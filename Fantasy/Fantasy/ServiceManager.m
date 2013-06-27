//
//  ServiceManager.m
//  
//  Created by Jennifer Duffey on 11/6/11.
//  Copyright (c) 2011 Trivie. All rights reserved.
//

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>
#import "ChatMessage.h"
#import "FormInfo.h"
#import "Stats.h"
#import "ShareManager.h"
#import "RequestData.h"
#import "AppDelegate.h"
#import "Error.h"
#import "QuestionResults.h"
#import "CategoryManager.h"

#define CERT_PASS "F9c1078"

@interface ServiceManager ()
{
	int mServerAPIMajor, mServerAPIMinor;
	NSString* mClientVersion;
	SecIdentityRef clientIdentity;
	SecTrustRef clientTrust;
	SecCertificateRef clientCert;
}

- (void)alertUserWithError:(NSError *)errorObj;
+ (NSString *)getPhotoSavePath;
// return dummy data
+ (NSDictionary *)getDummyDataForPath:(NSString *)path;
- (void) initCert;

@end

static ServiceManager *sharedInstance = nil;

@implementation ServiceManager

@synthesize callbackObject = _callbackObject;
@synthesize httpStatusCode = _httpStatusCode;
@synthesize currentRequest = _currentRequest;
@synthesize cachedRequests = _cachedRequests;
@synthesize requestsInQueue = _requestsInQueue;
@synthesize serverURL = _serverURL;
@synthesize updateURL = _updateURL;
@synthesize updateMessage = _updateMessage;
@synthesize successSelector = _successSelector;
@synthesize errorSelector = _errorSelector;
@synthesize needsAuthentication = _needsAuthentication;
@synthesize updateAvailable = _updateAvailable;
@synthesize siteOffline = _siteOffline;
@synthesize serverProtocol = _serverProtocol;

+ (ServiceManager *)sharedInstance
{
	static dispatch_once_t pred;
	dispatch_once(&pred, ^
	{
		sharedInstance = [[self alloc] init];
	});
	
	return sharedInstance;
}

- (id)init
{
	self = [super init];
	
	if(self)
	{
		[self initCert];
		//self.responseData = [[NSMutableData alloc] init];
		_cachedRequests = [NSMutableArray array];
		_currentRequest = nil;
		_requestsInQueue = NO;
		_serverProtocol = PROTOCOL_HTTPS; // Default to HTTPS going forward
		_serverURL = [_serverProtocol stringByAppendingString:SERVER_URL];
		
		mServerAPIMajor = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerAPIMajor"] intValue];
		mServerAPIMinor = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerAPIMinor"] intValue];
		mClientVersion = [Utils getVersionString];
	}
	
	return self;
}

- (void) switchToProtocol:(NSString*)_protocol;
{
	_serverProtocol = _protocol;
	_serverURL = [_serverProtocol stringByAppendingString:SERVER_URL];
}

- (void) initCert
{
	NSString* certPath = [[NSBundle mainBundle] pathForResource:@"TrivieClient" ofType:@"p12"];
	NSData* PKCS12Data = [NSData dataWithContentsOfFile:certPath];
	
	CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;
	
	OSStatus status = noErr;
	
	status = extractIdentityAndTrust(inPKCS12Data, &clientIdentity, &clientTrust);
	
	SecTrustResultType trustResult;
	
	if ( status == noErr )
	{
		SecTrustEvaluate(clientTrust, &trustResult);
		
		clientCert = NULL;
		SecIdentityCopyCertificate(clientIdentity, &clientCert);
		
		CFStringRef certSummary = SecCertificateCopySubjectSummary(clientCert);
		
		NSString* summaryString = [NSString stringWithString:(__bridge NSString*)certSummary];
		CFRelease(certSummary);
		
		NSLog(@"Certificate Summary:: %@", summaryString);
	}

}

OSStatus extractIdentityAndTrust(CFDataRef inPKCS12Data,
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust)
{
    OSStatus securityError = errSecSuccess;
	
    CFStringRef password = CFSTR(CERT_PASS);
    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { password };
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(
														   NULL, keys,
														   values, 1,
														   NULL, NULL);
		
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inPKCS12Data,
                                    optionsDictionary,
                                    &items);
	
	if (securityError == 0)
	{
		CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
		const void *tempIdentity = NULL;
		tempIdentity = CFDictionaryGetValue (myIdentityAndTrust,
											 kSecImportItemIdentity);
		*outIdentity = (SecIdentityRef)tempIdentity;
		const void *tempTrust = NULL;
		tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
		*outTrust = (SecTrustRef)tempTrust;
    }
	
    if (optionsDictionary)
        CFRelease(optionsDictionary);
	
	return securityError;
}

- (NSURLCredential*) getCredentials
{
	return [NSURLCredential credentialWithIdentity:clientIdentity
									  certificates:[NSArray arrayWithObject:(__bridge id)(clientCert)]
									   persistence:NSURLCredentialPersistenceForSession];
}

#define DEFAULT_TIMEOUT 10

#pragma mark -
#pragma mark Base Request Issuer
- (void) issueRequest:(ServerRequest*)_request
{
	if(!_request.isCancelled)
		[self issueRequest:_request withTimeout:DEFAULT_TIMEOUT];
}

- (void) issueRequest:(ServerRequest *)_request withTimeout:(NSUInteger)_timeout
{
	NSURL *url = [NSURL URLWithString:[_serverURL stringByAppendingString:_request.requestData.requestURL]];
	
	if([Utils isNullString:url.absoluteString])
		return;
	
	NSMutableURLRequest* urlRequest = [NSMutableURLRequest requestWithURL:url
															  cachePolicy:NSURLRequestReloadIgnoringCacheData
														  timeoutInterval:_timeout];
	NSMutableDictionary* headers = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"application/x-www-form-urlencoded", @"Content-Type",
							 @"application/json", @"Accept",
							 [NSString stringWithFormat:@"%i", mServerAPIMajor], @"server_api_major",
							 [NSString stringWithFormat:@"%i", mServerAPIMinor], @"server_api_minor",
							 mClientVersion, @"client_version", nil];
	
	if ( _request.additionalHeaders )
	{
		[headers addEntriesFromDictionary:_request.additionalHeaders];
	}
	
	[urlRequest setAllHTTPHeaderFields:headers];
	urlRequest.HTTPMethod = _request.requestData.HTTPMethod;
	
	//[urlRequest.allHTTPHeaderFields logDictionaryValuesAndKeys];

	
	/* 
	 NOTE: ONLY SHOWS LOG IF CURRENT SCHEME IS SET TO ONE OF THE '-Logging' SCHEMES 
	*/
#ifdef ALLOW_DEBUG_OUTPUT
	NSLog(@"Server Request: %@", url);
#endif
	
	// Append params
	NSString* params = _request.requestData.parameters;
	if (params != nil)
	{
		NSData* postData = [NSData dataWithData:[params dataUsingEncoding:NSUTF8StringEncoding]];
		
	/*
	 NOTE: ONLY SHOWS LOG IF CURRENT SCHEME IS SET TO ONE OF THE '-Logging' SCHEMES
	*/
#ifdef ALLOW_DEBUG_OUTPUT
		NSString *postDataString = [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding];
		NSLog(@"Request post data: %@", postDataString);
#endif
		
		//[ASIrequest appendPostData:postData];
		urlRequest.HTTPBody = postData;
	}
	
	/*
	 NOTE: If Scheme is set to 'Dummy Data' will return local (offline) data and request will 
	 automatically return 200
	 */
#ifdef ALLOW_DUMMY_DATA
	NSString *dummyName = [NSString stringWithFormat:@"Dummy_%i", _request.requestType];
	[_request dummyDataRequestFinished:[ServiceManager getDummyDataForPath:dummyName]];
	self.httpStatusCode = 200;
#else
	// Start and cache requests - limiting to arbitrary number of 10 - maybe re-explore this later
	[_request startRequest:urlRequest];
	
	if ( [_cachedRequests indexOfObject:_request] == NSNotFound )
	{
		[_cachedRequests addObject:_request];
	}
	if ( _cachedRequests.count > 10 )
	{
		[_cachedRequests removeObjectAtIndex:0];
	}
#endif
}

- (void)cancelRequestByType:(RequestType)type
{
	for(ServerRequest *req in _cachedRequests)
	{
		if(req.requestType == type)
		{
			[req setIsCancelled:YES];
			break;
		}
	}
}

+ (BOOL)requestUpdateAvailable
{
	return [ServiceManager sharedInstance].updateAvailable;
}

#pragma mark -
#pragma mark Check Facebook Credentials Helper
- (void) requestCheckFacebookCredentialsWithToken:(NSString *)_token onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"check_facebook_credentials/";
	NSString* params = [NSString stringWithFormat:@"access_token=%@&server_api_major=%i&server_api_minor=%i&client_version=%@", _token, mServerAPIMajor, mServerAPIMinor, mClientVersion];
	
	RequestData* requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_FACEBOOK_CREDENTIALS
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel];
	
	
	serverRequest.shouldHideLoadingMessage = NO;
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Register With Facebook Helper
- (void) requestRegisterWithFacebookToken:(NSString *)_token andUsername:(NSString *)_username onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"register_with_facebook/";
	NSString* params = [NSString stringWithFormat:@"access_token=%@&username=%@&server_api_major=%i&server_api_minor=%i&client_version=%@", _token, _username, mServerAPIMajor, mServerAPIMinor, mClientVersion];
	
	RequestData* requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_FACEBOOK_REGISTRATION 
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	
	serverRequest.shouldHideLoadingMessage = NO;
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Link With Facebook Helper
- (void) requestLinkAccountWithFacebookToken:(NSString *)_token onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"link_facebook/";
	NSString* params = [NSString stringWithFormat:@"access_token=%@", _token];
	
	RequestData* requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_PLEASE_WAIT];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_LINK_FACEBOOK
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Set Game Center ID
- (void) requestSetGameCenterID:(NSString *)_gcID andAlias:(NSString *)_alias onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"gamecenter_set_id/";
	NSString* params = [NSString stringWithFormat:@"gc_id=%@&gc_alias=%@", _gcID, _alias];
	
	RequestData* requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SET_GAMECENTER_ID
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Login Helper
- (void) requestLoginWithFormData:(NSDictionary *)_formData onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"login/";
	
	NSInteger version = ([Utils isFreeVersion]) ? 1 : 2;
	
	NSString *params = [NSString stringWithFormat:@"username=%@&password=%@&server_api_major=%i&server_api_minor=%i&client_version=%@&paid_version=%i", [_formData objectForKey:TEXT_FIELD_USERNAME], [_formData objectForKey:TEXT_FIELD_PASSWORD], mServerAPIMajor, mServerAPIMinor, mClientVersion, version];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_LOGIN
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel];
	
	
	self.needsAuthentication = NO;
	
	serverRequest.shouldHideLoadingMessage = NO;
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Origin Detection Helper
- (void) requestSendClientOrigin:(NSString *)_origin onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"record_origin_information/";
	
	NSString* params = [NSString stringWithFormat:@"origin_information=%@", _origin];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_ORIGIN_DETECTION
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel];
	serverRequest.shouldHideLoadingMessage = NO;
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Send Device Token Helper
- (void) requestSendDeviceToken:(NSString *)_token onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"register_push_device/";
	
	NSString *params = [NSString stringWithFormat:@"device_token=%@&username=%@", _token, [Player currentPlayer].userName];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SEND_DEVICE_TOKEN
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel
							 ];
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Registration Helper
- (void) requestRegistrationWithFormData:(NSDictionary *)_formData onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"register/";
	
	NSString *params = [NSString stringWithFormat:@"username=%@&password1=%@&password2=%@&email=%@&server_api_major=%i&server_api_minor=%i&client_version=%@", [_formData objectForKey:TEXT_FIELD_USERNAME], [_formData objectForKey:TEXT_FIELD_PASSWORD], [_formData objectForKey:TEXT_FIELD_PASSWORD2], [_formData objectForKey:TEXT_FIELD_EMAIL], mServerAPIMajor, mServerAPIMinor, mClientVersion];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_CREATE_ACCOUNT];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_REGISTRATION
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Token Denominations Helper
- (void) requestTokenDenominationsWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"get_token_denomination/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:LOAD_MESSAGE_STORE];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_TOKEN_DENOMINATIONS
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel
							  ];
	
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Avatars Helper
- (void)requestGetAvatarListWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"get_avatars_list/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:LOAD_MESSAGE_AVATARS];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_GET_AVATARS
												 andCallbackTarget:_target
											    withSuccessSelector:_successSel
												  andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}

- (void)requestSelectAvatarID:(int)avatarID withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"select_avatar/";
	
	NSString *params = [NSString stringWithFormat:@"avatar_id=%i", avatarID];
		
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_SUBMITTING_AVATARS];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SUBMIT_AVATARS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}

- (void)requestPurchaseAvatarSet:(int)avatarSetID withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"purchase_avatar_set/";
	
	NSString *params = [NSString stringWithFormat:@"avatar_set_id=%i", avatarSetID];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_UNLOCKING_AVATARS];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_UNLOCK_AVATARS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}


#pragma mark -
#pragma mark Get Category Tree Helper
- (void) requestCategoryTreeWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"get_category_tree/";
		
	/* server says no longer necessary
	
	if ( [CategoryManager sharedInstance].treeHash )
	{
		url = [url stringByAppendingFormat:@"?tree_hash=%@",[CategoryManager sharedInstance].treeHash];
	}
	
	url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];*/
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_GET_CATEGORIES
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel];

	serverRequest.shouldHideLoadingMessage = NO;
	
	if ( [CategoryManager sharedInstance].treeHash )
	{
		serverRequest.additionalHeaders = [NSDictionary dictionaryWithObject:[CategoryManager sharedInstance].treeHash
																	  forKey:@"If-None-Match"];
	}
	
	[self issueRequest:serverRequest withTimeout:60];
}

#pragma mark -
#pragma mark Categories Helper - DEPRECATED
- (void)requestAvailableCategoriesWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSLog(@"+++++++WARNING :: THIS METHOD IS DEPRECATED - USE requestCategoryTreeWithCallback INSTEAD++++++++");
	NSString* url = @"available_categories/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_CATEGORIES];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_GET_CATEGORIES
												 andCallbackTarget:_target
											    withSuccessSelector:_successSel
												  andErrorSelector:_errorSel
							  ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Sub Categories Helper - DEPRECATED
- (void)requestAvailableSubCategoriesForCategoryName:(NSString *)catName withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSLog(@"+++++++WARNING :: THIS METHOD IS DEPRECATED - USE requestCategoryTreeWithCallback INSTEAD++++++++");
	NSString* url = @"available_subcategories/";
	
	NSString* escapedCatName = [catName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	escapedCatName = [escapedCatName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	
	NSString *params = [NSString stringWithFormat:@"category_name=%@", escapedCatName];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_SUBCATEGORIES];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_GET_SUBCATEGORIES
												 andCallbackTarget:_target
											    withSuccessSelector:_successSel
												  andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Available Packs Helper - DEPRECATED
- (void)requestAvailablePacksForCategoryName:(NSString *)catName andSubCategoryName:(NSString *)subCatName withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
{
	NSLog(@"+++++++WARNING :: THIS METHOD IS DEPRECATED - USE requestCategoryTreeWithCallback INSTEAD++++++++");
	NSString* url = @"available_packs/";
	
	NSString* escapedCatName = [catName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	escapedCatName = [escapedCatName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	
	NSString* escapedSubName = [subCatName stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	escapedSubName = [escapedSubName stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
	
	NSString *params = [NSString stringWithFormat:@"category_name=%@&sub_category_name=%@", escapedCatName, escapedSubName];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_QUESTIONPACKS];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_GET_QUESTION_PACK
												 andCallbackTarget:_target
											    withSuccessSelector:_successSel
												  andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Search User Helper
- (void) requestSearchForUser:(NSString *)_username onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"search_users/";
	
	NSString *params = [NSString stringWithFormat:@"username=%@", _username];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_SEARCHING];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_USER_SEARCH
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Search Email Helper
- (void)requestSearchForEmails:(NSArray*)_emails onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"search_users_email/";
	
	NSString* emails = [_emails componentsJoinedByString:@"\",\""];
	
	NSString *params = [NSString stringWithFormat:@"email_list=[\"%@\"]", emails];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_SEARCHING];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_EMAIL_SEARCH
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Search by Facebook IDs
- (void)requestSearchForFacebookIDs:(NSArray*)_ids onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"search_users_fb/";
	
	NSString* ids = [_ids componentsJoinedByString:@"\",\""];
	
	NSString *params = [NSString stringWithFormat:@"fb_id_list=[\"%@\"]", ids];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_FACEBOOK_USER_SEARCH
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Search by Game Center IDs
- (void)requestSearchForGameCenterIDs:(NSArray *)_ids onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"search_users_gamecenter/";
	
	NSString* ids = [_ids componentsJoinedByString:@"\",\""];
	
	NSString *params = [NSString stringWithFormat:@"gc_id_list=[\"%@\"]", ids];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_GAMECENTER_USER_SEARCH
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Request Matches Helper
- (void)requestMatchesWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"get_matches_status/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_ALL_MATCHES
												 andCallbackTarget:_target
											    withSuccessSelector:_successSel
												  andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark User Stats Helper
- (void) requestUserStatsWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"get_user_profile/";
	
	//NSString *params = [NSString stringWithFormat:@"username=%@", [Player currentPlayer].userName];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_USER_STATS
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel ];
	
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Logout Helper
- (void) requestLogoutWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString* url = @"logout/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:LOAD_MESSAGE_LOGOUT];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_LOGOUT
															andCallbackTarget:_target
														  withSuccessSelector:_successSel
															 andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Chat Helper
- (void)requestChatMessagesForMatchID:(NSString*)_matchID andCallback:(id)_target  withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"chat_get/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@", _matchID];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_GET_CHAT_MESSAGES];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_CHAT_MESSAGES andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

- (void)requestSendChatMessage:(ChatMessage *)_message withCallback:(id)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"chat_new_message/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@&msg=%@", _message.matchID, _message.messageString];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SEND_CHAT_MESSAGE andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Start Match Helper
- (void)requestStartMatchWithUsername:(NSString *)_challengee andQuestionFilterID:(int)qID isFriend:(BOOL)_isFriend onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_request/";
	NSInteger isFriend = [[NSNumber numberWithBool:_isFriend] integerValue];
	NSString *params;
	if ( qID <= 0 )
	{
		params = [NSString stringWithFormat:@"challenge_username=%@&is_facebook_friend=%i", _challengee, isFriend];
	}
	else
	{
		params = [NSString stringWithFormat:@"challenge_username=%@&question_filter_id=%i&is_facebook_friend=%i", _challengee, qID, isFriend];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_CREATE_MATCH];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_MATCH andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

- (void)requestStartFirstMatchWithUsername:(NSString *)_challengee
					   andQuestionFilterID:(int)qID
								  isFriend:(BOOL)_isFriend
						  onCallbackTarget:(NSObject *)_target
					   withSuccessSelector:(SEL)_successSel
						  andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_request/";
	NSInteger isFriend = [[NSNumber numberWithBool:_isFriend] integerValue];
	NSString *params;
	if ( qID <= 0 )
	{
		params = [NSString stringWithFormat:@"challenge_username=%@&is_facebook_friend=%i&free_ride=1", _challengee, isFriend];
	}
	else
	{
		params = [NSString stringWithFormat:@"challenge_username=%@&question_filter_id=%i&is_facebook_friend=%i&free_ride=1", _challengee, qID, isFriend];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_CREATE_MATCH];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_MATCH andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

- (void)requestMatchmakingWithQuestionFilterID:(int)_qID onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_find_opponent/";
	
	NSString *params;
	if ( _qID <= 0 )
	{
		params = nil;
	}
	else
	{
		params = [NSString stringWithFormat:@"question_filter_id=%i", _qID];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_FIND_MATCH];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_MATCHMAKING andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest withTimeout:15];
}

- (void)requestFirstTimeMatchmakingWithQuestionFilterID:(int)_qID onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_find_opponent/";
	
	NSString *params;
	if ( _qID <= 0 )
	{
		params = nil;
	}
	else
	{
		params = [NSString stringWithFormat:@"question_filter_id=%i&free_ride=1", _qID];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_FIND_MATCH];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_MATCHMAKING andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest withTimeout:15];
}

#pragma mark -
#pragma mark Respond to Match Helper
- (void)requestRespondToMatchID:(NSString*)_matchID accept:(BOOL)_accepted andQuestionFilterID:(int)_qID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_response/";
	
	NSString *accepted = (_accepted) ? @"yes" : @"no";
	
	NSString *params;
	if ( _qID <= 0 )
	{
		params = [NSString stringWithFormat:@"match_id=%@&accept=%@", _matchID, accepted];
	}
	else
	{
		params = [NSString stringWithFormat:@"match_id=%@&accept=%@&question_filter_id=%i", _matchID, accepted, _qID];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_MATCH_RESPONSE];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_RESPOND_MATCH andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest withTimeout:15];
}

#pragma mark -
#pragma mark Send Round Results Helper
- (void)requestSendRoundResults:(NSArray *)_results andWager:(NSInteger)_wager forMatchID:(NSString*)matchID withPowerUp:(int)_powerup onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_round_send_results/";
	
	NSMutableArray* answerList = [NSMutableArray arrayWithCapacity:_results.count];
	NSMutableArray* scoreList = [NSMutableArray arrayWithCapacity:_results.count];
	NSMutableArray* timeList = [NSMutableArray arrayWithCapacity:_results.count];
	int tokens = 0;
	
	for ( NSUInteger counter = 0; counter < _results.count ; counter++)
	{
		QuestionResults *qr = (QuestionResults *)[_results objectAtIndex:counter];
		[answerList addObject:qr.answerText];
		[scoreList addObject:[NSNumber numberWithInt:qr.questionScore]];
		[timeList addObject:qr.answerTime];
		tokens += qr.awardTokens;
		//[paramList appendFormat:@"&answer_%i=%@&score_%i=%i", counter + 1, qr.answerText, counter + 1, qr.questionScore];
	}
	
	NSString* answers = [answerList componentsJoinedByString:@"\",\""];
	NSString* scores = [scoreList componentsJoinedByString:@"\",\""];
	NSString* times = [timeList componentsJoinedByString:@"\",\""];
	
	NSInteger version = ([Utils isFreeVersion]) ? 1 : 2;
	
	NSMutableString *paramList = [NSMutableString stringWithFormat:@"match_id=%@&answers=[\"%@\"]&scores=[\"%@\"]&answers_timing=[\"%@\"]&award_tokens=%i&final_trivie_wager=%i&paid=%i", matchID, answers, scores, times, tokens, _wager, version];
	
	if ( _powerup > 0 )
	{
		[paramList appendFormat:@"&powerup=%i",_powerup];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:paramList viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_SUBMIT_RESULTS];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SUBMIT_END_OF_ROUND_RESULTS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Send Round Results After Crash Helper
- (void)requestSendRecoveredGame:(NSDictionary *)_results onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_round_send_results/";
	
	NSMutableArray* answerList = [[_results valueForKey:@"answers"] mutableCopy];
	NSMutableArray* scoreList = [[_results valueForKey:@"scores"] mutableCopy];
	NSMutableArray* timeList = [[_results valueForKey:@"times"] mutableCopy];
	
	int tokens = [[_results valueForKey:@"tokens"] intValue];
	
	int answerCount = [[_results valueForKey:@"questionCount"] intValue];
	for ( int counter = answerList.count; counter < answerCount ; counter++)
	{
		// Fill in any remaining slots with nulled values
		[answerList addObject:@"None"];
		[scoreList addObject:[NSNumber numberWithInt:0]];
		[timeList addObject:@"0"];
	}
	
	NSString* answers = [answerList componentsJoinedByString:@"\",\""];
	NSString* scores = [scoreList componentsJoinedByString:@"\",\""];
	NSString* times = [timeList componentsJoinedByString:@"\",\""];
	NSInteger powerup = [[_results valueForKey:@"powerup"] integerValue];
	
	NSInteger version = ([Utils isFreeVersion]) ? 1 : 2;
	
	NSMutableString *paramList = [NSMutableString stringWithFormat:@"round_recovery=true&match_id=%@&answers=[\"%@\"]&scores=[\"%@\"]&answers_timing=[\"%@\"]&award_tokens=%i&final_trivie_wager=%i&paid=%i",
								  [_results objectForKey:@"matchID"], answers, scores, times, tokens, 0, version];
	
	if ( powerup > 0 )
	{
		[paramList appendFormat:@"&powerup=%i",powerup];
	}
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:paramList viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SUBMIT_END_OF_ROUND_RESULTS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Resume Match Helper
- (void)requestResumeMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_resume/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@", _matchID];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_MATCH_RESUME];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_RESUME_MATCH andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	
	
	[self issueRequest:serverRequest withTimeout:15];
}

- (void)requestResumeMatchID:(NSString*)_matchID withWager:(NSInteger)_wager onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_resume/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@&final_trivie_wager=%i", _matchID, _wager];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_MATCH_RESUME];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_RESUME_MATCH andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest withTimeout:15];
}

#pragma mark -
#pragma mark Get Round Results Helper
- (void)requestResultsFromRound:(int)_roundNumber forMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSLog(@"+++++++WARNING :: THIS METHOD IS DEPRECATED - USE requestDetailforMatchID INSTEAD++++++++");
	
	NSString *url = @"match_round_get_results/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@&round_num=%i", _matchID, _roundNumber];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_ROUND_RESULTS];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_ROUND_RESULTS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Get Final Results Helper
- (void)requestFinalResultsForMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_get_results/";

	NSString *params = [NSString stringWithFormat:@"match_id=%@", _matchID];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_FINAL_RESULTS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Get Match Details Helper
- (void)requestDetailforMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_get_details/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@", _matchID];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_MATCH_DETAILS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	
	
	[self issueRequest:serverRequest withTimeout:15];
}

#pragma mark -
#pragma mark Send Wager Helper
- (void) requestSendWager:(NSInteger)_wager forMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"match_set_final_trivie_wager/";
	
	NSString *params = [NSString stringWithFormat:@"match_id=%@&final_trivie_wager=%i", _matchID, _wager];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_SET_WAGER andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel];
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Token Helper
- (void)requestValidateTokenPurchase:(int)_tokenAmount withReceipt:(NSData*)_receipt onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"validate_token_purchase/";
	
	NSString *params = [NSString stringWithFormat:@"amount=%i&receipt=%@", _tokenAmount, _receipt];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_VALIDATE_TOKEN_PURCHASE andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	
	
	[self issueRequest:serverRequest];
}

- (void)requestConsumeTokens:(int)_tokenAmount onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"consume_tokens/";
	
	NSString *params = [NSString stringWithFormat:@"amount=%i", _tokenAmount];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_CONSUME_TOKENS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

- (void)requestAwardTokens:(int)_tokenAmount onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"award_tokens/";
	
	NSString *params = [NSString stringWithFormat:@"amount=%i", _tokenAmount];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_AWARD_TOKENS andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}

- (void)requestTokenInfoForCurrentUserWithCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"get_token_info/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_TOKEN_INFO andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	[self issueRequest:serverRequest];
}


#pragma mark -
#pragma mark Paid Upgrade Helper
- (void)requestValidatePaidUpgradeWithReceipt:(NSData *)_receipt onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel
{
	NSString *url = @"validate_paid_upgrade/";
	
	NSString *params = [NSString stringWithFormat:@"receipt=%@", _receipt];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:nil];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_VALIDATE_TOKEN_PURCHASE andCallbackTarget:_target withSuccessSelector:_successSel andErrorSelector:_errorSel ];
	
	//serverRequest.shouldHideLoadingMessage = NO;
	
	[self issueRequest:serverRequest];
}

#pragma mark -
#pragma mark Premium Content Helper
- (void)requestPremiumStoreInfoWithCallback:(NSObject *)target successSelector:(SEL)successSel andErrorSelector:(SEL)errorSel
{
    // initWithRequestURL ignores andParameters if the method is HTTP_GET
    // that should probably be fixed and supported, but I'm just abusing the URL instead
    NSString *params = [NSString stringWithFormat:@"client_version=%@", mClientVersion];
    params = [params stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *url = [NSString stringWithFormat:@"get_premium_store/?%@", params];
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_PREMIUM_STORE_INFO andCallbackTarget:target withSuccessSelector:successSel andErrorSelector:errorSel];
	
	[self issueRequest:serverRequest];
}

- (void)requestValidatePremiumPurchaseForPackID:(int)packID withReceipt:(NSData *)receipt onCallbackTarget:(NSObject *)target withSuccessSelector:(SEL)successSel andErrorSelector:(SEL)errorSel
{
	NSString *url = @"validate_premium_purchase/";
	
	NSString *params;
	
	if(receipt)
	{
		params = [NSString stringWithFormat:@"pack_id=%i&receipt=%@", packID, receipt];
	}
	else
	{
		params = [NSString stringWithFormat:@"pack_id=%i", packID];
	}
		
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:params viaHTTPMethod:HTTP_POST messageToDisplay:LOAD_MESSAGE_VALIDATING_PURCHASE];
	
	ServerRequest *serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_VALIDATE_PREMIUM_PURCHASE andCallbackTarget:target withSuccessSelector:successSel andErrorSelector:errorSel ];
	
	
	[self issueRequest:serverRequest];
}

-(void) requestGetPremiumPurchasesWithCallback:(NSObject *)target successSelector:(SEL)successSel andErrorSelector:(SEL)errorSel
{
	NSString* url = @"get_premium_purchases/";
	
	RequestData *requestData = [[RequestData alloc] initWithRequestURL:url andParameters:nil viaHTTPMethod:HTTP_GET messageToDisplay:nil];
	
	ServerRequest* serverRequest = [[ServerRequest alloc] initWithRequestData:requestData type:REQUEST_PREMIUM_PURCHASE_INFO andCallbackTarget:target withSuccessSelector:successSel andErrorSelector:errorSel];
	
	[self issueRequest:serverRequest];
}

#pragma mark -

+ (void)requestSetNewServerURL:(int)index
{
	[[ServiceManager sharedInstance] issueRequestSetNewServerURL:index];
}

- (void)issueRequestSetNewServerURL:(int)index
{
	NSString *newURL;
	
	switch(index)
	{
		case 1:
			_serverProtocol = PROTOCOL_HTTP;
			newURL = SERVER_URL_DEV;
			break;
			
		case 2:
			_serverProtocol = PROTOCOL_HTTP;
			newURL = SERVER_URL_TYLER;
			break;
			
		case 3:
			_serverProtocol = PROTOCOL_HTTP;
			newURL = SERVER_URL_INTERNAL;
			break;
		
		case 4:
			newURL = SERVER_URL_PROD;
			break;
	}
	
	[[NSUserDefaults standardUserDefaults] setValue:newURL forKey:kTRServerURLKey];
	self.serverURL = [_serverProtocol stringByAppendingString:newURL];
}

+ (NSString *)getCurrentUserName
{
     NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     return [userDefaults objectForKey:kTRUsernameKey];
}

+ (NSString *)getCurrentPassword
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
     return [userDefaults objectForKey:kTRPasswordKey];
}

+ (void)setCurrentUser:(Player *)user
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if(user == nil)
	{
		[userDefaults removeObjectForKey:kTRUsernameKey];
		[userDefaults removeObjectForKey:kTRPasswordKey];
	}
	else
	{
		[userDefaults setValue:user.userName forKey:kTRUsernameKey];
		[userDefaults setValue:user.password forKey:kTRPasswordKey];
	}
	
	[userDefaults synchronize];
}

+ (void)uploadUserImage:(UIImage *)image
{
     [UIImagePNGRepresentation(image) writeToFile:[self getPhotoSavePath] atomically:YES];
}

+ (UIImage *)getUserImage
{
     UIImage *img = [UIImage imageWithContentsOfFile:[self getPhotoSavePath]];
     return img;
}

+ (NSString *)getPhotoSavePath
{
     return [NSString stringWithFormat:@"%@/Documents/ProfilePic.PNG", NSHomeDirectory()];;
}

- (void)alertUserWithError:(NSError *)errorObj
{
	UIAlertView *alert = [Utils createAlertWithTitle:NSLocalizedString(@"ServerFailureDescription", @"")  message:errorObj.localizedDescription showCancelButton:YES andDelegate:self];
	[alert show];
}

#pragma mark -
#pragma mark UIAlertView Delegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if ( [alertView.title isEqualToString:@"Update Available"] )
	{
		if ( buttonIndex == 0 )
		{
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updateURL]];
		}
	}
}

#pragma mark -
#pragma mark Dummy Data
+ (NSDictionary *)getDummyDataForPath:(NSString *)path
{
	NSError *error;
	
	NSString *fullPath = [[NSBundle mainBundle] pathForResource:path ofType:@"txt"];
	
	NSString *dummyData = [NSString stringWithContentsOfFile:fullPath encoding:NSUTF8StringEncoding error:&error];
	
	NSData *jsonData = [NSData dataWithData:[dummyData dataUsingEncoding:NSUTF8StringEncoding]];
	
	return (NSDictionary *)[NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
}



@end

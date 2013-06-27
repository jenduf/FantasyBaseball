//
//  YahooClient.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/24/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "YahooClient.h"
#import "NSString+URLEncoding.h"
#import "NSData+Base64.h"
#import "NSString+RegEx.h"
#import "AuthRequest.h"
#import "AccessToken.h"
#import "YOAuthUtil.h"

@implementation YahooClient

+ (YahooClient *)sharedClient
{
	NSString *urlString = @"https://api.login.yahoo.com/oauth/v2/";
	
	static dispatch_once_t pred;
	static YahooClient *_sharedClient = nil;

	dispatch_once(&pred, ^
	{
		_sharedClient = [[self alloc] initWithAPIURL:[NSURL URLWithString:urlString] withParameters:nil];
	});
	
	return _sharedClient;
}

- (id)initWithAPIURL:(NSString *)url withParameters:(NSString *)parameters
{
	self = [super init];
	
	if(self)
	{
		[self setApiURL:url];
		
		NSDictionary *tokenDict = [NSDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:KEY_ACCESS_TOKEN]];
		
		if(tokenDict)
			self.accessToken = [[AccessToken alloc] initWithDictionary:tokenDict];
	}
	
	return self;
}

/*
- (NSString *)buildAuthorizationHeaderValue
{
	NSMutableArray *authorizationHeaderParts = [[NSMutableArray alloc] init];
	
	if(realm && ![realm isEqualToString:@""]) {
		[authorizationHeaderParts addObject:[NSString stringWithFormat:@"realm=\"%@\"", [realm URLEncodedString]]];
	}
	
	[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_consumer_key=\"%@\"", [self.consumer.key URLEncodedString]]];
	[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_signature_method=\"%@\"", [[signatureMethod name] URLEncodedString]]];
	[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_signature=\"%@\"", [self.oauthSignature URLEncodedString]]];
	[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_timestamp=\"%@\"", [self.oauthTimestamp URLEncodedString]]];
	[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_nonce=\"%@\"", [self.oauthNonce URLEncodedString]]];
	[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_version=\"%@\"", [self.oauthVersion URLEncodedString]]];
	
	if(token && ![token.key isEqualToString:@""]){
		[authorizationHeaderParts addObject:[NSString stringWithFormat:@"oauth_token=\"%@\"", [self.token.key URLEncodedString]]];
	}
	
	NSString *authorizationHeaderValue = [NSString stringWithFormat:@"OAuth %@", [authorizationHeaderParts componentsJoinedByString:@","]];
	
	[authorizationHeaderParts release];
	
	return authorizationHeaderValue;
}*/

- (void)startRequestWithURL:(NSURL *)url
{
	NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
	NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
	
	NSString *concatenatedSecret = [NSString stringWithFormat:@"%@%@", YAHOO_API_SECRET, self.accessToken.tokenSecret];
	
	NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
	[parametersDict setObject:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
	[parametersDict setObject:timeinNSString forKey:@"oauth_timestamp"];
	[parametersDict setObject:YAHOO_API_KEY forKey:@"oauth_consumer_key"];
	[parametersDict setObject:concatenatedSecret forKey:@"oauth_signature"];
	[parametersDict setObject:[NSString stringWithFormat:@"PLAINTEXT"] forKey:@"oauth_signature_method"];
	[parametersDict setObject:self.accessToken.token forKey:@"oauth_token"];
	[parametersDict setObject:@"1.0" forKey:@"oauth_version"];
	
	NSLog(@"Request: %@, Parameters: %@", url, parametersDict);
	
	NSData *postBody = [[parametersDict QueryString] dataUsingEncoding:NSUTF8StringEncoding];
	
	//	NSLog(@"Parameters mixed: %@", [parametersDict QueryString]);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postBody];
	
	self.responseData = [NSMutableData data];
	
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}


- (void)getGame
{
	self.requestType = REQUEST_GAME;
	
	NSString *gameURL = [NSString stringWithFormat:@"%@getGame?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:gameURL]];
}

- (void)getLeague
{
	self.requestType = REQUEST_LEAGUE;
	
	NSString *leagueURL = [NSString stringWithFormat:@"%@getLeague?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:leagueURL]];
}

- (void)getTeams
{
	self.requestType = REQUEST_TEAMS;
	
	NSString *teamsURL = [NSString stringWithFormat:@"%@get_teams?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:teamsURL]];
}

- (void)getScoreboard
{
	self.requestType = REQUEST_SCOREBOARD;
	
	NSString *scoreboardURL = [NSString stringWithFormat:@"%@get_scoreboard?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:scoreboardURL]];
}

- (void)getStandings
{
	self.requestType = REQUEST_STANDINGS;
	
	NSString *standingsURL = [NSString stringWithFormat:@"%@get_standings?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:standingsURL]];
}

- (void)getPlayers
{
	self.requestType = REQUEST_PLAYERS;
	
	NSString *playersURL = [NSString stringWithFormat:@"%@get_ownership?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:playersURL]];
}

- (void)getMyTeam
{
	self.requestType = REQUEST_MY_TEAM;
	
	NSString *playersURL = [NSString stringWithFormat:@"%@get_my_team?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:playersURL]];
}

- (void)getMyRoster
{
	self.requestType = REQUEST_MY_ROSTER;
	
	NSString *playersURL = [NSString stringWithFormat:@"%@get_my_roster?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:playersURL]];
}

- (void)getStats
{
	self.requestType = REQUEST_STATS;
	
	NSString *statsURL = [NSString stringWithFormat:@"%@get_stats?format=json", QUERY_URL];
	
	[self startRequestWithURL:[NSURL URLWithString:statsURL]];
}

- (void)editRoster
{
	self.requestType = REQUEST_MY_TEAM;
	
	NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
	NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
	
	NSString *concatenatedSecret = [YOAuthUtil buildSignatureWithRequest:@"a5eab504270b60d264bdb0396389ab0b4665fcef" andSecrets:self.accessToken.tokenSecret];//[NSString stringWithFormat:@"%@%@", YAHOO_API_SECRET, self.accessToken.tokenSecret];
	
	NSString *sigMethod = @"HMAC-SHA1";
	
	NSString *urlString = [NSString stringWithFormat:@"http://fantasysports.yahooapis.com/fantasy/v2/team/%@.t.5/roster/players", [League currentLeague].leagueKey];//?format=json&oauth_nonce=ce2130523f788f313f76314ed3965ea6&oauth_timestamp=%@&oauth_consumer_key=%@&oauth_signature=%@&oauth_signature_method=%@&oauth_token=%@&oauth_version=1.0", [League currentLeague].leagueKey, timeinNSString, YAHOO_API_KEY, concatenatedSecret, sigMethod, self.accessToken.token];
	
	
	NSString *queryString = [YOAuthUtil queryStringWithURL:[NSURL URLWithString:urlString] method:@"PUT" parameters:nil consumerKey:YAHOO_API_KEY consumerSecret:@"a5eab504270b60d264bdb0396389ab0b4665fcef" token:self.accessToken.token tokenSecret:self.accessToken.tokenSecret];
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", urlString, queryString]];
	
	
	
/*
	NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
	[parametersDict setObject:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
	[parametersDict setObject:timeinNSString forKey:@"oauth_timestamp"];
	[parametersDict setObject:YAHOO_API_KEY forKey:@"oauth_consumer_key"];
	[parametersDict setObject:concatenatedSecret forKey:@"oauth_signature"];
	[parametersDict setObject:[NSString stringWithFormat:@"PLAINTEXT"] forKey:@"oauth_signature_method"];
	[parametersDict setObject:self.accessToken.token forKey:@"oauth_token"];
	[parametersDict setObject:@"1.0" forKey:@"oauth_version"];
	
	NSLog(@"Request: %@, Parameters: %@", urlString, parametersDict);
	
	NSData *postBody = [[parametersDict QueryString] dataUsingEncoding:NSUTF8StringEncoding];
	
	//	NSLog(@"Parameters mixed: %@", [parametersDict QueryString]);
	*/
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	//[request setHTTPMethod:@"PUT"];
	//	[request setHTTPBody:postBody];
	
	self.responseData = [NSMutableData data];
	
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)initAccessToken
{
	self.requestType = REQUEST_AUTH;
	
	NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_request_token"];
	
	NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
	NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
	//NSLog(@"timeStamp: %@", timeinNSString);
	
	//NSString *callback = [[NSString stringWithFormat:@"http://fantasy.com/callback"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	//NSString *end = [NSString stringWithFormat:@"%@?oauth_callback=%@", urlString, callback];
	
	NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
	[parametersDict setObject:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
	[parametersDict setObject:timeinNSString forKey:@"oauth_timestamp"];
	[parametersDict setObject:YAHOO_API_KEY forKey:@"oauth_consumer_key"];
	[parametersDict setObject:YAHOO_API_SECRET forKey:@"oauth_signature"];
	[parametersDict setObject:[NSString stringWithFormat:@"PLAINTEXT"] forKey:@"oauth_signature_method"];
	[parametersDict setObject:@"http://fantasy.com/callback" forKey:@"oauth_callback"];
	[parametersDict setObject:@"1.0" forKey:@"oauth_version"];
	
	NSLog(@"Parameters: %@", parametersDict);
		
	NSData *postBody = [[parametersDict QueryString] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"Parameters mixed: %@", [parametersDict QueryString]);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postBody];
	
	//NSString *oauthValue = [NSString stringWithFormat:@"OAuth realm=\"yahooapis.com\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"%@\", oauth_version=\"1.0\", oauth_signature=\"%@\"", [NSString stringWithFormat:@"%@", YAHOO_API_KEY], timeinNSString, timeinNSString, YAHOO_API_SECRET];
	
	//NSLog(@"%@", oauthValue);
	
	//[request setAllHTTPHeaderFields:[NSDictionary dictionaryWithObject:oauthValue forKey:@"Authorization"]];
	
	
	self.responseData = [NSMutableData data];
	
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	/*
	//[self.urlConnection start];
	
	
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	request.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:PRE_APPROVED_TOKEN_STRING, @"type", nil];
	[request setPostValue:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
	[request setPostValue:timeinNSString forKey:@"oauth_timestamp"];
	[request setPostValue:[NSString stringWithFormat:@"%@", YAHOO_API_KEY] forKey:@"oauth_consumer_key"];
	[request setPostValue:@"plaintext" forKey:@"oauth_signature_method"];
	[request setPostValue:YAHOO_API_SECRET forKey:@"oauth_signature"];
	[request setPostValue:@"1.0" forKey:@"oauth_version"];
	[request setPostValue:callback forKey:@"oauth_callback"];
	
	[request setPostValue:[NSString stringWithFormat:@"jduffey_99@yahoo.com"] forKey:@"login"];
	[request setPostValue:[NSString stringWithFormat:@"Sarah6964"] forKey:@"password"];
	[request setDelegate:self];
	[request startSynchronous];
	
	//NSLog(@"curl -d 'oauth_consumer_key=%@&oauth_token=%@&oauth_signature_method=plaintext&oauth_signature=%@&oauth_session_handle=%@&oauth_timestamp=%@&oauth_nonce=abcde&oauth_version=1.0' https://api.login.yahoo.com/oauth/v2/get_token", [NSString stringWithFormat:@"%@", YAHOO_API_KEY],oauthToken,escapedUrlString,oauthSessionHandle, timeinNSString);
	
	NSError *error = [request error];
	
	if(!error)
	{
		NSString *response = [request responseString];
		NSLog(@"Response: %@", response);
	}
	else
	{
		NSLog(@"%@", [error description]);
	}*/
}

- (void)requestAccessTokenWithVerifier:(NSString *)verifier
{
	self.requestType = REQUEST_TOKEN;
	
	self.verifier = verifier;
	
	NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_token"];
	
	NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
	NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
	//NSLog(@"timeStamp: %@", timeinNSString);
	
	NSString *concatenatedSecret = [NSString stringWithFormat:@"%@%@", YAHOO_API_SECRET, self.authRequest.tokenSecret];
	
	NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
	[parametersDict setObject:YAHOO_API_KEY forKey:@"oauth_consumer_key"];
	[parametersDict setObject:timeinNSString forKey:@"oauth_timestamp"];
	[parametersDict setObject:[NSString stringWithFormat:@"PLAINTEXT"] forKey:@"oauth_signature_method"];
	[parametersDict setObject:verifier forKey:@"oauth_verifier"];
	[parametersDict setObject:@"1.0" forKey:@"oauth_version"];
	[parametersDict setObject:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
	[parametersDict setObject:concatenatedSecret forKey:@"oauth_signature"];
		[parametersDict setObject:self.authRequest.token forKey:@"oauth_token"];
	
	NSLog(@"Parameters: %@", parametersDict);
	
	NSData *postBody = [[parametersDict QueryString] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"Parameters mixed: %@", [parametersDict QueryString]);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postBody];
	
	self.responseData = nil;
	self.responseData = [NSMutableData data];
	
	self.urlConnection = nil;
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)refreshToken
{
	self.requestType = REQUEST_TOKEN_REFRESH;
	
	NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_token"];
	
	NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
	NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
	//NSLog(@"timeStamp: %@", timeinNSString);
	
	NSString *concatenatedSecret = [NSString stringWithFormat:@"%@%@", YAHOO_API_SECRET, self.accessToken.tokenSecret];
	
	NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
	[parametersDict setObject:YAHOO_API_KEY forKey:@"oauth_consumer_key"];
	[parametersDict setObject:timeinNSString forKey:@"oauth_timestamp"];
	[parametersDict setObject:[NSString stringWithFormat:@"PLAINTEXT"] forKey:@"oauth_signature_method"];
	[parametersDict setObject:@"1.0" forKey:@"oauth_version"];
	[parametersDict setObject:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
	[parametersDict setObject:concatenatedSecret forKey:@"oauth_signature"];
	[parametersDict setObject:self.accessToken.token forKey:@"oauth_token"];
	[parametersDict setObject:self.accessToken.sessionHandle forKey:@"oauth_session_handle"];
	
	NSLog(@"Parameters: %@", parametersDict);
	
	NSData *postBody = [[parametersDict QueryString] dataUsingEncoding:NSUTF8StringEncoding];
	
	NSLog(@"Parameters mixed: %@", [parametersDict QueryString]);
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:@"POST"];
	[request setHTTPBody:postBody];
	
	self.responseData = nil;
	self.responseData = [NSMutableData data];
	
	self.urlConnection = nil;
	self.urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)startRequestWithDelegate:(id)del
{
	self.delegate = del;
	
	if (!self.accessToken)
	{
		//Call init get access token
		NSLog(@"Call init get access token");
		[self initAccessToken];
	}
	else
	{
		
		[self refreshToken];
	}
}

/*
- (void)requestApiWithOauthToken:(NSString *)oauthToken withOauthTokenSecret:(NSString*)oauthTokenSecret
{
	NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
	NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
	NSLog(@"timeStamp: %@", timeinNSString);
	
	NSString* escapedUrlString = [NSString stringWithFormat:@"%@&", YAHOO_API_SECRET];
	
	NSLog(@"escapedUrlString: %@", escapedUrlString);
	
	
	NSString *baseUrl = @"https://api.login.yahoo.com/oauth/v2/";
	
	NSMutableDictionary *parameterDic = [NSMutableDictionary dictionaryWithObjects:
								  [NSArray arrayWithObjects:@"json", [NSString stringWithFormat:@"%@", YAHOO_API_KEY], timeinNSString, @"HMAC-SHA1", timeinNSString, oauthToken, @"1.0", nil]
															 forKeys:
								  [NSArray arrayWithObjects:@"format", @"oauth_consumer_key", @"oauth_nonce", @"oauth_signature_method", @"oauth_timestamp", @"oauth_token", @"oauth_version", nil]];
	
	
	NSString *searchString = self.parameters;
	NSString *regexString  = @"((\\w+)\\=(\\w+))";
	NSString *regexSpiltString  = @"\\=";
	NSArray  *matchArray   = NULL;
	
	matchArray = [searchString componentsMatchedByRegex:regexString];
	NSLog(@"matchArray: %@", matchArray);
	
	for (NSString* pairPara in matchArray) {
		NSArray  *splitArray   = NULL;
		splitArray = [pairPara componentsSeparatedByRegex:regexSpiltString];
		NSLog(@"splitArray: %@", splitArray);
		[parameterDic setObject:[splitArray objectAtIndex:1] forKey:[splitArray objectAtIndex:0]];
		
	}
	
	
	
	NSArray *myKeys = [parameterDic allKeys];
	NSArray *sortedKeys = [myKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
	
	NSString *parameters = @"";
	
	for (int k=0; k < [myKeys count]; k++) {
		parameters = [NSString stringWithFormat:@"%@%@=%@", [parameters isEqualToString:@""]?[NSString stringWithFormat:@""]:[NSString stringWithFormat:@"%@&", parameters] , [sortedKeys objectAtIndex:k],[parameterDic objectForKey: [sortedKeys objectAtIndex:k]]];
	}
	
	NSLog(@"parameters: %@", parameters);
	
	
	NSString *urlencodebaseUrl = [baseUrl URLEncodedString];
	
	NSString *urlencodeParameter = [parameters URLEncodedString];
	
	NSString *baseData = [NSString stringWithFormat:@"GET&%@&%@", urlencodebaseUrl, urlencodeParameter];
	NSString *encodeBaseData = [[self oauthGenerateHMAC_SHA1SignatureFor:baseData withClientSecret:[NSString stringWithFormat:@"%@", YAHOO_API_SECRET] andTokenSecret:oauthTokenSecret] URLEncodedString];
	
	
	NSLog(@"baseUrl: GET&%@", baseUrl);
	NSLog(@"baseData: %@", baseData);
	NSLog(@"encodeBaseData: %@", encodeBaseData);
	
	
	//NSURL *url = [NSURL URLWithString:@"http://wretch.yahooapis.com/v1.2/siteAlbumCategories?format=json"];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?format=json&%@", baseUrl, self.parameters]];
	ASIHTTPRequest *apiRequest = [ASIHTTPRequest requestWithURL:url];
	apiRequest.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"accessApi", @"type", nil];
	
	//NSMutableURLRequest *apiRequest = [NSMutableURLRequest requestWithURL:url];
	
	NSString *oauthValue = [NSString stringWithFormat:@"OAuth realm=\"yahooapis.com\", oauth_consumer_key=\"%@\", oauth_nonce=\"%@\", oauth_signature_method=\"HMAC-SHA1\", oauth_timestamp=\"%@\", oauth_token=\"%@\", oauth_version=\"1.0\", oauth_signature=\"%@\"", [NSString stringWithFormat:@"%@", YAHOO_API_KEY], timeinNSString, timeinNSString, oauthToken, encodeBaseData];
	
	NSLog(@"%@", oauthValue);
	
	//	[apiRequest setAllHTTPHeaderFields:[NSDictionary dictionaryWithObject:oauthValue forKey:@"Authorization"]];
	
	[apiRequest addRequestHeader:@"Authorization" value:oauthValue];
	[apiRequest setDelegate:self];
	[apiRequest startAsynchronous];
}
*/


#pragma mark - NSURLConnectionDelegate Methods
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseData appendData:data];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_urlResponse = response;
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection
{	
	NSString *strResponse = [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
	NSLog(@"Request Response Data: %@", strResponse);
	
	if([strResponse hasPrefix:@"\n<!"])
	{
		[self.delegate yahooClient:self needsToDisplayHTML:strResponse];
	}
	else
	{
		
		switch(self.requestType)
		{
			case REQUEST_AUTH:
			{
				NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
			
				NSArray *resultArray = [strResponse componentsSeparatedByString:@"&"];
				for(NSString *str in resultArray)
				{
					NSArray *arr = [[str URLDecodedString] componentsSeparatedByString:@"="];
					[resultDict setObject:arr[1] forKey:arr[0]];
				}
				
				self.authRequest = [[AuthRequest alloc] initWithDictionary:resultDict];
				
				[self.delegate yahooClient:self didFinishWithResults:resultDict];
				
				[self.delegate yahooClient:self needsToShowWebPage:self.authRequest.authURL withCode:self.authRequest.token];
			}
				break;
				
			case REQUEST_GAME:
			case REQUEST_LEAGUE:
			case REQUEST_STANDINGS:
			case REQUEST_SCOREBOARD:
			case REQUEST_MY_TEAM:
			case REQUEST_MY_ROSTER:
			case REQUEST_STATS:
			case REQUEST_PLAYERS:
			case REQUEST_TEAMS:
			{
				NSError *JSONError;
				
				id response = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&JSONError];
				
				NSLog(@"response: %@", response);
				
				[self.delegate yahooClient:self didFinishWithResults:response];
				
			}
				break;
				
			default:
			{
				NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
			
				NSArray *resultArray = [strResponse componentsSeparatedByString:@"&"];
				for(NSString *str in resultArray)
				{
					NSArray *arr = [str componentsSeparatedByString:@"="];
					[resultDict setObject:arr[1] forKey:arr[0]];
				}
				
				self.accessToken = [[AccessToken alloc] initWithDictionary:resultDict];
				
				[[NSUserDefaults standardUserDefaults] setObject:resultDict forKey:KEY_ACCESS_TOKEN];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[self.delegate yahooClientAuthorizationComplete:self];
			}
				break;
			
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error: %@", error);
}

/*
#pragma mark - ASIHTTPRequest Methods
- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSLog(@"request finished");
	
	NSData *data = request.responseData;
	
	NSString *response = [NSString stringWithCString:[data bytes] encoding:NSUTF8StringEncoding];
	
	NSLog(@"Response: %@", response);
	
	if([response hasPrefix:@"\n<!"])
	{
		[self.delegate yahooClient:self needsToDisplayHTML:response];
	}
	
	if([[request.userInfo valueForKey:@"type"] isEqualToString:PRE_APPROVED_TOKEN_STRING])
	{
		NSString *regEx = @"RequestToken=(.*)+";
		NSString *match = [response stringByMatching:regEx];
		if ([match isEqual:@""] == NO)
		{
			NSString *requestToken = [match stringByReplacingOccurrencesOfRegex:@"RequestToken=" withString:@""];
			NSLog(@"requestToken: %@", requestToken);
			
			NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
			NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];
			NSLog(@"timeStamp: %@", timeinNSString);
			
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:timeinNSString forKey:@"timeStamp"];
			[defaults synchronize];
			
			NSString* escapedUrlString = [NSString stringWithFormat:@"%@&", YAHOO_API_SECRET];
			
			NSLog(@"escapedUrlString: %@", escapedUrlString);
			
			//
			NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_token"];
			ASIFormDataRequest *getTokenRequest = [ASIFormDataRequest requestWithURL:url];
			getTokenRequest.userInfo = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"getToken", @"type", nil];
			[getTokenRequest setPostValue:[NSString stringWithFormat:@"%@", YAHOO_API_KEY] forKey:@"oauth_consumer_key"];
			[getTokenRequest setPostValue:@"PLAINTEXT" forKey:@"oauth_signature_method"];
			[getTokenRequest setPostValue:@"abcde" forKey:@"oauth_nonce"];
			[getTokenRequest setPostValue:timeinNSString forKey:@"oauth_timestamp"];
			[getTokenRequest setPostValue:escapedUrlString forKey:@"oauth_signature"];
			[getTokenRequest setPostValue:@"svmhhd" forKey:@"oauth_verifier"];
			[getTokenRequest setPostValue:@"1.0" forKey:@"oauth_version"];
			[getTokenRequest setPostValue:requestToken forKey:@"oauth_token"];
			[getTokenRequest setDelegate:self];
			[getTokenRequest startAsynchronous];
			
			
		} else {
			NSLog(@"Not found.");
		}
		
	}
	else if ([[request.userInfo valueForKey:@"type"] isEqualToString:@"getToken"]) {
		
		if (response != NULL) {
			NSString *regEx = @"\\boauth_token=([a-zA-Z0-9%_.+\\-]+)&\\b";
			NSString *oauthTokenSecretReg = @"\\boauth_token_secret=([a-zA-Z0-9%_.+\\-]+)&\\b";
			NSString *oauthSessionHandleReg = @"\\boauth_session_handle=([a-zA-Z0-9%_.+\\-]+)&\\b";
			//oauth_token
			NSString *match = [response stringByMatching:regEx];
			//oauth_token_secret
			NSString *match2 = [response stringByMatching:oauthTokenSecretReg];
			//oauth_session_handle
			NSString *match3 = [response stringByMatching:oauthSessionHandleReg];
			NSLog(@"oauthSessionHandleReg: %@", match3);
			
			if ([match isEqual:@""] == NO) {
				
				NSString *oauthToken = [match stringByReplacingOccurrencesOfRegex:@"oauth_token=" withString:@""];
				oauthToken = [oauthToken stringByReplacingOccurrencesOfRegex:@"&" withString:@""];
				NSLog(@"oauth_token: %@", oauthToken);
				
				NSString *oauthSecrect = [match2 stringByReplacingOccurrencesOfRegex:@"oauth_token_secret=" withString:@""];
				oauthSecrect = [oauthSecrect stringByReplacingOccurrencesOfRegex:@"&" withString:@""];
				NSLog(@"oauthSecrect: %@", oauthSecrect);
				
				NSString *oauthSessionHandle = [match3 stringByReplacingOccurrencesOfRegex:@"oauth_session_handle=" withString:@""];
				oauthSessionHandle = [oauthSessionHandle stringByReplacingOccurrencesOfRegex:@"&" withString:@""];
				NSLog(@"oauthSessionHandle: %@", oauthSessionHandle);
				
				NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
				[defaults setObject:oauthToken forKey:@"oauth_token"];
				[defaults setObject:oauthSecrect forKey:@"oauth_token_secret"];
				[defaults setObject:oauthSessionHandle forKey:@"oauth_session_handle"];
				[defaults synchronize];
				
				if (self.onlyGetToken == NO)
				{
					[self requestApiWithOauthToken:oauthToken withOauthTokenSecret:oauthSecrect];
				}
				
			}
		}
		else
		{
			[self initAccessToken];
			
		}
		
		
	}
	else if ([[request.userInfo valueForKey:@"type"] isEqualToString:@"accessApi"])
	{
		NSArray *jsonDict = [response JSONValue];
		
		[self.delegate yahooClient:self didFinishWithResults:jsonDict];
		//NSLog(@"%@", jsonDict);
		
	}
}
*/
- (void)requestStarted
{
	
}

// Called when a request receives response headers, lets the delegate know via didReceiveResponseHeadersSelector
- (void)requestReceivedResponseHeaders:(NSDictionary *)newHeaders
{
	
}

// Called when a request completes successfully, lets the delegate know via didFinishSelector
- (void)requestFinished
{
	
}

// Called when a request fails, and lets the delegate know via didFailSelector
- (void)failWithError:(NSError *)theError
{
	
}


@end

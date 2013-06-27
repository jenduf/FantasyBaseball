//
//  ServiceManager.h
//
//  Created by Jennifer Duffey on 11/6/11.
//  Copyright (c) 2011 Trivie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/message.h>
#import "ServerRequest.h"

@class Round, RequestData, FormInfo, QuestionResults, ChatMessage;
@interface ServiceManager : NSObject <UIAlertViewDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSObject *callbackObject;
@property (nonatomic, assign) int httpStatusCode;
@property (nonatomic, strong) RequestData *currentRequest;
@property (nonatomic, strong) NSMutableArray *cachedRequests;
@property (nonatomic, assign) BOOL requestsInQueue, needsAuthentication, updateAvailable, siteOffline;
@property (nonatomic, strong) NSString *serverURL;
@property (nonatomic, strong) NSString *updateURL;
@property (nonatomic, strong) NSString *updateMessage;
@property (nonatomic) SEL successSelector;
@property (nonatomic) SEL errorSelector;
@property (nonatomic, strong) NSString *serverProtocol;

- (void) issueRequest:(ServerRequest*)_request;
- (void) issueRequest:(ServerRequest*)_request withTimeout:(NSUInteger)_timeout;
- (NSURLCredential*) getCredentials;
+ (BOOL)requestUpdateAvailable;
- (void) switchToProtocol:(NSString*)_protocol;
- (void)cancelRequestByType:(RequestType)type;

#pragma mark LOGIN/REGISTRATION
- (void) requestLoginWithFormData:(NSDictionary *)_formData onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestSendDeviceToken:(NSString *)_token onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestRegistrationWithFormData:(NSDictionary *)_formData onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestCheckFacebookCredentialsWithToken:(NSString*)_token onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestRegisterWithFacebookToken:(NSString*)_token andUsername:(NSString*)_username onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestLinkAccountWithFacebookToken:(NSString*)_token onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestSetGameCenterID:(NSString*)_gcID andAlias:(NSString*)_alias onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void) requestSendClientOrigin:(NSString*)_origin onCallbackTarget:(NSObject*)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;

#pragma mark AVATARS
- (void)requestGetAvatarListWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSelectAvatarID:(int)avatarID withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestPurchaseAvatarSet:(int)avatarSetID withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;

#pragma mark MAIN MENU
- (void)requestMatchesWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;

#pragma mark MATCH MAKING
- (void)requestMatchmakingWithQuestionFilterID:(int)_qID onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestFirstTimeMatchmakingWithQuestionFilterID:(int)_qID onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSearchForUser:(NSString*)_username onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSearchForEmails:(NSArray*)_emails onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSearchForFacebookIDs:(NSArray*)_ids onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSearchForGameCenterIDs:(NSArray*)_ids onCallbackTarget:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestCategoryTreeWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
// DEPRECATED - TO BE DELETED
- (void)requestAvailableCategoriesWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestAvailableSubCategoriesForCategoryName:(NSString *)catName withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestAvailablePacksForCategoryName:(NSString *)catName andSubCategoryName:(NSString *)subCatName withCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
// END DEPRECATED

#pragma mark USER PROFILE
- (void)requestUserStatsWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestLogoutWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;

#pragma mark CHAT
- (void)requestChatMessagesForMatchID:(NSString*)_matchID andCallback:(id)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSendChatMessage:(ChatMessage *)_message withCallback:(id)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;

#pragma mark GAMEPLAY
- (void)requestStartMatchWithUsername:(NSString *)_challengee andQuestionFilterID:(int)qID isFriend:(BOOL)_isFriend onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestStartFirstMatchWithUsername:(NSString*)_challengee andQuestionFilterID:(int)qID isFriend:(BOOL)_isFriend onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestRespondToMatchID:(NSString*)_matchID accept:(BOOL)_accepted andQuestionFilterID:(int)_qID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSendRoundResults:(NSArray *)_results andWager:(NSInteger)_wager forMatchID:(NSString*)matchID withPowerUp:(int)_powerup onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSendRecoveredGame:(NSDictionary *)_results onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestResumeMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestResumeMatchID:(NSString*)_matchID withWager:(NSInteger)_wager onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestFinalResultsForMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestDetailforMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestSendWager:(NSInteger)_wager forMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
// DEPRECATED - TO BE DELETED
- (void)requestResultsFromRound:(int)_roundNumber forMatchID:(NSString*)_matchID onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
// DEPRECATED - TO BE DELETED

#pragma mark TOKENS
- (void)requestConsumeTokens:(int)_tokenAmount onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestValidateTokenPurchase:(int)_tokenAmount withReceipt:(NSData*)_receipt onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestTokenDenominationsWithCallback:(NSObject *)_target andSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestTokenInfoForCurrentUserWithCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;
- (void)requestValidatePaidUpgradeWithReceipt:(NSData*)_receipt onCallbackTarget:(NSObject *)_target withSuccessSelector:(SEL)_successSel andErrorSelector:(SEL)_errorSel;

#pragma mark PREMIUM STORE
- (void)requestPremiumStoreInfoWithCallback:(NSObject *)target successSelector:(SEL)successSel andErrorSelector:(SEL)errorSel;
- (void)requestValidatePremiumPurchaseForPackID:(int)packID withReceipt:(NSData *)receipt onCallbackTarget:(NSObject *)target withSuccessSelector:(SEL)successSel andErrorSelector:(SEL)errorSel;
- (void)requestGetPremiumPurchasesWithCallback:(NSObject *)target successSelector:(SEL)successSel andErrorSelector:(SEL)errorSel;

#pragma mark CLASS METHODS
+ (ServiceManager *)sharedInstance;
+ (void)requestSetNewServerURL:(int)index;

#pragma mark ----LEGACY STUFF----
+ (NSString *)getCurrentUserName;
+ (NSString *)getCurrentPassword;
+ (void)setCurrentUser:(Player *)user;
+ (UIImage *)getUserImage;
+ (void)uploadUserImage:(UIImage *)image;

@end

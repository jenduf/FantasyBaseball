//
//  YahooClient.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/24/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//


@protocol YahooClientDelegate;

@class AuthRequest, AccessToken;
@interface YahooClient : NSObject
<NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURLRequest *urlRequest;
@property (nonatomic, strong) NSURLConnection *urlConnection;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSURLResponse *urlResponse;
@property (nonatomic, strong) NSString *token, *parameters;
@property (nonatomic, strong) NSDictionary *userInfo;
@property (nonatomic, strong) NSString *apiURL;
@property (nonatomic, strong) AuthRequest *authRequest;
@property (nonatomic, strong) AccessToken *accessToken;
@property (nonatomic, strong) NSString *verifier, *sessionHandle;
@property (nonatomic, assign) RequestType requestType;

@property (nonatomic, weak) id <YahooClientDelegate> delegate;

//- (void)getGame;

+ (YahooClient *)sharedClient;
- (id)initWithAPIURL:(NSString *)url withParameters:(NSString *)parameters;

- (void)startRequestWithDelegate:(id)del;

- (void)requestAccessTokenWithVerifier:(NSString *)verifier;

- (void)getGame;
- (void)getLeague;
- (void)getScoreboard;
- (void)getStandings;
- (void)getPlayers;
- (void)getMyTeam;
- (void)getMyRoster;
- (void)getStats;
- (void)getTeams;
- (void)editRoster;

@end


@protocol YahooClientDelegate <NSObject>

@optional
- (void)yahooClient:(YahooClient *)client didFailWithError:(NSError *)error;
- (void)yahooClient:(YahooClient *)client needsToDisplayHTML:(NSString *)htmlString;
- (void)yahooClient:(YahooClient *)client didFinishWithResults:(id)results;
- (void)yahooClient:(YahooClient *)client needsToShowWebPage:(NSString *)url withCode:(NSString *)code;
- (void)yahooClientAuthorizationComplete:(YahooClient *)client;

@end
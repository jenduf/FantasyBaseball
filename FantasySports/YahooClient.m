//
//  YahooClient.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "YahooClient.h"
#import "AccessToken.h"
#import "AuthRequest.h"
#import "League.h"
#import "NSString+URLEncoding.h"

@interface YahooClient ()
<NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionTask *currentTask;
@property (nonatomic, strong) AccessToken *accessToken;
@property (nonatomic, strong) NSMutableData *responseData;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, strong) AuthRequest *authRequest;

@end

@implementation YahooClient

static YahooClient *sharedClient = nil;

+ (YahooClient *)sharedClient
{
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^
    {
        sharedClient = [[self alloc] init];
    });
    
    return sharedClient;
}

- (id)init
{
    self = [super init];
    
    if(self)
    {
        NSDictionary *tokenDict = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_ACCESS_TOKEN];
        
        if(tokenDict)
        {
            self.accessToken = [[AccessToken alloc] initWithDictionary:tokenDict];
        }
    }
    
    return self;
}

#pragma mark - Helpers
- (NSString *)getURLForLeagueWithString:(NSString *)initialURL
{
    League *l = [League currentLeague];
    
    NSString *appendedString = ([l.leagueID isEqualToString:@"169940"] ? @"_169940" : @"");
    
    NSString *formattedString = [NSString stringWithFormat:@"%@%@", initialURL, appendedString];
    
    return formattedString;
}

- (NSData *)dictionaryToJSON:(NSDictionary *)dict
{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    
    if(jsonData.length == 0 && error == nil)
    {
        NSLog(@"No data was returned after serialization");
    }
    else if(error != nil)
    {
        NSLog(@"An error happened = %@", error);
    }
    
    return jsonData;
}

- (id)parseJSONResponse:(NSData *)json
{
    if(!json)
    {
        return nil;
    }
    
    NSError *error = nil;
    
    id data = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingAllowFragments error:&error];
    
    if(error)
    {
        NSLog(@"JSON ERROR: %@", error);
        return nil;
    }
    
    return data;
}

- (NSData *)dictionaryToQueryString:(NSDictionary *)dict
{
    NSMutableArray *queryParameters = [[NSMutableArray alloc] init];
    
    for (NSString *aKey in [dict allKeys])
    {
        NSString *keyValuePair = [NSString stringWithFormat:@"%@=%@", aKey, dict[aKey]];
        [queryParameters addObject:keyValuePair];
    }
    
    NSString *queryString = [queryParameters componentsJoinedByString:@"&"];
    
    return [queryString dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSURLSession *)configureSession
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    return session;
}

- (void)initAccessToken
{
    NSURL *url = [NSURL URLWithString:@"https://api.login.yahoo.com/oauth/v2/get_request_token"];

    NSTimeInterval  todaysDate = [[NSDate date] timeIntervalSince1970];
    NSString *timeinNSString = [NSString stringWithFormat:@"%.0f", todaysDate];

    NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
    [parametersDict setObject:@"ce2130523f788f313f76314ed3965ea6" forKey:@"oauth_nonce"];
    [parametersDict setObject:timeinNSString forKey:@"oauth_timestamp"];
    [parametersDict setObject:YAHOO_API_KEY forKey:@"oauth_consumer_key"];
    [parametersDict setObject:YAHOO_API_SECRET forKey:@"oauth_signature"];
    [parametersDict setObject:[NSString stringWithFormat:@"PLAINTEXT"] forKey:@"oauth_signature_method"];
    [parametersDict setObject:@"http://fantasy.com/callback" forKey:@"oauth_callback"];
    [parametersDict setObject:@"1.0" forKey:@"oauth_version"];

    NSLog(@"Parameters: %@", parametersDict);

    NSData *postBody = [self dictionaryToQueryString:parametersDict];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBody];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
    {
        NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
        
        NSArray *resultArray = [strResponse componentsSeparatedByString:@"&"];
        for(NSString *str in resultArray)
        {
            NSArray *arr = [[str URLDecodedString] componentsSeparatedByString:@"="];
            [resultDict setObject:arr[1] forKey:arr[0]];
        }
        
        self.authRequest = [[AuthRequest alloc] initWithDictionary:resultDict];
        
        [self.delegate yahooClient:self needsToShowWebPage:self.authRequest.authURL withCode:self.authRequest.token];
        
    }];
}

- (void)refreshAccessToken
{
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
    
    NSData *postBody = [self dictionaryToQueryString:parametersDict];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
         
         NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         NSArray *resultArray = [strResponse componentsSeparatedByString:@"&"];
         for(NSString *str in resultArray)
         {
             NSArray *arr = [str componentsSeparatedByString:@"="];
             [resultDict setObject:arr[1] forKey:arr[0]];
         }
         
         if(resultDict)
         {
             self.accessToken = [[AccessToken alloc] initWithDictionary:resultDict];
             
             [[NSUserDefaults standardUserDefaults] setObject:resultDict forKey:KEY_ACCESS_TOKEN];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         
         [self.delegate yahooClientAuthorizationComplete:self];
         
     }];
}

- (void)requestAccessTokenWithVerifier:(NSString *)verifier
{
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
    
    NSData *postBody = [self dictionaryToQueryString:parametersDict];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postBody];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
         
         NSString *strResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
         
         NSArray *resultArray = [strResponse componentsSeparatedByString:@"&"];
         for(NSString *str in resultArray)
         {
             NSArray *arr = [str componentsSeparatedByString:@"="];
             [resultDict setObject:arr[1] forKey:arr[0]];
         }
         
         if(resultDict)
         {
             self.accessToken = [[AccessToken alloc] initWithDictionary:resultDict];
         
             [[NSUserDefaults standardUserDefaults] setObject:resultDict forKey:KEY_ACCESS_TOKEN];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }
         
         [self.delegate yahooClientAuthorizationComplete:self];
         
     }];
}

- (void)getTokenWithDelegate:(id)del
{
    self.delegate = del;
    
    if(self.accessToken)
    {
        [self refreshAccessToken];
    }
    else
    {
        [self initAccessToken];
    }
}

- (void)getLeagueWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeLeague;
    
    NSString *leagueURL = [NSString stringWithFormat:@"%@get_leagues?format=json", QUERY_URL];
    
    [self startRequestWithURL:[NSURL URLWithString:leagueURL] andHTTPType:HttpTypePost];
}

- (void)getGameWithDelegate:(id)del
{
    self.delegate = del;

    self.requestType = RequestTypeGame;
    
    NSString *gameURL = [NSString stringWithFormat:@"%@getGame?format=json", QUERY_URL];
    
    [self startRequestWithURL:[NSURL URLWithString:gameURL] andHTTPType:HttpTypePost];
}

- (void)getRosterWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeMyRoster;

    NSString *rosterString = [self getURLForLeagueWithString:@"get_roster"];
    
    NSString *rosterURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, rosterString];
    
    [self startRequestWithURL:[NSURL URLWithString:rosterURL] andHTTPType:HttpTypePost];
}

- (void)getStatsWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeStats;
    
    NSString *statsString = [self getURLForLeagueWithString:@"get_stats"];
    
    NSString *statsURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, statsString];
    
    [self startRequestWithURL:[NSURL URLWithString:statsURL] andHTTPType:HttpTypePost];
}

- (void)getScoreboardWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeScoreboard;
    
    NSString *scoreboardString = [self getURLForLeagueWithString:@"get_scoreboard"];
    
    NSString *scoreboardURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, scoreboardString];
    
    [self startRequestWithURL:[NSURL URLWithString:scoreboardURL] andHTTPType:HttpTypePost];
}

- (void)getTeamWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeTeam;
    
    NSString *teamString = [self getURLForLeagueWithString:@"get_team"];
    
    NSString *teamURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, teamString];
    
    [self startRequestWithURL:[NSURL URLWithString:teamURL] andHTTPType:HttpTypePost];
}

- (void)getStandingsWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeStandings;
    
    NSString *standingsString = [self getURLForLeagueWithString:@"get_standings"];
    
    NSString *standingsURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, standingsString];
    
    [self startRequestWithURL:[NSURL URLWithString:standingsURL] andHTTPType:HttpTypePost];
}

- (void)getPlayerWithID:(NSString *)playerID andDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypePlayer;
    
    NSString *playerURL = [NSString stringWithFormat:@"%@select%%20*%%20from%%20fantasysports.players%%20where%%20player_key%%3D'%@'&format=json", SPECIFIC_QUERY_URL, playerID];
    
    [self startRequestWithURL:[NSURL URLWithString:playerURL] andHTTPType:HttpTypePost];
}

- (void)getPlayersWithStart:(NSInteger)start count:(NSInteger)count sortType:(NSInteger)sortType andDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypePlayers;
    
    League *league = [League currentLeague];
    
 //   NSString *playerURL = [NSString stringWithFormat:@"%@select%%20*%%20from%%20fantasysports.players%%20where%%20league_key%%3D'%@'&start%%3D%ld&count%%3D%ld&sort_type=%ld&format=json", SPECIFIC_QUERY_URL, league.leagueKey, (long)start, (long)count, (long)sortType];
    
    NSString *playersString = [self getURLForLeagueWithString:@"get_free_agents"];
    
    NSString *playersURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, playersString];
    
    [self startRequestWithURL:[NSURL URLWithString:playersURL] andHTTPType:HttpTypePost];
}

- (void)getOwnershipWithDelegate:(id)del
{
    self.delegate = del;
    
    self.requestType = RequestTypeOwnership;
    
    NSString *ownershipString = [self getURLForLeagueWithString:@"get_ownership"];
    
    NSString *ownershipURL = [NSString stringWithFormat:@"%@%@?format=json", QUERY_URL, ownershipString];
    
    [self startRequestWithURL:[NSURL URLWithString:ownershipURL] andHTTPType:HttpTypePost];
}

- (void)startRequestWithURL:(NSURL *)url andHTTPType:(HttpType)type
{
    if(self.currentTask)
        return;
    
    if(!self.session)
        self.session = [self configureSession];
    
    NSTimeInterval todaysDate = [[NSDate date] timeIntervalSince1970];
    NSString *timeInString = [NSString stringWithFormat:@"%.0f", todaysDate];
    
    NSString *concatenatedSecret = [NSString stringWithFormat:@"%@%@", YAHOO_API_SECRET, self.accessToken.tokenSecret];
    
    NSMutableDictionary *parametersDict = [NSMutableDictionary dictionary];
    parametersDict[@"oauth_nonce"] = @"ce2130523f788f313f76314ed3965ea6";
    parametersDict[@"oauth_timestamp"] = timeInString;
    parametersDict[@"oauth_consumer_key"] = YAHOO_API_KEY;
    parametersDict[@"oauth_signature"] = concatenatedSecret;
    parametersDict[@"oauth_signature_method"] = @"PLAINTEXT";
    parametersDict[@"oauth_token"] = self.accessToken.token;
    parametersDict[@"oauth_version"] = @"1.0";
    
    NSLog(@"\n\nRequest: %@, Parameters: %@", url, parametersDict);
    
    NSData *postBody = [self dictionaryToQueryString:parametersDict];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    if(type == HttpTypePost)
    {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:postBody];
    }
    else
    {
        [request setHTTPMethod:@"GET"];
    }
    
    self.responseData = [NSMutableData data];
    
    self.currentTask = [self.session dataTaskWithRequest:request];
    
    [self.currentTask resume];
}

#pragma mark - NSURLSessionTaskDelegate Methods
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    self.responseData.length = 0;
    
    self.response = (NSHTTPURLResponse *)response;
    
    NSInteger status = [self.response statusCode];
    
    NSLog(@"Got RESPONSE: %ld", (long)status);
    
    if(status == HTTP_CODE_SUCCESS)
    {
        completionHandler(NSURLSessionResponseAllow);
    }
    else
    {
        NSLog(@"Received bad status code: %li", (long)self.response.statusCode);
    }
    
    self.currentTask = nil;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    [self.responseData appendData:data];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    NSLog(@"completed; error: %@", error);
    
    self.currentTask = nil;
    
    if(error)
    {
        NSLog(@"Error: %@", error.localizedDescription);
    }
    else
    {
        NSString *str = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"\n\nRESPONSE: %@", str);
        
        id jsonData = [self parseJSONResponse:self.responseData];
        
        [self.delegate yahooClient:self didReturnData:jsonData];
    }
}

@end

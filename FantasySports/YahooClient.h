//
//  YahooClient.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YahooClientDelegate;

@interface YahooClient : NSObject

@property (nonatomic, assign) RequestType requestType;
@property (nonatomic, assign) id <YahooClientDelegate> delegate;

+ (YahooClient *)sharedClient;

- (void)getTokenWithDelegate:(id)del;
- (void)requestAccessTokenWithVerifier:(NSString *)verifier;
- (void)getLeagueWithDelegate:(id)del;
- (void)getGameWithDelegate:(id)del;
- (void)getRosterWithDelegate:(id)del;
- (void)getStatsWithDelegate:(id)del;
- (void)getScoreboardWithDelegate:(id)del;
- (void)getTeamWithDelegate:(id)del;
- (void)getStandingsWithDelegate:(id)del;
- (void)getPlayerWithID:(NSString *)playerID andDelegate:(id)del;
- (void)getPlayersWithStart:(NSInteger)start count:(NSInteger)count sortType:(NSInteger)sortType andDelegate:(id)del;
- (void)getOwnershipWithDelegate:(id)del;

@end

@protocol YahooClientDelegate

@optional
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data;
- (void)yahooClient:(YahooClient *)yahooClient needsToShowWebPage:(NSString *)webPage withCode:(NSString *)code;
- (void)yahooClientAuthorizationComplete:(YahooClient *)yahooClient;

@end

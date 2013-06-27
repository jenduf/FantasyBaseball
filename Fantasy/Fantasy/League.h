//
//  League.h
//  Fantasy
//
//  Created by Jennifer Duffey on 5/2/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface League : NSObject

@property (nonatomic, strong) NSString *editKey, *endDate, *leagueKey, *leagueUpdateDate, *name, *url;
@property (nonatomic, assign) NSInteger currentWeek, endWeek, leagueID, numberOfTeams;
@property (nonatomic, assign) BOOL isPro;

+ (League *)currentLeague;
+ (void)setCurrentLeague:(League *)league;

@end

//
//  League.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface League : NSObject

@property (nonatomic, strong) NSString *leagueKey, *leagueID, *leagueName, *leagueURL;

+ (League *)currentLeague;
+ (void)setCurrentLeague:(League *)league;

@end

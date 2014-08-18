//
//  Matchup.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Team;
@interface Matchup : NSObject

@property (nonatomic, strong) NSString *week, *status;
@property (nonatomic, strong) NSDate *weekStart, *weekEnd;
@property (nonatomic, strong) NSMutableArray *teams;

//- (void)compareTeams;

@end

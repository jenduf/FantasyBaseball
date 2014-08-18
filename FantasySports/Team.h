//
//  Team.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TeamStats;
@interface Team : NSObject

@property (nonatomic, strong) NSString *teamID, *teamKey, *teamName, *managerName, *managerID;
@property (nonatomic, assign) NSInteger teamPoints, rank, wins, losses, ties, percentage, gamesBack, rosterAdds;
@property (nonatomic, strong) NSString *waiverPriority, *numberOfMoves, *numberOfTrades;
@property (nonatomic, strong) TeamStats *teamStats;

@end

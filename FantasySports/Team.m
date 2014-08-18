//
//  Team.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Team.h"
#import "TeamStats.h"

@implementation Team

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_teamID = dictionary[@"team_id"];
		_teamKey = dictionary[@"team_key"];
		_teamName = dictionary[@"name"];
        _waiverPriority = dictionary[@"waiver_priority"];
        _numberOfMoves = dictionary[@"number_of_moves"];
        _numberOfTrades = dictionary[@"number_of_trades"];
        
        NSDictionary *rosterDict = dictionary[@"roster_adds"];
        _rosterAdds = [rosterDict[@"value"] intValue];
		
		NSDictionary *managersDict = dictionary[@"managers"];
		NSDictionary *managerDict = managersDict[@"manager"];
		
		_managerName = managerDict[@"nickname"];
		
		_managerID = managerDict[@"manager_id"];
		
		NSDictionary *pointsDict = dictionary[@"team_points"];
		_teamPoints = [pointsDict[@"total"] intValue];
        
        _teamStats = [[TeamStats alloc] initWithDictionary:dictionary[@"team_stats"]];
        
        NSDictionary *standings = dictionary[@"team_standings"];
        _rank = [standings[@"rank"] intValue];
        
        NSDictionary *totals = standings[@"outcome_totals"];
        _wins = [totals[@"wins"] intValue];
        _losses = [totals[@"losses"] intValue];
        _ties = [totals[@"ties"] intValue];
        _percentage = [totals[@"percentage"] intValue];
        _gamesBack = [standings[@"games_back"] intValue];
	}
	
	return self;
}

@end

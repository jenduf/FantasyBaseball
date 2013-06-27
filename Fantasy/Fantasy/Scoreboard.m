//
//  Scoreboard.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/26/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Scoreboard.h"
#import "Team.h"

@implementation Scoreboard

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_currentWeek = [dictionary[@"week"] intValue];
		
		_matchups = [[NSMutableArray alloc] init];
		
		NSDictionary *matchupDict = dictionary[@"matchups"];
		NSArray *matchupArray = matchupDict[@"matchup"];
		
		for(NSDictionary *dict in matchupArray)
		{
			NSDictionary *teamsDict = dict[@"teams"];
			
			NSArray *teamArray = teamsDict[@"team"];
			
			NSMutableArray *teams = [NSMutableArray array];
			
			for(NSDictionary *d in teamArray)
			{
				Team *team = [[Team alloc] initWithDictionary:d];
				[teams addObject:team];
			}
			
			[_matchups addObject:teams];
		}
	}
	
	return self;
}

@end

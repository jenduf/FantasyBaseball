//
//  Scoreboard.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/26/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Scoreboard.h"
#import "Team.h"
#import "Matchup.h"

@implementation Scoreboard

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_currentWeek = [dictionary[@"week"] intValue];

		NSDictionary *matchupDict = dictionary[@"matchups"];
		NSArray *matchupArray = matchupDict[@"matchup"];
		
        _matchups = [[NSArray alloc] initWithArray:[self getMatchupsFromArray:matchupArray]];
	}
	
	return self;
}

- (NSArray *)getMatchupsFromArray:(NSArray *)matchupArray
{
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for(NSDictionary *dict in matchupArray)
    {
        Matchup *matchup = [[Matchup alloc] initWithDictionary:dict];
        
        [returnArray addObject:matchup];
    }
    
    return returnArray;
}

@end

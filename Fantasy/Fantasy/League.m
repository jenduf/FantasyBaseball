//
//  League.m
//  Fantasy
//
//  Created by Jennifer Duffey on 5/2/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "League.h"

static League *currentLeague;

@implementation League

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super initWithDictionary:dictionary];
	
	if(self)
	{
		_currentWeek = [dictionary[@"current_week"] intValue];
		_editKey = dictionary[@"edit_key"];
		_endDate = dictionary[@"end_date"];
		_endWeek = [dictionary[@"end_week"] intValue];
		_isPro = [dictionary[@"is_pro_league"] boolValue];
		_leagueID = [dictionary[@"league_id"] intValue];
		_leagueKey = dictionary[@"league_key"];
		_name = dictionary[@"name"];
		_numberOfTeams = [dictionary[@"num_teams"] intValue];
		_url = dictionary[@"url"];
	}
	
	return self;
}

+ (League *)currentLeague
{
	return currentLeague;
}

+ (void)setCurrentLeague:(League *)league
{
	currentLeague = league;
}

@end

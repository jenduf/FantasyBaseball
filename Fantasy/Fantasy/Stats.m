//
//  BatterStats.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Stats.h"

@implementation Stats

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_statID = [dictionary[@"stat_id"] intValue];
		_statValue = dictionary[@"value"];
		_statName = [self getStatNameByID:_statID];
	}
	
	return self;
}

- (NSString *)getStatNameByID:(NSInteger)statID
{
	StatID adjustedStatID = statID;
	
	switch (adjustedStatID)
	{
		case STATS_ID_ATBATS:
			return @"H/AB";
			break;
			
		case STATS_ID_RUNS:
			return @"R";
			break;
			
		case STATS_ID_HOMERUNS:
			return @"HR";
			break;
			
		case STATS_ID_RBI:
			return @"RBI";
			break;
			
		case STATS_ID_STOLEN_BASES:
			return @"SB";
			break;
			
		case STATS_ID_BATTING_AVERAGE:
			return @"AVG";
			break;
			
		case STATS_ID_INNINGS_PITCHED:
			return @"IP";
			break;
			
		case STATS_ID_WINS:
			return @"W";
			break;
			
		case STATS_ID_SAVES:
			return @"SV";
			break;
			
		case STATS_ID_STRIKEOUTS:
			return @"K";
			break;
			
		case STATS_ID_ERA:
			return @"ERA";
			break;
			
		case STATS_ID_WHIP:
			return @"WHIP";
			break;
			
		default:
			break;
	}
}

@end

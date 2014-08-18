//
//  BatterStats.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Stat.h"

@implementation Stat

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
	switch (statID)
	{
		case StatIDAB:
			return @"H/AB";
			break;
			
		case StatIDRuns:
			return @"R";
			break;
			
		case StatIDHR:
			return @"HR";
			break;
			
		case StatIDRBI:
			return @"RBI";
			break;
			
		case StatIDSB:
			return @"SB";
			break;
			
		case StatIDBA:
			return @"AVG";
			break;
			
		case StatIDIP:
			return @"IP";
			break;
			
		case StatIDWins:
			return @"W";
			break;
			
		case StatIDSaves:
			return @"SV";
			break;
			
		case StatIDK:
			return @"K";
			break;
			
		case StatIDERA:
			return @"ERA";
			break;
			
		case StatIDWhip:
			return @"WHIP";
			break;
			
		default:
			break;
	}
    
    return nil;
}

@end

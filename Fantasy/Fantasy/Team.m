//
//  Team.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Team.h"

@implementation Team

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_teamID = dictionary[@"team_id"];
		_teamKey = dictionary[@"team_key"];
		_teamName = dictionary[@"name"];
		
		NSDictionary *managersDict = dictionary[@"managers"];
		NSDictionary *managerDict = managersDict[@"manager"];
		
		_managerName = managerDict[@"nickname"];
		
		_managerID = managerDict[@"manager_id"];
		
		NSDictionary *pointsDict = dictionary[@"team_points"];
		_teamPoints = [pointsDict[@"total"] intValue];
	}
	
	return self;
}

@end

//
//  League.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "League.h"

@implementation League

static League *currentLeague;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self)
    {
        _leagueKey = dictionary[@"league_key"];
        _leagueID = dictionary[@"league_id"];
        _leagueName = dictionary[@"name"];
        _leagueURL = dictionary[@"url"];
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

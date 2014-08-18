//
//  Matchup.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "Matchup.h"
#import "Team.h"
#import "Stat.h"
#import "TeamStats.h"

@implementation Matchup

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self)
    {
        _week = dictionary[@"week"];
        _weekStart = [Utils dateFromString:dictionary[@"week_start"] withFormat:DATE_FORMAT_STRING];
        _weekEnd = [Utils dateFromString:dictionary[@"week_end"] withFormat:DATE_FORMAT_STRING];
        
        NSDictionary *teamsDict = dictionary[@"teams"];
        
        _teams = [[NSMutableArray alloc] initWithArray:[self getTeamsFromArray:teamsDict[@"team"]]];
        
        [self compareTeams];
        
    }
    
    return self;
}

- (NSArray *)getTeamsFromArray:(NSArray *)teamsArray
{
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for(NSDictionary *dict in teamsArray)
    {
        Team *team = [[Team alloc] initWithDictionary:dict];
        [returnArray addObject:team];
    }
    
    return returnArray;
}

- (void)compareTeams
{
    Team *team1 = self.teams[0];
    Team *team2 = self.teams[1];
    
    NSInteger total = team1.teamStats.stats.count;
    
    for(NSInteger i = 0; i < total; i++)
    {
        Stat *stat = team1.teamStats.stats[i];
        Stat *statCompare = team2.teamStats.stats[i];
        
        if(stat.statID != StatIDERA && stat.statID != StatIDWhip)
        {
            if([stat.statValue doubleValue] > [statCompare.statValue doubleValue])
            {
                stat.winning = YES;
            }
            else
            {
                statCompare.winning = YES;
            }
        }
        else
        {
            if([stat.statValue doubleValue] < [statCompare.statValue doubleValue])
            {
                stat.winning = YES;
            }
            else
            {
                statCompare.winning = YES;
            }
        }
    }
}

@end

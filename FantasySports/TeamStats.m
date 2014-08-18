//
//  TeamStats.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "TeamStats.h"
#import "Stat.h"

@implementation TeamStats

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    
    if(self)
    {
        _coverageType = dictionary[@"coverage_type"];
        _week = dictionary[@"week"];
        
        NSDictionary *statDict = dictionary[@"stats"];
        _stats = [[NSArray alloc] initWithArray:[self getStatsFromArray:statDict[@"stat"]]];
    }
    
    return self;
}

- (NSArray *)getStatsFromArray:(NSArray *)statsArray
{
    NSMutableArray *returnArray = [NSMutableArray array];
    
    for(NSDictionary *dict in statsArray)
    {
        Stat *stat = [[Stat alloc] initWithDictionary:dict];
        [returnArray addObject:stat];
    }
    
    return returnArray;
}


- (NSMutableArray *)getParticularStats
{
    NSMutableArray *filteredArray = [NSMutableArray array];
    
    for(Stat *stat in self.stats)
    {
        if(!(stat.statID == StatIDAB || stat.statID == StatIDIP))
        {
            [filteredArray addObject:stat];
        }
    }
    
    return filteredArray;
}

@end

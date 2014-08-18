//
//  Utils.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "Utils.h"

@implementation Utils

+ (NSDate *)dateFromString:(NSString *)str withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    
    return [formatter dateFromString:str];
}

+ (NSString *)getStatStringForBatterStatIndex:(BatterStatIndex)index
{
    NSString *batterStatString = nil;
    
    switch(index)
    {
        case BatterStatIndexAB:
            batterStatString = @"H/AB";
            break;
            
        case BatterStatIndexR:
            batterStatString = @"R";
            break;
            
        case BatterStatIndexHR:
            batterStatString = @"HR";
            break;
            
        case BatterStatIndexRBI:
            batterStatString = @"RBI";
            break;
            
        case BatterStatIndexSB:
            batterStatString = @"SB";
            break;
            
        case BatterStatIndexAVG:
            batterStatString = @"AVG";
            break;
            
    }
    
    return batterStatString;
}

+ (NSString *)getStatStringForPitcherStatIndex:(PitcherStatIndex)index
{
    NSString *pitcherStatString = nil;
    
    switch(index)
    {
        case PitcherStatIndexIP:
            pitcherStatString = @"IP";
            break;
            
        case PitcherStatIndexW:
            pitcherStatString = @"W";
            break;
            
        case PitcherStatIndexSV:
            pitcherStatString = @"SV";
            break;
            
        case PitcherStatIndexK:
            pitcherStatString = @"K";
            break;
            
        case PitcherStatIndexERA:
            pitcherStatString = @"ERA";
            break;
            
        case PitcherStatIndexWHIP:
            pitcherStatString = @"WHIP";
            break;
            
    }
    
    return pitcherStatString;
}

@end

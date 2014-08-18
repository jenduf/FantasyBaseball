//
//  Utils.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (NSString *)getStatStringForBatterStatIndex:(BatterStatIndex)index;
+ (NSString *)getStatStringForPitcherStatIndex:(PitcherStatIndex)index;
+ (NSDate *)dateFromString:(NSString *)str withFormat:(NSString *)format;

@end

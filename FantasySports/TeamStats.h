//
//  TeamStats.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamStats : NSObject

@property (nonatomic, strong) NSString *coverageType, *week;
@property (nonatomic, strong) NSArray *stats;

- (NSMutableArray *)getParticularStats;

@end

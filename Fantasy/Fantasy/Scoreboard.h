//
//  Scoreboard.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/26/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Scoreboard : NSObject

@property (nonatomic, assign) NSInteger currentWeek;
@property (nonatomic, strong) NSMutableArray *matchups;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

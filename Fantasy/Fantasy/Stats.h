//
//  BatterStats.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stats : NSObject

@property (nonatomic, assign) NSInteger statID;
@property (nonatomic, strong) NSString *statValue, *statName;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

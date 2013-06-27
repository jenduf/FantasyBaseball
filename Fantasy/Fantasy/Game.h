//
//  Game.h
//  Fantasy
//
//  Created by Jennifer Duffey on 5/2/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Game : NSObject


@property (nonatomic, strong) NSString *code, *gameKey, *name, *url;
@property (nonatomic, assign) NSInteger gameID, season;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (Game *)currentGame;
+ (void)setCurrentGame:(Game *)game;

@end

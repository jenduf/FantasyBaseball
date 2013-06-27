//
//  Game.m
//  Fantasy
//
//  Created by Jennifer Duffey on 5/2/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Game.h"

@implementation Game

static Game *currentGame;

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_code = dictionary[@"code"];
		_gameID = [dictionary[@"game_id"] intValue];
		_gameKey = dictionary[@"game_key"];
		_name = dictionary[@"name"];
		_season = [dictionary[@"season"] intValue];
		_url = dictionary[@"url"];
	}
	
	return self;
}

+ (Game *)currentGame
{
	return currentGame;
}

+ (void)setCurrentGame:(Game *)game
{
	currentGame = game;
}

@end

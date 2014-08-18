//
//  Player.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "Player.h"

@implementation Player

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_playerKey = dictionary[@"player_key"];
		_playerID = dictionary[@"player_id"];
        
        NSDictionary *ownershipDict = dictionary[@"ownership"];
        _ownershipType = ownershipDict[@"ownership_type"];
		
		NSDictionary *nameDict = dictionary[@"name"];
		_firstName = nameDict[@"first"];
		_lastName = nameDict[@"last"];
		_fullName = nameDict[@"full"];
		
		_teamName = dictionary[@"editorial_team_full_name"];
		_teamNameShort = dictionary[@"editorial_team_abbr"];
		
		_uniformNumber = [dictionary[@"uniform_number"] intValue];
		_position = dictionary[@"display_position"];
		
		NSDictionary *positionDict = dictionary[@"selected_position"];
		_activePosition = positionDict[@"position"];
		
		_positionType = dictionary[@"position_type"];
		
		NSDictionary *headShotDict = dictionary[@"headshot"];
		_headshotURL = headShotDict[@"url"];
		_imageURL = dictionary[@"image_url"];
		
		_isUndroppable = [dictionary[@"is_undroppable"] boolValue];
		_hasPlayerNotes = [dictionary[@"has_player_notes"] boolValue];
		_hasRecentPlayerNotes = [dictionary[@"has_recent_player_notes"] boolValue];
		
		NSDictionary *startStatusDict = dictionary[@"starting_status"];
		_startingStatus = (![startStatusDict[@"is_starting"] boolValue]);
		
	}
	
	return self;
}

@end

//
//  Player.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stats;
@interface Player : NSObject

@property (nonatomic, strong) NSString *playerKey, *playerID, *position, *activePosition, *positionType;
@property (nonatomic, strong) NSString *firstName, *lastName, *fullName;
@property (nonatomic, strong) NSString *teamName, *teamNameShort;
@property (nonatomic, assign) NSInteger uniformNumber;
@property (nonatomic, strong) NSString *headshotURL, *imageURL;
@property (nonatomic, assign) BOOL isUndroppable;
@property (nonatomic, assign) BOOL startingStatus;
@property (nonatomic, assign) BOOL hasPlayerNotes, hasRecentPlayerNotes;
@property (nonatomic, strong) NSDictionary *stats;
@property (nonatomic, assign) OwnershipType ownershipType;

- (id)initWithDictionary:(NSDictionary *)dictionary;


@end

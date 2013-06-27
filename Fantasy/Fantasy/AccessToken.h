//
//  AccessToken.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccessToken : NSObject

@property (nonatomic, strong) NSString *token, *tokenSecret, *sessionHandle, *sessionGUID;

@property (nonatomic, assign) NSInteger tokenExpireInterval, sessionExpireInterval;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryFromAccessToken;

@end

//
//  AccessToken.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "AccessToken.h"

@implementation AccessToken

- (id)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	
	if(self)
	{
		_token = dictionary[@"oauth_token"];
		_tokenSecret = dictionary[@"oauth_token_secret"];
		_sessionHandle = dictionary[@"oauth_session_handle"];
		_tokenExpireInterval = [dictionary[@"oauth_expires_in"] intValue];
		_sessionExpireInterval = [dictionary[@"oauth_authorization_expires_in"] intValue];
		_sessionGUID = dictionary[@"xoauth_yahoo_guid"];
	}
	
	return self;
}

- (NSDictionary *)dictionaryFromAccessToken
{
	NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:_token, _tokenSecret, _sessionHandle, _tokenExpireInterval, _sessionExpireInterval, _sessionGUID, nil] forKeys:[NSArray arrayWithObjects:@"oauth_token", @"oauth_token_secret", @"oauth_session_handle", @"oauth_expires_in", @"oauth_authorization_expires_in", @"xoauth_yahoo_guid", nil]];
	return dictionary;
}


#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder
{
	[encoder encodeObject:self.token forKey:@"oauth_token"];
	[encoder encodeObject:self.tokenSecret forKey:@"oauth_token_secret"];
	[encoder encodeObject:self.sessionHandle forKey:@"oauth_session_handle"];
	[encoder encodeInteger:self.tokenExpireInterval forKey:@"oauth_expires_in"];
	[encoder encodeInteger:self.sessionExpireInterval forKey:@"oauth_authorization_expires_in"];
	[encoder encodeObject:self.sessionGUID forKey:@"xoauth_yahoo_guid"];
}

- (id)initWithCoder:(NSCoder *)decoder
{
	self = [super init];
	
	if(self)
	{
		self.token = [decoder decodeObjectForKey:@"oauth_token"];
		self.tokenSecret = [decoder decodeObjectForKey:@"oauth_token_secret"];
		self.sessionHandle = [decoder decodeObjectForKey:@"oauth_session_handle"];
		self.tokenExpireInterval = [decoder decodeIntForKey:@"oauth_expires_in"];
		self.sessionExpireInterval = [decoder decodeIntForKey:@"oauth_authorization_expires_in"];
		self.sessionGUID = [decoder decodeObjectForKey:@"xoauth_yahoo_guid"];
	}
	
	return self;
}


@end

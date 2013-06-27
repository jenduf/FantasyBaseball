//
//  AuthRequest.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "AuthRequest.h"

@implementation AuthRequest

- (id)initWithDictionary:(NSDictionary *)dict
{
	self = [super init];
	
	if(self)
	{
		_token = [dict objectForKey:@"oauth_token"];
		_tokenSecret = [dict objectForKey:@"oauth_token_secret"];
		_expires = [[dict valueForKey:@"oauth_expires_in"] intValue];
		_authURL = [dict objectForKey:@"xoauth_request_auth_url"];
		_callbackConfirmed = [[dict valueForKey:@"oauth_callback_confirmed"] boolValue];
	}
	
	return self;
}


@end

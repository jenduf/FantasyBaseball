//
//  OauthRequestSigner.m
//  Fantasy
//
//  Created by Jennifer Duffey on 5/19/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "OauthRequestSigner.h"

@implementation OauthRequestSigner

// sign the clear text with the secret key
+ (NSString *)signClearText:(NSString *)text withKey:(NSString *)secret
{
	NSData *secretData = STRDATA(secret);
	NSData *clearTextData = STRDATA(text);
	
	// HMAC - SHA1
	CCHmacContext hmacContext;
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
	
	// convert to a base64-encoded result
	NSData *outData = [NSData dataWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
	
	return [outData base64EncodedString];
}

+(NSString *)urlEncodedString:(NSString *)string
{
	NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)string, NULL, CFSTR(":/?#[]@!$&'()*+,;="), kCFStringEncodingUTF8);
	return result;
}

// return url-encoded signed request
+ (NSString *)signRequest:(NSString *)baseRequest withKey:(NSString *)secret
{
	NSString *signedRequest = [OauthRequestSigner signClearText:baseRequest withKey:secret];
	NSString *encodedRequest = [OauthRequestSigner urlEncodedString:signedRequest];
	
	return encodedRequest;
}

// return a nonce (random value
+ (NSString *)oauthNonce
{
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	NSString *nonceString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return nonceString;
}

// build a token dictionary from a key=value&key=value string
+ (NSDictionary *)dictionaryFromParameterString:(NSString *)resultString
{
	if(!resultString)
		return nil;
	
	NSMutableDictionary *tokens = [NSMutableDictionary dictionary];
	NSArray *pairs = [resultString componentsSeparatedByString:@"&"];
	
	for(NSString *pairString in pairs)
	{
		NSArray *pair = [pairString componentsSeparatedByString:@"="];
		
		if(pair.count != 2)
			continue;
		
		tokens[pair[0]] = pair[1];
	}
	
	return tokens;
}

// build a string from an oauth dictionary
+ (NSString *)parameterStringFromDictionary:(NSDictionary *)dict
{
	NSMutableString *outString = [NSMutableString string];
	
	// sort keys
	NSMutableArray *keys = [NSMutableArray arrayWithArray:[dict allKeys]];
	[keys sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	// add sorted items to parameter string
	for(int i = 0; i < keys.count; i++)
	{
		NSString *key = keys[i];
		[outString appendFormat:@"%@=%@", key, dict[key]];
		if(i < (keys.count - 1))
		{
			[outString appendString:@"&"];
		}
	}
	
	return outString;
}

// create a base oauth header dictionary
+ (NSMutableDictionary *)oauthBaseDictionary:(NSString *)consumerKey
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	dict[@"oauth_consumer_key"] = consumerKey;
	dict[@"oauth_nonce"] = [OauthRequestSigner oauthNonce];
	dict[@"oauth_signature_method"] = @"HMAC-SHA1";
	dict[@"oauth_timestamp"] = [NSString stringWithFormat:@"%d", (int)time(0)];
	dict[@"oauth_version"] = @"1.0";
	return dict;
}

+ (NSMutableString *)baseRequestWithEndpoint:(NSString *)endPoint dictionary:(NSDictionary *)dict andRequestMethod:(NSString *)method
{
	NSMutableString *baseRequest = [NSMutableString string];
	NSString *encodedEndPoint = [OauthRequestSigner urlEncodedString:endPoint];
	[baseRequest appendString:[NSString stringWithFormat:@"%@&%@&", method, encodedEndPoint]];
	NSString *parameterString = [OauthRequestSigner parameterStringFromDictionary:dict];
	NSString *encodedParameterString = [OauthRequestSigner urlEncodedString:parameterString];
	[baseRequest appendString:encodedParameterString];
	return baseRequest;
}

@end

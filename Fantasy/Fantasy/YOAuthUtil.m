//
//  YOAuthUtil.m
//  YOAuth
//
//  Created by Zach Graves on 2/14/09.
//  Copyright (c) 2009 Yahoo! Inc. All rights reserved.
//  
//  The copyrights embodied in the content of this file are licensed under the BSD (revised) open source license.
//

#import "YOAuthUtil.h"
#include "Base64Transcoder.h"
#import "GTMBase64.h"
#import <CommonCrypto/CommonHMAC.h>

static NSString *const kOAuthVersion= @"1.0";

NSInteger SortParameter(NSString *key1, NSString *key2, void *context)
{
	NSComparisonResult r = [key1 compare:key2];
	
	if(r == NSOrderedSame)
	{
		NSDictionary *dict = (__bridge NSDictionary *)context;
		NSString *value1 = [dict objectForKey:key1];
		NSString *value2 = [dict objectForKey:key2];
		return [value1 compare:value2];
	}
	
	return r;
}

@implementation YOAuthUtil

+ (NSString *)oauth_nonce
{	
	NSString *nonce = nil;
	CFUUIDRef generatedUUID = CFUUIDCreate(kCFAllocatorDefault);
	nonce = (NSString*)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, generatedUUID));
	CFRelease(generatedUUID);
	
	return nonce;
}

+ (NSString *)oauth_timestamp
{
	return [NSString stringWithFormat:@"%ld", time(NULL)];
}

+ (NSString *)oauth_version
{
	return kOAuthVersion;
}

+ (NSString *)buildSignatureWithRequest:(NSString *)aSignableString andSecrets:(NSString *)aSecret
{
	NSData *secretData = [aSecret dataUsingEncoding:NSUTF8StringEncoding];
	NSData *clearTextData = [aSignableString dataUsingEncoding:NSUTF8StringEncoding];
	
	uint8_t digest[CC_SHA1_DIGEST_LENGTH] = {0};
	
	CCHmacContext hmacContext;
	CCHmacInit(&hmacContext, kCCHmacAlgSHA1, secretData.bytes, secretData.length);
	CCHmacUpdate(&hmacContext, clearTextData.bytes, clearTextData.length);
	CCHmacFinal(&hmacContext, digest);
	
	//Base64 Encoding
	char base64Result[32];
	size_t theResultLength = 32;
	UVBase64EncodeData(digest, CC_SHA1_DIGEST_LENGTH, base64Result, &theResultLength);
	NSData *theData = [NSData dataWithBytes:base64Result length:theResultLength];
	
	NSString *base64EncodedResult = [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
	
	return base64EncodedResult;
}

+ (NSString *)urlencodeWithUTF8:(NSString *)string
{
	NSString *escaped = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, nil, CFSTR("!*'();:@&=+$,/?%#[]"), kCFStringEncodingUTF8));
	return escaped;
}

+ (NSString *)GUID
{
	CFUUIDRef u = CFUUIDCreate(kCFAllocatorDefault);
	CFStringRef s = CFUUIDCreateString(kCFAllocatorDefault, u);
	NSString *result = [(__bridge NSString *)s stringByReplacingOccurrencesOfString:@"-" withString:@""];
	CFRelease(u);
	CFRelease(s);
	
	return result;
}

+ (NSData *)hmacSHA1WithString:(NSString *)value key:(NSString *)key
{
	unsigned char buf[CC_SHA1_DIGEST_LENGTH];
	CCHmac(kCCHmacAlgSHA1, [key UTF8String], [key length], [value UTF8String], [value length], buf);
	
	return [NSData dataWithBytes:buf length:CC_SHA1_DIGEST_LENGTH];
}

+ (NSString *)queryStringWithURL:(NSURL *)url method:(NSString *)method parameters:(NSDictionary *)parameters consumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret token:(NSString *)token tokenSecret:(NSString *)tokenSecret
{
	NSString *nonce = [YOAuthUtil GUID];
	NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
	NSString *sigMethod = @"HMAC-SHA1";
	NSString *version = @"1.0";
	
	NSMutableDictionary *authParameters = [NSMutableDictionary dictionary];
	[authParameters setObject:nonce forKey:@"oauth_nonce"];
	[authParameters setObject:timestamp forKey:@"oauth_timestamp"];
	[authParameters setObject:sigMethod forKey:@"oauth_signature_method"];
	[authParameters setObject:version forKey:@"oauth_version"];
	[authParameters setObject:consumerKey forKey:@"oauth_consumer_key"];
	
	if(token)
		[authParameters setObject:token forKey:@"oauth_token"];
	
	if(parameters)
		[authParameters addEntriesFromDictionary:parameters];
	
	for(NSString *key in [authParameters allKeys])
	{
		NSString *value = [authParameters objectForKey:key];
		[authParameters setObject:[YOAuthUtil urlencodeWithUTF8:value] forKey:key];
	}
	
	NSArray *sortedKeys = [[authParameters allKeys] sortedArrayUsingFunction:SortParameter context:(__bridge void *)(authParameters)];
	
	NSMutableArray *parameterArray = [NSMutableArray array];
	
	for(NSString *key in sortedKeys)
	{
		[parameterArray addObject:[NSString stringWithFormat:@"%@=%@", key, [authParameters objectForKey:key]]];
	}
	
	NSString *normalizedParameterString = [parameterArray componentsJoinedByString:@"&"];
	
	NSString *signatureBaseString = [NSString stringWithFormat:@"%@&%@&%@", method, [YOAuthUtil urlencodeWithUTF8:[url description]], [YOAuthUtil urlencodeWithUTF8:normalizedParameterString]];
	
	NSLog(@"signatureBaseString=%@", signatureBaseString);
	
	NSString *key = [NSString stringWithFormat:@"%@&%@", consumerSecret, nil == tokenSecret ? @"" : tokenSecret];
	
	NSLog(@"key=%@", key);
	
	NSData *signature = [YOAuthUtil hmacSHA1WithString:signatureBaseString key:key];
	NSString *base64Sig = [GTMBase64 stringByEncodingData:signature];
	
	NSLog(@"base64Signature=%@", base64Sig);
	
	[authParameters setObject:[YOAuthUtil urlencodeWithUTF8:base64Sig] forKey:@"oauth_signature"];
	
	NSMutableArray *queryItems = [NSMutableArray array];
	for(NSString *key in authParameters)
	{
		NSString *value = [authParameters objectForKey:key];
		[queryItems addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
	}
	
	return [queryItems componentsJoinedByString:@"&"];
}

@end

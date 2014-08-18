//
//  AuthRequest.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthRequest : NSObject

@property (nonatomic, strong) NSString *token, *tokenSecret, *authURL;
@property (nonatomic, assign) NSInteger expires;
@property (nonatomic, assign) BOOL callbackConfirmed;

@end

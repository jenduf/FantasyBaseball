//
//  StatLayoutAttributes.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StatLayoutAttributes.h"

@implementation StatLayoutAttributes

- (id)copyWithZone:(NSZone *)zone
{
    StatLayoutAttributes *attributes = [super copyWithZone:zone];
    
    attributes.layoutMode = self.layoutMode;
    
    return attributes;
}

- (BOOL)isEqual:(id)object
{
    return [super isEqual:object] && (self.layoutMode == [object layoutMode]);
}

@end

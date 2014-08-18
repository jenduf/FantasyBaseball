//
//  StatCollectionCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StatCollectionCell.h"
#import "StatLayoutAttributes.h"


@implementation StatCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)setLayoutMode:(CollectionViewLayoutMode)layoutMode
{
    _layoutMode = layoutMode;
    
    [self setCustomFrame];
}

#pragma mark - Overridden Methods
- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    if(![layoutAttributes isKindOfClass:[StatLayoutAttributes class]])
        return;
    
    StatLayoutAttributes *castedLayoutAttributes = (StatLayoutAttributes *)layoutAttributes;
    self.layoutMode = castedLayoutAttributes.layoutMode;
}

- (void)setCustomFrame
{
    CGSize newSize = self.bounds.size;
    
    if (self.layoutMode == CollectionViewLayoutModeNarrow)
    {
        newSize = CGSizeMake(STAT_CELL_NARROW_WIDTH, STAT_CELL_HEIGHT);
    }
    else
    {
        newSize = CGSizeMake(STAT_CELL_WIDE_WIDTH, STAT_CELL_HEIGHT);
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, newSize.width, newSize.height)];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}

@end

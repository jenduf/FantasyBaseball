//
//  StatFlowLayout.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StatFlowLayout.h"

@implementation StatFlowLayout

- (id)init
{
    self = [super init];
    
    if(self)
    {
        self.itemSize = CGSizeMake(STAT_CELL_NARROW_WIDTH, STAT_CELL_HEIGHT);
        self.sectionInset = UIEdgeInsetsMake(13.0f, 13.0f, 13.0f, 13.0f);
        self.minimumInteritemSpacing = 13.0f;
        self.minimumLineSpacing = 13.0f;
    }
    
    return self;
}

+ (Class)layoutAttributesClass
{
    return [StatLayoutAttributes class];
}

#pragma mark - Private Helper Methods
- (void)applyLayoutAttributes:(StatLayoutAttributes *)attributes
{
    if(attributes.representedElementKind == nil)
    {
        attributes.layoutMode = self.layoutMode;
        
        if([self.collectionView.delegate respondsToSelector:@selector(collectionView:layout:layoutModeForItemAtIndexPath:)])
        {
            attributes.layoutMode = [(id<StatFlowDelegateLayout>)self.collectionView.delegate collectionView:self.collectionView layout:self layoutModeForItemAtIndexPath:attributes.indexPath];
        }
    }
}

#pragma mark - Overridden Methods

#pragma mark Cell Layout
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray *attributesArray = [super layoutAttributesForElementsInRect:rect];
    
    for (StatLayoutAttributes *attributes in attributesArray)
    {
        [self applyLayoutAttributes:attributes];
    }
    
    return attributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    StatLayoutAttributes *attributes = (StatLayoutAttributes *)[super layoutAttributesForItemAtIndexPath:indexPath];
    
    [self applyLayoutAttributes:attributes];
    
    return attributes;
}

#pragma mark - Overridden Properties
- (void)setLayoutMode:(CollectionViewLayoutMode)layoutMode
{
    _layoutMode = layoutMode;
    
    [self invalidateLayout];
}

@end

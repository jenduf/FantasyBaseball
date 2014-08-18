//
//  StatFlowLayout.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatLayoutAttributes.h"

@protocol StatFlowDelegateLayout;

@interface StatFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CollectionViewLayoutMode layoutMode;

@end

@protocol StatFlowDelegateLayout
<UICollectionViewDelegateFlowLayout>

@optional

- (CollectionViewLayoutMode)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout layoutModeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end
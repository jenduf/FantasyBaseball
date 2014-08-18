//
//  ScoreboardDetailCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScoreDetailCell : UITableViewCell

@property (nonatomic, strong) NSArray *stats;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *scoreLabels;

@end

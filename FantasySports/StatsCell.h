//
//  StatsCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Player;
@interface StatsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *position, *playerName;
@property (nonatomic, strong) IBOutletCollection(UILabel) NSArray *statLabels;
@property (nonatomic, strong) Player *player;

@end

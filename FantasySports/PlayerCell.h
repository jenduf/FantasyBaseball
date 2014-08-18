//
//  PlayerCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleView, Player;
@interface PlayerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet CircleView *statusView;
@property (nonatomic, weak) IBOutlet UILabel *playerName, *position, *teamName;
@property (nonatomic, weak) IBOutlet UIImageView *headshotImageView;
@property (nonatomic, weak) IBOutlet UIButton *newsButton;
@property (nonatomic, weak) IBOutlet UIImageView *lockImageView;
@property (nonatomic, assign) NewsMode newsMode;
@property (nonatomic, strong) Player *player;

@end

//
//  PlayerCell.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleView;
@interface PlayerCell : UITableViewCell

@property (nonatomic, weak) IBOutlet CircleView *statusView;
@property (nonatomic, weak) IBOutlet UILabel *playerName, *position, *teamName;
@property (nonatomic, weak) IBOutlet UIImageView *headshotImageView;
@property (nonatomic, weak) IBOutlet UIButton *newsButton;
@property (nonatomic, weak) IBOutlet UIImageView *lockImageView;
@property (nonatomic, assign) NewsMode newsMode;

@end

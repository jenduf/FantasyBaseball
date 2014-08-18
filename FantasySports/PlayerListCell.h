//
//  PlayerListCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 8/1/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Player;
@interface PlayerListCell : UITableViewCell

@property (nonatomic, strong) Player *player;
@property (nonatomic, weak) IBOutlet UILabel *name;

@end

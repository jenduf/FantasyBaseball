//
//  PlayerListCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 8/1/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "PlayerListCell.h"
#import "Player.h"

@implementation PlayerListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPlayer:(Player *)player
{
    _player = player;
    
    self.name.text = player.fullName;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

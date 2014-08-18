//
//  PlayerCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "PlayerCell.h"
#import "Player.h"

@implementation PlayerCell

- (void)setPlayer:(Player *)player
{
    _player = player;
    
    self.position.text = player.position;
    self.playerName.text = player.fullName;
    self.teamName.text = player.teamName;
    
    NewsMode playerNewsMode = NewsModeNone;
    
    if(player.hasRecentPlayerNotes)
        playerNewsMode = NewsModeHot;
    else if(player.hasPlayerNotes)
        playerNewsMode = NewsModeWarm;
    
    NSString *newsImageName = [NSString stringWithFormat:@"news_%i", playerNewsMode];
    [self.newsButton setBackgroundImage:[UIImage imageNamed:newsImageName] forState:UIControlStateNormal];
    
    UIImage *headshotImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:player.headshotURL]  options:0 error:nil]];
    self.headshotImageView.image = headshotImage;
    
    [self.lockImageView setHidden:!(player.isUndroppable)];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

//
//  StatsCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StatsCell.h"
#import "Player.h"
#import "Stat.h"

@implementation StatsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setPlayer:(Player *)player
{
    _player = player;
    
    self.playerName.text = player.fullName;
    
    self.position.text = player.position;
    
    NSInteger total = player.stats.count;
    
    for(NSInteger i = 0; i < total; i++)
    {
        Stat *stat = player.stats[i];
        
        UILabel *statLabel = self.statLabels[i];
        
        statLabel.text = stat.statValue;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

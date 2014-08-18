//
//  ScoreboardDetailCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "ScoreDetailCell.h"
#import "Stat.h"

@implementation ScoreDetailCell

- (void)setStats:(NSArray *)stats
{
    _stats = stats;
    
    NSInteger total = stats.count;
    
    for(NSInteger i = 0; i < total; i++)
    {
        Stat *stat = stats[i];
        UILabel *scoreLabel = self.scoreLabels[i];
        scoreLabel.text = stat.statValue;
        
        if(stat.winning)
            scoreLabel.textColor = [UIColor redColor];
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

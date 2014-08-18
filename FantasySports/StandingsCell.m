//
//  StandingsCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 8/1/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StandingsCell.h"
#import "Team.h"

@implementation StandingsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTeam:(Team *)team
{
    _team = team;
    
    self.rank.text = [NSString stringWithFormat:@"%li", (long)team.rank];
    
    self.name.text = team.teamName;
    
    self.record.text = [NSString stringWithFormat:@"%li - %li - %li", (long)team.wins, (long)team.losses, (long)team.ties];
    
    self.gamesBack.text = [NSString stringWithFormat:@"%li games back", (long)team.gamesBack];
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

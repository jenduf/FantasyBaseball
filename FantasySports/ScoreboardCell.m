//
//  ScoreboardCell.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "ScoreboardCell.h"
#import "Team.h"
#import "Matchup.h"

@implementation ScoreboardCell

- (void)setMatchup:(Matchup *)matchup
{
    _matchup = matchup;
    
    Team *t1 = matchup.teams[0];
    
    self.team1.text = t1.teamName;
    self.score1.text = [NSString stringWithFormat:@"%li", (long)t1.teamPoints];
    
    Team *t2 = matchup.teams[1];
    
    self.team2.text = t2.teamName;
    self.score2.text = [NSString stringWithFormat:@"%li", (long)t2.teamPoints];
}

@end

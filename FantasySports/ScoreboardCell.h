//
//  ScoreboardCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Matchup;
@interface ScoreboardCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *team1, *team2;
@property (nonatomic, weak) IBOutlet UILabel *score1, *score2;
@property (nonatomic, strong) Matchup *matchup;

@end

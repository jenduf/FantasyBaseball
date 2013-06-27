//
//  StatsCell.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StatsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *position, *playerName, *atBats, *runs, *homeRuns, *rbi, *stolenBases, *average;
@property (nonatomic, weak) IBOutlet UILabel *innings, *wins, *saves, *strikeouts, *era, *whip;

@end

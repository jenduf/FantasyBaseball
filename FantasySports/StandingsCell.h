//
//  StandingsCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 8/1/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface StandingsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *name, *rank, *record, *gamesBack;
@property (nonatomic, strong) Team *team;

@end

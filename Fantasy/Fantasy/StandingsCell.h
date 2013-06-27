//
//  StandingsCell.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/26/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StandingsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *teamName, *teamRank;
@property (nonatomic, weak) IBOutlet UILabel *teamRecord;
@property (nonatomic, weak) IBOutlet UILabel *gamesBack;

@end

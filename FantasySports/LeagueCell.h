//
//  LeagueCell.h
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class League;
@interface LeagueCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (nonatomic, strong) League *league;

@end

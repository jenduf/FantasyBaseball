//
//  MatchUpCell.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/26/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MatchUpCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *team1Name, *team2Name;
@property (nonatomic, weak) IBOutlet UILabel *team1Score, *team2Score;

@end

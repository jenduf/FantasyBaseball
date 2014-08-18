//
//  ScoreDetailViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "ScoreDetailViewController.h"
#import "Matchup.h"
#import "Team.h"
#import "TeamStats.h"
#import "ScoreDetailCell.h"
#import "ScoreHeaderView.h"

@interface ScoreDetailViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel *team1, *team2, *score1, *score2;
@property (nonatomic, weak) IBOutlet UITableView *scoreTableView;

@end

@implementation ScoreDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    Team *t1 = self.matchup.teams[0];
    self.team1.text = t1.teamName;
    self.score1.text = [NSString stringWithFormat:@"%li", (long)t1.teamPoints];
    
    Team *t2 = self.matchup.teams[1];
    self.team2.text = t2.teamName;
    self.score2.text = [NSString stringWithFormat:@"%li", (long)t2.teamPoints];
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.matchup.teams.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    Team *team = self.matchup.teams[0];
    
    ScoreHeaderView *headerView = [[ScoreHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, STAT_CELL_HEIGHT)];
    [headerView setStatHeaders:[team.teamStats getParticularStats]];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:SCORE_DETAIL_CELL_IDENTIFIER];
    
    Team *team = self.matchup.teams[indexPath.row];
    
    [cell setStats:[team.teamStats getParticularStats]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.selectedIndex = indexPath.row;
    
    //	[self performSegueWithIdentifier:SHOW_SHEET_MUSIC_SEGUE sender:nil];
}

@end

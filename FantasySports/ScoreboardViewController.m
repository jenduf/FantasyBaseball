//
//  ScoreboardViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "ScoreboardViewController.h"
#import "ScoreDetailViewController.h"
#import "Scoreboard.h"
#import "ScoreboardCell.h"
#import "Matchup.h"

@interface ScoreboardViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Scoreboard *scoreboard;
@property (nonatomic, weak) IBOutlet UITableView *scoreboardTableView;

@end

@implementation ScoreboardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[YahooClient sharedClient] getScoreboardWithDelegate:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ScoreDetailViewController *sdvc = (ScoreDetailViewController *)segue.destinationViewController;
    
    NSInteger row = [self.scoreboardTableView indexPathForSelectedRow].row;
    Matchup *matchup = self.scoreboard.matchups[row];
    sdvc.matchup = matchup;
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.scoreboard.matchups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScoreboardCell *cell = [tableView dequeueReusableCellWithIdentifier:SCOREBOARD_CELL_IDENTIFIER];
    
    Matchup *matchup = self.scoreboard.matchups[indexPath.row];

    [cell setMatchup:matchup];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.selectedIndex = indexPath.row;
    
    //	[self performSegueWithIdentifier:SHOW_SHEET_MUSIC_SEGUE sender:nil];
}

#pragma mark - YahooClientDelegate Methods
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data
{
    NSDictionary *dataDict = (NSDictionary *)data;
    
    NSDictionary *queryDict = dataDict[@"query"];
    NSDictionary *resultsDict = queryDict[@"results"];
    NSDictionary *leagueDict = resultsDict[@"league"];
    NSDictionary *scoreboardDict = leagueDict[@"scoreboard"];
    
    self.scoreboard = [[Scoreboard alloc] initWithDictionary:scoreboardDict];
    
    [self.scoreboardTableView reloadData];
}

@end

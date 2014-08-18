//
//  StandingsViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StandingsViewController.h"
#import "Team.h"
#import "StandingsCell.h"

@interface StandingsViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *standingsTableView;

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation StandingsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.teams = [[NSMutableArray alloc] init];
    
    [[YahooClient sharedClient] getStandingsWithDelegate:self];
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.teams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StandingsCell *cell = [tableView dequeueReusableCellWithIdentifier:STANDINGS_CELL_IDENTIFIER];
    
    Team *team = self.teams[indexPath.row];
    
    [cell setTeam:team];
    
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
    NSDictionary *standingsDict = leagueDict[@"standings"];
    NSDictionary *teams = standingsDict[@"teams"];
    
    NSArray *teamArray = teams[@"team"];
    
    for(NSDictionary *dict in teamArray)
    {
        Team *team = [[Team alloc] initWithDictionary:dict];
        [self.teams addObject:team];
    }
    
    [self.standingsTableView reloadData];
}

@end

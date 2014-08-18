 //
//  StatsViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StatsViewController.h"
#import "Stat.h"
#import "Player.h"
#import "StatsCell.h"
#import "StatsHeaderView.h"

@interface StatsViewController ()
<YahooClientDelegate>

@property (nonatomic, strong) NSMutableArray *players;

@end

@implementation StatsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    
    self.players = [[NSMutableArray alloc] init];
    
    [self refresh];
}

- (void)refresh
{
    [self.players removeAllObjects];
    
    [[YahooClient sharedClient] getStatsWithDelegate:self];
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return _players.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = _players[section];
    return array.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    StatsHeaderView *headerView = [[StatsHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, STAT_CELL_HEIGHT)];
    [headerView setPlayerType:(PlayerType)section];
    
    return headerView;
}

/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Batters";
    
    return @"Pitchers";
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StatsCell *cell = [tableView dequeueReusableCellWithIdentifier:STATS_CELL_IDENTIFIER];
    
    NSArray *array = _players[indexPath.section];
    
    Player *player = array[indexPath.row];
    
    [cell setPlayer:player];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 //   NSArray *array = _players[indexPath.section];
 //   Player *player = array[indexPath.row];
    
    //PlayerViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:PLAYER_VIEW_CONTROLLER];
    //pvc.player = player;
    
    //[self.navigationController pushViewController:pvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YahooClientDelegate Methods
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data
{
    NSDictionary *dataDict = (NSDictionary *)data;
    
    NSDictionary *queryDict = dataDict[@"query"];
    NSDictionary *resultsDict = queryDict[@"results"];
    NSDictionary *teamDict = resultsDict[@"team"];
    NSDictionary *rosterDict = teamDict[@"roster"];
    NSDictionary *playersDict = rosterDict[@"players"];
    NSArray *playerArray = playersDict[@"player"];
    
    NSMutableArray *pitchers = [NSMutableArray array];
    NSMutableArray *batters = [NSMutableArray array];
    
    [playerArray enumerateObjectsUsingBlock:^(NSDictionary *playerDict, NSUInteger idx, BOOL *stop)
     {
         Player *player = [[Player alloc] initWithDictionary:playerDict];
         
         NSDictionary *playerStatsDict = playerDict[@"player_stats"];
         NSDictionary *statsDict = playerStatsDict[@"stats"];
         NSArray *statArray = statsDict[@"stat"];
         
         NSMutableArray *allStatsArray = [NSMutableArray array];
         
         [statArray enumerateObjectsUsingBlock:^(NSDictionary *stat, NSUInteger idx, BOOL *stop)
          {
              Stat *s = [[Stat alloc] initWithDictionary:stat];
              
              [allStatsArray addObject:s];
          }];
         
         [player setStats:allStatsArray];
         
         
         if([player.positionType isEqualToString:@"P"])
         {
             [pitchers addObject:player];
         }
         else
         {
             [batters addObject:player];
         }
     }];
    
    [_players addObject:batters];
    [_players addObject:pitchers];
    
    if([self.refreshControl isRefreshing])
        [self.refreshControl endRefreshing];
    
    [self.tableView reloadData];
}

@end

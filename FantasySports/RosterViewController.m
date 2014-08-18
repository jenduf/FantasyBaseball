//
//  SecondViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/27/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "RosterViewController.h"
#import "PlayerViewController.h"
#import "Player.h"
#import "PlayerCell.h"

@interface RosterViewController ()
<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *players;
@property (nonatomic, weak) IBOutlet UITableView *rosterTableView;

@end

@implementation RosterViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.players = [[NSMutableArray alloc] init];
    
    [[YahooClient sharedClient] getRosterWithDelegate:self];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return @"Batters";
    
    return @"Pitchers";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:PLAYER_CELL_IDENTIFIER];
    
    NSArray *array = _players[indexPath.section];
    
    Player *player = array[indexPath.row];
    
    [cell setPlayer:player];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = _players[indexPath.section];
    Player *player = array[indexPath.row];
    
    PlayerViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:PLAYER_VIEW_CONTROLLER];
    pvc.player = player;
    
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YahooClientDelegate Methods
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data
{
    switch (yahooClient.requestType)
    {
        case RequestTypeMyRoster:
        {
            NSDictionary *dataDict = (NSDictionary *)data;
            
            NSDictionary *queryDict = dataDict[@"query"];
            NSDictionary *resultsDict = queryDict[@"results"];
            NSDictionary *teamDict = resultsDict[@"team"];
            NSDictionary *rosterDict = teamDict[@"roster"];
            NSDictionary *playersDict = rosterDict[@"players"];
            NSArray *playerArray = playersDict[@"player"];
            
            NSMutableArray *batters = [NSMutableArray array];
            NSMutableArray *pitchers = [NSMutableArray array];
            
            [playerArray enumerateObjectsUsingBlock:^(NSDictionary *playerDict, NSUInteger idx, BOOL *stop)
             {
                 Player *player = [[Player alloc] initWithDictionary:playerDict];
                 
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
            
            [self.rosterTableView reloadData];
        }
            break;
            
        case RequestTypePlayer:
        {
            
        }
            break;
            
        default:
            break;
    }
}

@end

//
//  PlayerSearchViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 8/1/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "PlayerSearchViewController.h"
#import "PlayerListCell.h"
#import "Player.h"

@interface PlayerSearchViewController ()
<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UITableView *playerTableView;
@property (nonatomic, weak) IBOutlet UISearchBar *playerSearchBar;
@property (nonatomic, strong) NSMutableArray *players;

@end

@implementation PlayerSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.players = [[NSMutableArray alloc] init];
    
    //[[YahooClient sharedClient] getOwnershipWithDelegate:self];
    
    [[YahooClient sharedClient] getPlayersWithStart:0 count:20 sortType:1 andDelegate:self];
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.players.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerListCell *cell = [tableView dequeueReusableCellWithIdentifier:PLAYER_LIST_CELL_IDENTIFIER];
    
    Player *player = self.players[indexPath.row];
    
    [cell setPlayer:player];
    
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
    NSArray *playerArray = resultsDict[@"player"];
    
    for(NSDictionary *dict in playerArray)
    {
        Player *p = [[Player alloc] initWithDictionary:dict];
        
       // if([p.ownershipType isEqualToString:OWNERSHIP_TYPE_FREEAGENTS])
        [self.players addObject:p];
    }
    
    [self.playerTableView reloadData];
}

@end

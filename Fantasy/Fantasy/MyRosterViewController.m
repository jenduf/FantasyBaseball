//
//  MyRosterViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "MyRosterViewController.h"
#import "Player.h"
#import "PlayerCell.h"
#import "CircleView.h"
#import "UIImageView+AFNetworking.h"

@interface MyRosterViewController ()

@property (nonatomic, strong) NSMutableArray *players;

@end

@implementation MyRosterViewController


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[YahooClient sharedClient] setDelegate:self];
	[[YahooClient sharedClient] getMyRoster];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_players = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
	PlayerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PlayerCellIdentifier"];
	
	NSArray *array = _players[indexPath.section];
	
	Player *player = array[indexPath.row];
	
	cell.position.text = player.position;
	cell.playerName.text = player.fullName;
	cell.teamName.text = player.teamName;
	
	NewsMode playerNewsMode = NEWS_MODE_NONE;
	
	if(player.hasRecentPlayerNotes)
		playerNewsMode = NEWS_MODE_HOT;
	else if(player.hasPlayerNotes)
		playerNewsMode = NEWS_MODE_WARM;
	
	[cell setNewsMode:playerNewsMode];
	
	[cell.statusView setStatusMode:player.startingStatus];
	
	[cell.headshotImageView setImageWithURL:[NSURL URLWithString:player.headshotURL]];
	
	[cell.lockImageView setHidden:!(player.isUndroppable)];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	//self.selectedIndex = indexPath.row;
	
	//	[self performSegueWithIdentifier:SHOW_SHEET_MUSIC_SEGUE sender:nil];
}

#pragma mark - Yahoo Client Methods
- (void)yahooClient:(YahooClient *)client didFinishWithResults:(id)results
{
	NSLog(@"Results: %@", results);
	
	NSDictionary *queryDict = results[@"query"];
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

@end

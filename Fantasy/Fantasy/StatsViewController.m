//
//  StatsViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "StatsViewController.h"
#import "Player.h"
#import "Stats.h"
#import "StatsCell.h"

@interface StatsViewController ()
<YahooClientDelegate>

@property (nonatomic, strong) NSMutableArray *players;

@end

@implementation StatsViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[YahooClient sharedClient] setDelegate:self];
	[[YahooClient sharedClient] getStats];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_players = [NSMutableArray array];
}

- (NSString *)getCellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier;
	
	if(indexPath.section == 0)
	{
		identifier = ((indexPath.row % 2) == 0 ? @"StatsCellIdentifier" : @"StatsAltCellIdentifier");
	}
	else
	{
		identifier = ((indexPath.row % 2) == 0 ? @"StatsPitcherCellIdentifier" : @"StatsPitcherAltCellIdentifier");
	}
	
	return identifier;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationLandscapeLeft;
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
	NSString *imageName = [NSString stringWithFormat:@"top_bar_%i", section];
	
	UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
	
	return headerImageView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [self getCellIdentifierForIndexPath:indexPath];
	
	StatsCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	
	NSArray *array = _players[indexPath.section];
	
	Player *player = array[indexPath.row];
	
	cell.position.text = player.position;
	cell.playerName.text = player.fullName;
	
	if(indexPath.section == 0)
	{
		cell.atBats.text = player.stats[@"H/AB"];
		cell.runs.text = player.stats[@"R"];
		cell.homeRuns.text = player.stats[@"HR"];
		cell.rbi.text = player.stats[@"RBI"];
		cell.stolenBases.text = player.stats[@"SB"];
		cell.average.text = player.stats[@"AVG"];
	}
	else
	{
		cell.innings.text = player.stats[@"IP"];
		cell.wins.text = player.stats[@"W"];
		cell.saves.text = player.stats[@"SV"];
		cell.strikeouts.text = player.stats[@"K"];
		cell.era.text = player.stats[@"ERA"];
		cell.whip.text = player.stats[@"WHIP"];
		
	}
	
	
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
	
	NSMutableArray *pitchers = [NSMutableArray array];
	NSMutableArray *batters = [NSMutableArray array];
	
	[playerArray enumerateObjectsUsingBlock:^(NSDictionary *playerDict, NSUInteger idx, BOOL *stop)
	 {
		 Player *player = [[Player alloc] initWithDictionary:playerDict];
		 
		 NSDictionary *playerStatsDict = playerDict[@"player_stats"];
		 NSDictionary *statsDict = playerStatsDict[@"stats"];
		 NSArray *statArray = statsDict[@"stat"];
		 
		 NSMutableDictionary *statDictionary = [NSMutableDictionary dictionary];
		 
		 [statArray enumerateObjectsUsingBlock:^(NSDictionary *stat, NSUInteger idx, BOOL *stop)
		  {
			  Stats *stats = [[Stats alloc] initWithDictionary:stat];
			  
			  [statDictionary setObject:stats.statValue forKey:stats.statName];
		  }];
		 
		 [player setStats:[[NSDictionary alloc] initWithDictionary:statDictionary]];
		 
		 
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
	
	[self.statsTableView reloadData];
	
}

@end

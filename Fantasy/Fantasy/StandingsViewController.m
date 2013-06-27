//
//  StandingsViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "StandingsViewController.h"
#import "Team.h"
#import "StandingsCell.h"

@interface StandingsViewController ()
<YahooClientDelegate>

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation StandingsViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[YahooClient sharedClient] setDelegate:self];
	[[YahooClient sharedClient] getStandings];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_teams = [[NSMutableArray alloc] init];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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
	StandingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StandingsCellIdentifier"];
	
	Team *team = self.teams[indexPath.row];
	
	cell.teamName.text = team.teamName;
	
	cell.teamRank.text = [NSString stringWithFormat:@"%i", indexPath.row];
	
	cell.teamRecord.text = [NSString stringWithFormat:@"%i - %i - %i", team.wins, team.losses, team.ties];
	
	cell.gamesBack.text = [NSString stringWithFormat:@"%i Games Back", team.gamesBack];
	
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
	NSDictionary *leagueDict = resultsDict[@"league"];
	NSDictionary *standingsDict = leagueDict[@"standings"];
	NSDictionary *teams = standingsDict[@"teams"];
	
	NSArray *teamArray = teams[@"team"];
	
	for(NSDictionary *dict in teamArray)
	{
		Team *team = [[Team alloc] initWithDictionary:dict];
		
		NSDictionary *standings = dict[@"team_standings"];
		team.rank = [standings[@"rank"] intValue];
		
		NSDictionary *totals = standings[@"outcome_totals"];
		team.wins = [totals[@"wins"] intValue];
		team.losses = [totals[@"losses"] intValue];
		team.ties = [totals[@"ties"] intValue];
		team.percentage = [totals[@"percentage"] intValue];
		team.gamesBack = [standings[@"games_back"] intValue];
		
		[_teams addObject:team];
	}
	
	
	[self.standingsTableView reloadData];
}

@end

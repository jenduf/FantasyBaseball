//
//  ScoreboardViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "ScoreboardViewController.h"
#import "Scoreboard.h"
#import "MatchUpCell.h"
#import "Team.h"

@interface ScoreboardViewController ()
<YahooClientDelegate>

@property (nonatomic, strong) Scoreboard *scoreboard;

@end

@implementation ScoreboardViewController

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[YahooClient sharedClient] setDelegate:self];
	[[YahooClient sharedClient] getScoreboard];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view.
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
	return self.scoreboard.matchups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	MatchUpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MatchUpCellIdentifier"];
	
	NSArray *matchup = self.scoreboard.matchups[indexPath.row];
	
	Team *team1 = matchup[0];
	Team *team2 = matchup[1];
	
	cell.team1Name.text = team1.teamName;
	cell.team2Name.text = team2.teamName;
	
	cell.team1Score.text = [NSString stringWithFormat:@"%i", team1.teamPoints];
	cell.team2Score.text = [NSString stringWithFormat:@"%i", team2.teamPoints];
	
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
	NSDictionary *scoreboardDict = leagueDict[@"scoreboard"];
	
	self.scoreboard = [[Scoreboard alloc] initWithDictionary:scoreboardDict];
	
	[self.scoreboardTableView reloadData];
}

@end

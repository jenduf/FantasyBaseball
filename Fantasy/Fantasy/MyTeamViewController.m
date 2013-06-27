//
//  MyTeamViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "MyTeamViewController.h"
#import "Team.h"

@interface MyTeamViewController ()
<YahooClientDelegate>

@end

@implementation MyTeamViewController


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[YahooClient sharedClient] setDelegate:self];
	[[YahooClient sharedClient] getMyTeam];
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

#pragma mark - Yahoo Client Methods
- (void)yahooClient:(YahooClient *)client didFinishWithResults:(id)results
{
	NSLog(@"Results: %@", results);
	
	NSDictionary *queryDict = results[@"query"];
	NSDictionary *resultsDict = queryDict[@"results"];
	NSDictionary *teamDict = resultsDict[@"team"];
	
	Team *team = [[Team alloc] initWithDictionary:teamDict];
	
	self.teamNameLabel.text = team.teamName;
	
	self.managerNameLabel.text = team.managerName;
	
}

@end

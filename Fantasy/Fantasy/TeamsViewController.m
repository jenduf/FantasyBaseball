//
//  TeamsViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 5/2/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "TeamsViewController.h"
#import "Team.h"

@interface TeamsViewController ()
<YahooClientDelegate>

@property (nonatomic, strong) NSMutableArray *teams;

@end

@implementation TeamsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.teams = [[NSMutableArray alloc] init];
	
	[[YahooClient sharedClient] setDelegate:self];
	[[YahooClient sharedClient] editRoster];
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
	NSArray *teamArray = resultsDict[@"team"];
	
	for(NSDictionary *dict in teamArray)
	{
		Team *team = [[Team alloc] initWithDictionary:dict];
		[self.teams addObject:team];
	}
	
}

@end

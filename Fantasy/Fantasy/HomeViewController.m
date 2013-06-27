//
//  HomeViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "HomeViewController.h"
#import "AuthViewController.h"
#import "Game.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

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
	
	[[YahooClient sharedClient] startRequestWithDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Yahoo Client Delegate Methods
- (void)yahooClient:(YahooClient *)client didFailWithError:(NSError *)error
{
	
}

- (void)yahooClient:(YahooClient *)client needsToDisplayHTML:(NSString *)htmlString
{
	AuthViewController *authVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
	[self presentViewController:authVC animated:YES completion:^
	{
		[authVC.webView loadHTMLString:htmlString baseURL:nil];
	}];
}

- (void)yahooClient:(YahooClient *)client didFinishWithResults:(id)results
{
	NSLog(@"Results: %@", results);
	
	NSDictionary *queryDict = results[@"query"];
	NSDictionary *resultsDict = queryDict[@"results"];
	NSDictionary *gameDict = resultsDict[@"game"];
	
	[Game setCurrentGame:[[Game alloc] initWithDictionary:gameDict]];
	
		
}

- (void)yahooClient:(YahooClient *)client needsToShowWebPage:(NSString *)url withCode:(NSString *)code
{
	AuthViewController *authVC = [self.storyboard instantiateViewControllerWithIdentifier:@"AuthViewController"];
	[self presentViewController:authVC animated:YES completion:^
	 {
		 [authVC.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
		 authVC.codeLabel.text = [NSString stringWithFormat:@"Your Code: %@", code];
	 }];
}

- (void)yahooClientAuthorizationComplete:(YahooClient *)client
{
	[[YahooClient sharedClient] getGame];
}

@end

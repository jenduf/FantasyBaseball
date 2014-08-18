//
//  FirstViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/27/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "HomeViewController.h"
#import "AuthViewController.h"
#import "RosterViewController.h"
#import "LeagueCell.h"
#import "League.h"

@interface HomeViewController ()
<YahooClientDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AuthViewController *authViewController;
@property (weak, nonatomic) IBOutlet UITableView *leagueTableView;
@property (nonatomic, strong) NSMutableArray *leagues;

@end

@implementation HomeViewController
            
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leagues = [[NSMutableArray alloc] init];
    
    [[YahooClient sharedClient] getTokenWithDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView Delegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.leagues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LeagueCell *cell = [tableView dequeueReusableCellWithIdentifier:LEAGUE_CELL_IDENTIFIER];
    
    League *league = self.leagues[indexPath.row];
    
    [cell setLeague:league];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    League *league = self.leagues[indexPath.row];
    
    [League setCurrentLeague:league];
    
    [self.tabBarController setSelectedIndex:TabStateRoster];
}

#pragma mark - YahooClientDelegate Methods
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data
{
    NSDictionary *returnDict = (NSDictionary *)data;
    
    NSDictionary *queryDict = returnDict[@"query"];
    NSDictionary *resultsDict = queryDict[@"results"];
    NSArray *leagueArray = resultsDict[@"league"];
    
    for(NSDictionary *d in leagueArray)
    {
        League *league = [[League alloc] initWithDictionary:d];
        [self.leagues addObject:league];
    }
    
    [self.leagueTableView reloadData];
}

- (void)yahooClient:(YahooClient *)yahooClient needsToShowWebPage:(NSString *)webPage withCode:(NSString *)code
{
    self.authViewController = [self.storyboard instantiateViewControllerWithIdentifier:AUTH_VIEW_CONTROLLER];
    
    [self presentViewController:self.authViewController animated:YES completion:^
    {
        [self.authViewController.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:webPage]]];
        self.authViewController.codeLabel.text = [NSString stringWithFormat:@"Your Code: %@", code];

    }];
}

- (void)yahooClientAuthorizationComplete:(YahooClient *)yahooClient
{
    if(self.authViewController)
    {
        [self dismissViewControllerAnimated:YES completion:^
        {
            
        }];
    }
    
    [[YahooClient sharedClient] getLeagueWithDelegate:self];
}

@end

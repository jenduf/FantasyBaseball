//
//  TeamViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "TeamViewController.h"

@implementation TeamViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[YahooClient sharedClient] getTeamWithDelegate:self];
}

#pragma mark - YahooClientDelegate Methods
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data
{
    
    
}

@end

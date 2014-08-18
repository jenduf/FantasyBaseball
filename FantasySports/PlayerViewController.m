//
//  PlayerViewController.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "PlayerViewController.h"
#import "Player.h"
#import "CircleView.h"

@interface PlayerViewController ()

@property (nonatomic, weak) IBOutlet CircleView *statusView;
@property (nonatomic, weak) IBOutlet UILabel *playerName, *position, *teamName;
@property (nonatomic, weak) IBOutlet UIImageView *headshotImageView;
@property (nonatomic, weak) IBOutlet UIButton *newsButton;
@property (nonatomic, weak) IBOutlet UIImageView *lockImageView;

@end

@implementation PlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    [[YahooClient sharedClient] getPlayerWithID:self.player.playerKey andDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - YahooClientDelegate Methods
- (void)yahooClient:(YahooClient *)yahooClient didReturnData:(id)data
{
    NSDictionary *dataDict = (NSDictionary *)data;
    
    NSDictionary *queryDict = dataDict[@"query"];
    NSDictionary *resultsDict = queryDict[@"results"];
    NSDictionary *playerDict = resultsDict[@"player"];
    
    Player *p = [[Player alloc] initWithDictionary:playerDict];
    
    self.position.text = p.position;
    self.playerName.text = p.fullName;
    self.teamName.text = p.teamName;
    
    NewsMode playerNewsMode = NewsModeNone;
    
    if(p.hasRecentPlayerNotes)
        playerNewsMode = NewsModeHot;
    else if(p.hasPlayerNotes)
        playerNewsMode = NewsModeWarm;
    
    NSString *newsImageName = [NSString stringWithFormat:@"news_%i", playerNewsMode];
    [self.newsButton setBackgroundImage:[UIImage imageNamed:newsImageName] forState:UIControlStateNormal];
    
    UIImage *headshotImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:p.headshotURL]  options:0 error:nil]];
    self.headshotImageView.image = headshotImage;
    
    [self.lockImageView setHidden:!(p.isUndroppable)];
}

@end

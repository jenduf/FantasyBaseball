//
//  StatsHeaderView.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/28/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "StatsHeaderView.h"

@implementation StatsHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        
    }
    
    return self;
}

- (void)setPlayerType:(PlayerType)playerType
{
    _playerType = playerType;
    
    float nextX = CELL_PADDING;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, STAT_CELL_HEIGHT)];
    headerLabel.font = [UIFont fontWithName:FONT_DIN_CONDENSED_BOLD size:FONT_SIZE_HEADER];
    headerLabel.backgroundColor = [UIColor darkGrayColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = (playerType == PlayerTypeBatter ? @"  Batters" : @"  Pitchers");
    [self addSubview:headerLabel];
    
    UILabel *positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(nextX, headerLabel.bottom, STAT_FIRST_CELL_WIDTH, STAT_CELL_HEIGHT)];
    positionLabel.font = [UIFont fontWithName:FONT_DIN_CONDENSED_BOLD size:FONT_SIZE_TITLE];
    positionLabel.text = @"POS";
    [self addSubview:positionLabel];
    
    nextX += (positionLabel.width + CELL_PADDING);
    
    UILabel *playerLabel = [[UILabel alloc] initWithFrame:CGRectMake(nextX, headerLabel.bottom, STAT_CELL_WIDE_WIDTH, STAT_CELL_HEIGHT)];
    playerLabel.font = [UIFont fontWithName:FONT_DIN_CONDENSED_BOLD size:FONT_SIZE_TITLE];
    playerLabel.text = @"PLAYER";
    [self addSubview:playerLabel];
    
    nextX += (playerLabel.width + CELL_ITEM_PADDING);
        
    for(int i = 0; i < TOTAL_STAT_LABELS; i++)
    {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(nextX, headerLabel.bottom, STAT_CELL_NARROW_WIDTH, STAT_CELL_HEIGHT)];
        label.font = [UIFont fontWithName:FONT_DIN_CONDENSED_BOLD size:FONT_SIZE_TITLE];
        label.text = [self getStatStringForPlayerType:playerType atIndex:i];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        nextX += (label.width + CELL_PADDING);
    }
}

- (NSString *)getStatStringForPlayerType:(PlayerType)type atIndex:(int)index
{
    NSString *labelText = nil;
    
    if(type == PlayerTypeBatter)
    {
        labelText = [Utils getStatStringForBatterStatIndex:index];
    }
    else
    {
        labelText = [Utils getStatStringForPitcherStatIndex:index];
    }
    
    return labelText;
}

@end

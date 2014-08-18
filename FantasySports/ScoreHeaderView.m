//
//  ScoreHeaderView.m
//  FantasySports
//
//  Created by Jennifer Duffey on 7/29/14.
//  Copyright (c) 2014 Jennifer Duffey. All rights reserved.
//

#import "ScoreHeaderView.h"
#import "Stat.h"

@implementation ScoreHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setStatHeaders:(NSArray *)statHeaders
{
    _statHeaders = statHeaders;
    
    float nextX = STAT_PADDING;
    
    NSInteger total = statHeaders.count;
        
    for(NSInteger i = 0; i < total; i++)
    {
        Stat *stat = statHeaders[i];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(nextX, CELL_PADDING, STAT_CELL_NARROW_WIDTH, STAT_CELL_HEIGHT)];
        label.font = [UIFont fontWithName:FONT_DIN_CONDENSED_BOLD size:FONT_SIZE_TITLE];
        label.text = stat.statName;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        nextX += (label.width + CELL_PADDING);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

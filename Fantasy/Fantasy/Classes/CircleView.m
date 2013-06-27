//
//  CircleView.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/25/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "CircleView.h"

@implementation CircleView

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
	{
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

- (void)setStatusMode:(StatusMode)statusMode
{
	_statusMode = statusMode;
	
	[self setNeedsDisplay];
}



- (UIColor *)getColorForMode:(StatusMode)mode
{
	switch (mode)
	{
		case STATUS_MODE_BENCHED:
			return [UIColor redColor];
			break;
			
		case STATUS_MODE_PLAYING:
			return [UIColor greenColor];
			break;
			
		case STATUS_MODE_DISABLED:
			return [UIColor blueColor];
			break;
			
		default:
			break;
	}
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect circleRect = CGRectInset(rect, PADDING_TOP, PADDING_TOP);
	CGRect strokeRect = CGRectOffset(circleRect, 0, -1);
	
	UIColor *circleColor = [self getColorForMode:_statusMode];
	
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 4.0, [UIColor blackColor].CGColor);
	CGContextSetFillColorWithColor(context, circleColor.CGColor);
	CGContextFillEllipseInRect(context, circleRect);
	CGContextRestoreGState(context);
	
	CGContextSaveGState(context);
	CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] colorWithAlphaComponent:0.75].CGColor);
	CGContextSetLineWidth(context, 1.5);
	CGContextStrokeEllipseInRect(context, strokeRect);
	CGContextRestoreGState(context);
}


@end

//
//  HomeViewController.h
//  Fantasy
//
//  Created by Jennifer Duffey on 4/24/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AuthViewController : UIViewController
<YahooClientDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;

@end

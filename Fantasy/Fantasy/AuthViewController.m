//
//  HomeViewController.m
//  Fantasy
//
//  Created by Jennifer Duffey on 4/24/13.
//  Copyright (c) 2013 Jennifer Duffey. All rights reserved.
//

#import "AuthViewController.h"

@interface AuthViewController ()

@end

@implementation AuthViewController

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
	
	

	//[client getGame];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIWebView Delegate Methods
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSLog(@"request data: %@", [request.URL relativeString]);
	
	NSString *url = [request.URL relativeString];
	
	NSRange range = [url rangeOfString:@"oauth_verifier"];
	
	if(range.location != NSNotFound)
	{
		NSArray *arr = [url componentsSeparatedByString:@"&"];
		NSArray *nextArr = [arr[1] componentsSeparatedByString:@"="];
		NSString *verifier = nextArr[1];
		
		[[YahooClient sharedClient] requestAccessTokenWithVerifier:verifier];
		
		return  NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	
}

- (void)webview:(UIWebView *)webView decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id)listener
{
	
}

@end

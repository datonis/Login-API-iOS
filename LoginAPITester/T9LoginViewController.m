//
//  T9LoginViewController.m
//  LoginAPITester
//
//  Created by Jeremy White on 5/8/13.
//  Copyright (c) 2013 Ten 90 Group. All rights reserved.
//

#import "T9LoginViewController.h"
#import "T9Login.h"

@interface T9LoginViewController ()
{
    UIWebView *webView;
    UIActivityIndicatorView *indicator;
    
    BOOL shouldHandleErrors;
}

@end

@implementation T9LoginViewController

- (id)init
{
    self = [super init];
    if (self) {
        shouldHandleErrors = YES;
        [self createViews];
    }
    return self;
}

- (void) createViews
{
    self.modalPresentationStyle = UIModalPresentationFormSheet;
    self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    webView = [[UIWebView alloc] init];
    self.view = webView;
    
    [self initiateConnectionToServer];
}

// Changes the loaded HTML "device width" to be width of webView
- (void) fixHTMLWidth
{
    NSString* js =
    [NSString stringWithFormat:@"var meta = document.createElement('meta'); " \
     "meta.setAttribute( 'name', 'viewport' ); " \
     "meta.setAttribute( 'content', 'width = %f, initial-scale = 1.0, user-scalable = no' ); " \
     "document.getElementsByTagName('head')[0].appendChild(meta)", self.view.frame.size.width];
    
    [webView stringByEvaluatingJavaScriptFromString: js];
}

- (void) webViewDidStartLoad:(UIWebView *)pWebView
{
    [self startIndicator];
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (!shouldHandleErrors)
        return;
    
    if (error.code == NSURLErrorCancelled) return;
    
    [self stopIndicator];
    
    NSString *errorString = [NSString stringWithFormat:@"Connection Error %d", error.code];
    NSString *messageString = [NSString stringWithFormat:@"Failed to load login screen with the error below. Try again or press the Home button to exit.\n\n%@", error.localizedDescription];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorString
                                                    message:messageString
                                                   delegate:self
                                          cancelButtonTitle:@"Try Again"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void) webViewDidFinishLoad:(UIWebView *)pWebView
{
    [self stopIndicator];
    [self fixHTMLWidth];
    
    if ([pWebView.request.URL.path isEqualToString:@"/portal"])
        [[T9Login sharedLogin] setDeviceUUID:[webView stringByEvaluatingJavaScriptFromString:@"getDeviceUUID()"]];
    
    NSLog(@"Device UUID: %@", [[T9Login sharedLogin] deviceUUID]);
}

- (void) startIndicator
{
    webView.scrollView.userInteractionEnabled = NO;
    webView.scrollView.alpha = 0.5;
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    CGRect indicatorFrame = CGRectMake(0, 0, indicator.frame.size.width, indicator.frame.size.height);
    indicatorFrame.origin.x = (self.view.frame.size.width - indicator.frame.size.width) / 2;
    indicatorFrame.origin.y = (self.view.frame.size.height - indicator.frame.size.height) / 2;
    indicator.frame = indicatorFrame;
    
    [self.view addSubview:indicator];
    [indicator startAnimating];
}

- (void) stopIndicator
{
    [indicator stopAnimating];
    [indicator removeFromSuperview];
    indicator = nil;
    
    webView.scrollView.userInteractionEnabled = YES;
    webView.scrollView.alpha = 1;
}

- (void) initiateConnectionToServer
{
    NSMutableURLRequest *request =
    [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://gambit.local:3000/portal"]
                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                        timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSLog(@"FIX ME %@", [[T9Login sharedLogin] deviceUUID]);
    NSString *postString = [NSString stringWithFormat:@"device_uuid=%@&app_uuid=%@", [[T9Login sharedLogin] deviceUUID], [[T9Login sharedLogin] appUUID]];
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    [webView setScalesPageToFit:YES];
    [webView setDelegate:self];
    [webView loadRequest:request];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self initiateConnectionToServer];
}

- (BOOL)webView:(UIWebView *)pWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"T9LoginViewController::Requested to load %@", request.URL.path);
    
    if ([request.URL.path isEqualToString:@"/"])
    {
        shouldHandleErrors = NO;
        [webView stopLoading];
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;
    } else
        return YES;
}

@end

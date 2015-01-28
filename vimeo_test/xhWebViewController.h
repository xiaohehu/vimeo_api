//
//  xhWebViewController.h
//  xhWebViewController
//
//  Created by Xiaohe Hu on 10/11/13.
//  Copyright (c) 2013 Xiaohe Hu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "Reachability.h"

@class Reachability;
@protocol ModalViewDelegate;

@interface xhWebViewController : UIViewController  <UIGestureRecognizerDelegate, UIWebViewDelegate>
{
    BOOL internetActive;
}
@property (nonatomic, retain) AppDelegate *appDelegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *ebTitle;

-(IBAction)socialButton:(NSString*)myTag;

-(IBAction)dismissModal;

-(void)checkWireless;

-(IBAction)webGoBack;

-(IBAction)webGoForward;

-(IBAction)webStop;

-(IBAction)webRefresh;

-(IBAction)callOutActSheet;

@end

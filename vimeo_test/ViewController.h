//
//  ViewController.h
//  vimeo_test
//
//  Created by Xiaohe Hu on 1/26/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OAConsumer.h"
#import "OAToken.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

@interface ViewController : UIViewController<UIWebViewDelegate>
{
    IBOutlet UIWebView *webview;
    OAConsumer* consumer;
    OAToken* requestToken;
    OAToken* accessToken;
}

@property (nonatomic, retain) IBOutlet UIWebView *webview;

@end


//
//  ViewController.m
//  vimeo_test
//
//  Created by Xiaohe Hu on 1/26/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSString *secrete;
}
@end

NSString *clientID;
NSString *Secret;
NSString *callback;

@implementation ViewController

@synthesize webview;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    clientID = @"0ac70ad344540ad2b340e85108ca1c87f1ebfc32";
    Secret = @"527e23916119d5b416a8ed967f04b5ddd2fe73df";
    callback  = @"vimeo://authorized";
    
    //[self connectTumblr];
    
    
    
    // call the authorize URL (https://api.vimeo.com/oauth/authorize)
    [self authorizeVimeo];
    
    
    
    
    
}


- (void)authorizeVimeo{
    NSLog(@"AUTHORIZE %@",@"authorized");
    
    //NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    //NSURL* authorizeUrl = [NSURL URLWithString:@"https://vimeo.com/oauth/authorize"];
    
    
    NSURL *theURL = [NSURL URLWithString:@"https://vimeo.com/oauth/authorize?response_type=code&client_id=0ac70ad344540ad2b340e85108ca1c87f1ebfc32&secret=527e23916119d5b416a8ed967f04b5ddd2fe73dfredirect_uri=vimeo://authorized&scope=public"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:theURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0f];
    [theRequest setHTTPMethod:@"POST"];
    
    //NSLog(@"RESPONSE: %@",theRequest);
    
    //NSString* jsonString = [[NSString alloc] initWithContentsOfFile:theRequest encoding:NSUTF8StringEncoding error:nil];
    
    NSURLResponse *theResponse = NULL;
    NSError *theError = NULL;
    NSData *theResponseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&theResponse error:&theError];
    NSString *theResponseString = [[NSString alloc] initWithData:theResponseData encoding:NSUTF8StringEncoding];
    
    NSLog(@"RESPONSE: %@",theResponseString);
    
    //[theRequest setValue:@"application/json-rpc" forHTTPHeaderField:@"Content-Type"];
    ////NSString *theBodyString = [[CJSONSerializer serializer] serializeDictionary:theRequestDictionary];
    //NSLog(@"%@", theBodyString);
    //NSData *theBodyData = [theBodyString dataUsingEncoding:NSUTF8StringEncoding];
    
}




-(void)connectTumblr {
    
    consumer = [[OAConsumer alloc] initWithKey:clientID secret:Secret];
    
    
    NSURL* requestTokenUrl = [NSURL URLWithString:@"https://vimeo.com/oauth/request_token"];
    
    OAMutableURLRequest* requestTokenRequest = [[OAMutableURLRequest alloc] initWithURL:requestTokenUrl
                                                                                consumer:consumer
                                                                                token:nil
                                                                                realm:callback
                                                                      signatureProvider:nil] ;
    
    OARequestParameter* callbackParam = [[OARequestParameter alloc] initWithName:@"oauth_callback" value:callback] ;
    [requestTokenRequest setHTTPMethod:@"POST"];
    [requestTokenRequest setParameters:[NSArray arrayWithObject:callbackParam]];
    OADataFetcher* dataFetcher = [[OADataFetcher alloc] init] ;
    [dataFetcher fetchDataWithRequest:requestTokenRequest
                             delegate:self
                            didFinishSelector:@selector(didReceiveRequestToken:data:)
                            didFailSelector:@selector(didFailOAuth:error:)];
    
}

- (void)didReceiveRequestToken:(OAServiceTicket*)ticket data:(NSData*)data {
    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    requestToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    NSURL* authorizeUrl = [NSURL URLWithString:@"https://vimeo.com/oauth/authorize"];
    OAMutableURLRequest* authorizeRequest = [[OAMutableURLRequest alloc] initWithURL:authorizeUrl
                                                                            consumer:nil
                                                                               token:nil
                                                                               realm:nil
                                                                   signatureProvider:nil];
    
    NSString* oauthToken = requestToken.key;
    OARequestParameter* oauthTokenParam = [[OARequestParameter alloc] initWithName:@"oauth_token" value:oauthToken] ;
    [authorizeRequest setParameters:[NSArray arrayWithObject:oauthTokenParam]];
    //  UIWebView* webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    //  webView.scalesPageToFit = YES;
    //  [[[UIApplication sharedApplication] keyWindow] addSubview:webView];
    webview.delegate = self;
    [webview loadRequest:authorizeRequest];
    
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if ([[[request URL] scheme] isEqualToString:@"vimeo"]) {
        // Extract oauth_verifier from URL query
        NSString* verifier = nil;
        NSArray* urlParams = [[[request URL] query] componentsSeparatedByString:@"&"];
        NSLog(@"the result is:\n %@", urlParams);
        for (NSString* param in urlParams) {
            NSArray* keyValue = [param componentsSeparatedByString:@"="];
            NSString* key = [keyValue objectAtIndex:0];
            if ([key isEqualToString:@"oauth_verifier"]) {
                verifier = [keyValue objectAtIndex:1];
                break;
            }
        }
        if (verifier) {
            NSURL* accessTokenUrl = [NSURL URLWithString:@"https://vimeo.com/oauth/access_token"];
            OAMutableURLRequest* accessTokenRequest = [[OAMutableURLRequest alloc] initWithURL:accessTokenUrl
                                                                                      consumer:consumer
                                                                                         token:requestToken
                                                                                         realm:nil
                                                                             signatureProvider:nil];
            
            OARequestParameter* verifierParam = [[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifier];
            [accessTokenRequest setHTTPMethod:@"POST"];
            [accessTokenRequest setParameters:[NSArray arrayWithObject:verifierParam]];
            OADataFetcher* dataFetcher = [[OADataFetcher alloc] init];
            [dataFetcher fetchDataWithRequest:accessTokenRequest
                                     delegate:self
                            didFinishSelector:@selector(didReceiveAccessToken:data:)
                            didFailSelector:@selector(didFailOAuth:error:)];
        } else {
            // ERROR!
            
        }
        [webView removeFromSuperview];
        return NO;
    }
    return YES;
}


- (void)didReceiveAccessToken:(OAServiceTicket*)ticket data:(NSData*)data {

    NSString* httpBody = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    accessToken = [[OAToken alloc] initWithHTTPResponseBody:httpBody];
    
    NSLog(@"The response is %@", accessToken);
    
//    NSString *OAuthKey = accessToken.key;    // HERE YOU WILL GET ACCESS TOKEN
//    NSString *OAuthSecret = accessToken.secret;  //HERE  YOU WILL GET SECRET TOKEN
//    secrete = [NSString stringWithString:OAuthSecret];
//    UIAlertView *alertView = [[UIAlertView alloc]
//                              initWithTitle:@"Vimeo TOken"
//                              message:OAuthKey
//                              delegate:nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil];
//    [alertView show];
    
//    webview.hidden = YES;
//    [self sendAPIRequist];
}

- (void)sendAPIRequist
{
    NSURL *url = [NSURL URLWithString:@"https://api.vimeo.com/me/videos"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"Authorization: bearer 8615512ccc84238fe73bd298f2df935a"forHTTPHeaderField:@"https://api.vimeo.com"];
    
    NSURLResponse *response;
    NSError *error;
    //send it synchronous
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    // check for an error. If there is a network error, you should handle it here.
    if(!error)
    {
        //log response
        NSLog(@"Response from server = %@", responseString);
    }
    NSLog(@"\nThe Data is:\n\n %@", responseString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

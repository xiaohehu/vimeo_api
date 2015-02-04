//
//  ViewController.m
//  vimeo_test
//
//  Created by Xiaohe Hu on 1/26/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "ViewController.h"
#import "xhWebViewController.h"
#import "galleryCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "AFNetworking.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIWebViewDelegate>
{
    NSMutableArray      *arr_rawData;
    int                 totalVideo;
    int                 pageNum;
    NSString            *video_src;
    __weak IBOutlet UIWebView *webview;
    __weak IBOutlet UICollectionView *theCollectionView;
}
@property (nonatomic, strong) MPMoviePlayerViewController       *playerViewController;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    arr_rawData = [[NSMutableArray alloc] init];
    webview.delegate = self;
    webview.hidden = YES;
    
    [theCollectionView registerClass:[galleryCell class] forCellWithReuseIdentifier:@"theCell"];
    theCollectionView.delegate = self;
    theCollectionView.dataSource = self;
    [theCollectionView reloadData];
    
    [self authorizeVimeo];
    
//    NSDictionary *dictionary = NSDictionary.FromObjectAndKey(new NSString("Mozilla/5.0 (" + (UIDevice.CurrentDevice.Model.Contains("iPad") ? "iPad" : "iPhone" ) +  "; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A403 Safari/8536.25"), new NSString("UserAgent"));
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)authorizeVimeo{
    NSLog(@"AUTHORIZE %@",@"authorized");
    
    
    // set the URL
    NSURL *url = [NSURL URLWithString:@"https://api.vimeo.com/me/videos"];
    //set up the request to be sent
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setURL:url];
//    [request setHTTPMethod:@"GET"];
    [request setValue:@"bearer 6bdf3f21e6319a1e2e55b35dac8654f5" forHTTPHeaderField:@"Authorization"];
//    [request setTimeoutInterval:30];
    
    // turn on the network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFJSONResponseSerializer serializer];
    op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.vimeo.video+json"];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"JSON: %@", responseObject);
        
        totalVideo = [[responseObject objectForKey: @"total"] integerValue];
        if (totalVideo % 25 > 0) {
            pageNum = totalVideo/25 + 1;
        }
        
        [self buildRawDataArray];
        [theCollectionView reloadData];

        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)buildRawDataArray
{
    // turn on the network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    for (int i = 0; i < pageNum; i++) {
        NSString *url = [NSString stringWithFormat:@"https://api.vimeo.com/me/videos?page=%i", i+1];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        [request setHTTPMethod:@"GET"];
        [request setValue:@"bearer 6bdf3f21e6319a1e2e55b35dac8654f5" forHTTPHeaderField:@"Authorization"];
        
        AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        op.responseSerializer = [AFJSONResponseSerializer serializer];
        op.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/vnd.vimeo.video+json"];
        [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSArray *arr_pageData = [NSArray arrayWithArray:[responseObject objectForKey:@"data"]];
            for (int j = 0; j < arr_pageData.count; j++) {
                [arr_rawData addObject: arr_pageData[j]];
            }

            [theCollectionView reloadData];
            // turn off the network indicator
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        [[NSOperationQueue mainQueue] addOperation:op];
    }

    // turn off the network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Collection Delegate Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arr_rawData.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
//    galleryCell *galleryImageCell = [collectionView
//                                       dequeueReusableCellWithReuseIdentifier:@"theCell" forIndexPath:indexPath];
    UICollectionViewCell *galleryImageCell = [collectionView
                                     dequeueReusableCellWithReuseIdentifier:@"theCell" forIndexPath:indexPath];


    NSDictionary *picture = [[arr_rawData objectAtIndex:indexPath.item] objectForKey:@"pictures"];
    NSArray *size = [picture objectForKey:@"sizes"];
    NSDictionary *theImage = [size objectAtIndex:0];
    NSString *link = [theImage objectForKey:@"link"];
//    UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link]]];
//    UIImageView *thumbUiiv = [[UIImageView alloc] initWithImage:thumbImage];
//    thumbUiiv.frame = galleryImageCell.bounds;
    UIImageView *thumbUiiv = [[UIImageView alloc] initWithFrame:galleryImageCell.bounds];
    [thumbUiiv sd_setImageWithURL:[NSURL URLWithString:link] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    [galleryImageCell addSubview: thumbUiiv];
//    galleryImageCell.cellThumb.image = thumbImage;
    
//    [galleryImageCell.cellThumb sd_setImageWithURL:[NSURL URLWithString:link]
//                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    return galleryImageCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *theLink = [[arr_rawData objectAtIndex: indexPath.item] objectForKey:@"link"];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:theLink]]];
//    NSLog(@"the link is \n%@", theLink);
//    webview.hidden = NO;
}

- (void)loadPlayerWeb
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    xhWebViewController *vc = (xhWebViewController*)[mainStoryboard instantiateViewControllerWithIdentifier:@"xhWebViewController"];
    [vc socialButton:video_src];
    vc.view.frame = self.view.bounds;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - WebView Delegate Methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"Loading: %@", [request URL]);
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    NSLog(@"didFinish: %@; stillLoading: %@", [[webView request]URL],
//          (webView.loading?@"YES":@"NO"));
    if (webview.loading) {
        // turn on the network indicator
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
    
    else {
        
        // turn off the network indicator
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.querySelector('div.cloaked > video').src;"];
//        NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.querySelector('div.flideo').innerHTML;"];
        NSLog(@"the link is \n %@", html);
        if (html) {
            video_src = nil;
            video_src = [[NSString alloc] initWithString:html];
            [self loadPlayerWeb];
//            _playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:video_src]];
//            _playerViewController.view.frame = self.view.bounds;//CGRectMake(0, 0, 1024, 768);
//            _playerViewController.view.alpha=1.0;
//            _playerViewController.moviePlayer.controlStyle = MPMovieControlStyleNone;
//            [_playerViewController.moviePlayer setAllowsAirPlay:YES];
//            _playerViewController.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//            [_playerViewController.moviePlayer play];
//            [self.view addSubview: _playerViewController.view];
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//    NSLog(@"didFail: %@; stillLoading: %@", [[webView request]URL],
//          (webView.loading?@"YES":@"NO"));
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

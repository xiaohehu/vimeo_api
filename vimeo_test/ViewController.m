//
//  ViewController.m
//  vimeo_test
//
//  Created by Xiaohe Hu on 1/26/15.
//  Copyright (c) 2015 Neoscape. All rights reserved.
//

#import "ViewController.h"
#import "xhWebViewController.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIWebViewDelegate>
{
    NSMutableArray      *arr_rawData;
    int                 totalVideo;
    int                 pageNum;
    NSString            *video_src;
    __weak IBOutlet UIWebView *webview;
    __weak IBOutlet UICollectionView *theCollectionView;
}
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    arr_rawData = [[NSMutableArray alloc] init];
    webview.delegate = self;
    webview.hidden = YES;
    
    [self authorizeVimeo];
    
    theCollectionView.delegate = self;
    theCollectionView.dataSource = self;
    [theCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"theCell"];
    [theCollectionView reloadData];
}

- (void)authorizeVimeo{
    NSLog(@"AUTHORIZE %@",@"authorized");
    
    
    // set the URL
    NSURL *url = [NSURL URLWithString:@"https://api.vimeo.com/me/videos"];
    
    //set up the request to be sent
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"bearer 6bdf3f21e6319a1e2e55b35dac8654f5" forHTTPHeaderField:@"Authorization"];
//    [request setTimeoutInterval:30];
    
    // turn on the network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    NSHTTPURLResponse   *response = nil;
    NSError         *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    SBJsonParser *jResponse = [[SBJsonParser alloc]init];
    NSDictionary *tokenData = [jResponse objectWithString:result];
    NSArray*keys=[tokenData allKeys];
    NSLog(@"RESULT: %@",keys);
    NSLog(@"\n\n %i", [[tokenData objectForKey: @"data"] count]);
    totalVideo = [[tokenData objectForKey: @"total"] integerValue];
    if (totalVideo % 25 > 0) {
        pageNum = totalVideo/25 + 1;
    }
    
    [self buildRawDataArray];
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
        NSHTTPURLResponse   *response = nil;
        NSError         *error = nil;
        NSData *pageData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *result = [[NSString alloc] initWithData:pageData encoding:NSUTF8StringEncoding];
        SBJsonParser *jResponse = [[SBJsonParser alloc]init];
        NSDictionary *tokenData = [jResponse objectWithString:result];
        NSArray *arr_pageData = [NSArray arrayWithArray:[tokenData objectForKey:@"data"]];
        for (int j = 0; j < arr_pageData.count; j++) {
            [arr_rawData addObject: arr_pageData[j]];
        }
    }
    
//    NSLog(@"The total item num is %@", arr_rawData[5]);

    // turn off the network indicator
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Collection Delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return arr_rawData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *galleryImageCell = [collectionView
                                       dequeueReusableCellWithReuseIdentifier:@"theCell" forIndexPath:indexPath];
    
    if (!galleryImageCell) {
        galleryImageCell = [[UICollectionViewCell alloc] init];
        NSDictionary *picture = [[arr_rawData objectAtIndex:indexPath.item] objectForKey:@"pictures"];
        NSArray *size = [picture objectForKey:@"sizes"];
        NSDictionary *theImage = [size objectAtIndex:0];
        NSString *link = [theImage objectForKey:@"link"];
        UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:link]]];
        UIImageView *thumbUiiv = [[UIImageView alloc] initWithImage:thumbImage];
        thumbUiiv.frame = galleryImageCell.bounds;
    }
    return galleryImageCell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *theLink = [[arr_rawData objectAtIndex: indexPath.item] objectForKey:@"link"];
    [webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:theLink]]];
    NSLog(@"the link is \n%@", theLink);
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
        
        NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.querySelector('div.flideo > video').src;"];
        NSLog(@"the link is \n %@", html);
        if (html) {
            video_src = nil;
            video_src = [[NSString alloc] initWithString:html];
            [self loadPlayerWeb];
        }
    }
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

//
//  xhWebViewController.m
//  xhWebViewController
//
//  Created by Xiaohe Hu on 10/11/13.
//  Copyright (c) 2013 Xiaohe Hu. All rights reserved.
//

#import "xhWebViewController.h"
#import "AppDelegate.h"
@interface xhWebViewController ()
@property (strong, nonatomic) NSString *urlAddress;
@property (nonatomic, strong) UIView   *uiv_login;

@end

@implementation xhWebViewController

@synthesize activityIndicator;
@synthesize webView, ebTitle, appDelegate;

- (BOOL)prefersStatusBarHidden {
    return YES;
}
-(void)viewWillAppear:(BOOL)animated {
	[self checkWireless];
	[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[activityIndicator setHidesWhenStopped:YES];
	
	UIToolbar* toolbar = [self createToolbar];
	[self.view addSubview:toolbar];
	
	UILabel* webTitle = [self createWebLabel];
	[self.view addSubview:webTitle];
	webTitle.text = self.title;
}

- (void)viewDidAppear:(BOOL)animated
{
    self.view.frame = self.view.superview.bounds;
    webView.frame = self.view.superview.bounds;
}

-(void) viewWillLayoutSubviews {
    self.view.frame = self.view.superview.bounds;
}

-(void)openAndClose:(id)sender
{
    UIButton *tappedBtn = sender;
    tappedBtn.selected = !tappedBtn.selected;
    if (tappedBtn.selected) {
        [UIView animateWithDuration:0.33 animations:^{
            _uiv_login.transform = CGAffineTransformMakeTranslation(-260, 0.0);
        }];
    }
    else {
        [UIView animateWithDuration:0.33 animations:^{
            _uiv_login.transform = CGAffineTransformIdentity;
        }];
    }
}

-(void)initInfo
{
    UIView *uiv_infoContainer = [[UIView alloc] initWithFrame:CGRectMake(40, 10, 250, 85)];
    uiv_infoContainer.backgroundColor = [UIColor lightGrayColor];
    [_uiv_login addSubview: uiv_infoContainer];
    
    UILabel *uil_name = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 0.0, 80.0, 30.0)];
    [uil_name setText:@"Username:"];
    [uil_name setFont:[UIFont systemFontOfSize:13]];
    [uiv_infoContainer addSubview: uil_name];
    
    UILabel *uil_pass = [[UILabel alloc] initWithFrame:CGRectMake(3.0, 50.0, 80.0, 30.0)];
    [uil_pass setText:@"Password: "];
    [uil_pass setFont:[UIFont systemFontOfSize:13]];
    [uiv_infoContainer addSubview: uil_pass];
    
    UITextView *uitv_account = [[UITextView alloc] initWithFrame:CGRectMake(88, 5, 120, 30)];
    [uitv_account setText:@"PCampot_boston"];
    [uitv_account setFont:[UIFont systemFontOfSize:13]];
    uitv_account.userInteractionEnabled = YES;
    uitv_account.editable = NO;
    [uiv_infoContainer addSubview: uitv_account];
    
    UITextView *uitv_pass = [[UITextView alloc] initWithFrame:CGRectMake(88, 45, 120, 30)];
    [uitv_pass setText:@"suffolk1"];
    [uitv_pass setFont:[UIFont systemFontOfSize:13]];
    uitv_pass.userInteractionEnabled = YES;
    uitv_pass.editable = NO;
    [uiv_infoContainer addSubview: uitv_pass];
}

-(UILabel*)createWebLabel
{
	UILabel *webTitle = [[UILabel alloc] initWithFrame:CGRectMake(354, 4, 512, 46)];
	[webTitle setFont:[UIFont fontWithName:@"Futura" size:15]];
	[webTitle setTextAlignment:NSTextAlignmentCenter];
	float viewWidth = self.view.frame.size.width;
	//float viewHeight = self.view.frame.size.height;
	float labelWidth = webTitle.frame.size.width;
	float labelHeight = webTitle.frame.size.height;
	
	float xpos = (viewWidth/2.0f) - (labelWidth/2.0f);
	//float ypos = (viewHeight/2.0f) - (labelHeight/2.0f);
	
	[webTitle setFrame:CGRectMake(xpos,0,labelWidth,labelHeight)];
	
	return webTitle;
}

- (UIToolbar*)createToolbar
{
    UIToolbar* toolbar = [[UIToolbar alloc] init];
    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
	
	// buttons
	UIBarButtonItem *closeButton =[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				target:self
																				action:@selector(dismissModal)];
	UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																				target:self
																				action:nil];
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"<"
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(webGoBack)];
	UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithTitle:@">"
																	  style:UIBarButtonItemStylePlain
																	 target:self
																	 action:@selector(webGoForward)];
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																				   target:self
																				   action:@selector(webRefresh)];
	UIBarButtonItem *stopButton = [[UIBarButtonItem alloc] initWithTitle:@"X"
																   style:UIBarButtonItemStylePlain
																  target:self
																  action:@selector(webStop)];
	
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
																				 target:self
																				 action:@selector(callOutActSheet)];
	
    NSArray *buttonItems = [NSArray arrayWithObjects:closeButton,flexButton,backButton,forwardButton,refreshButton,stopButton, shareButton,nil];
    [toolbar setItems:buttonItems];
    return toolbar;
}

-(void)checkWireless {
    
	appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
//    NSLog(@"Reading as %@", appDelegate.isWirelessAvailable);
    
    if ([appDelegate.isWirelessAvailable isEqualToString:@"NO"]) {
        NSLog(@"Wireless NO");
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Status"
														message:@"A network connection is required to view this website. Please check your internet connection and try again."
													   delegate:self
											  cancelButtonTitle:@"OK"
											  otherButtonTitles: nil];
        [alert show];
    } else if ([appDelegate.isWirelessAvailable isEqualToString:@"YES"]) {
        NSLog(@"Wireless YES");
    }
}

-(IBAction)socialButton:(NSString*)myTag;
{
	
	NSLog(@"load %@", myTag);
	CGRect webFrame = CGRectMake(0.0, 44.0, 1024.0, 724.0);
	webView = [[UIWebView alloc] initWithFrame:webFrame];
    webView.frame = self.view.bounds;
	[webView setBackgroundColor:[UIColor blackColor]];
	webView.delegate = self;
	webView.scalesPageToFit=YES;
	_urlAddress = myTag;
	NSURL *url = [NSURL URLWithString:_urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[webView loadRequest:requestObj];
	[self.view addSubview:webView];
	[webView addSubview:activityIndicator];
}

-(IBAction)callOutActSheet
{
    NSString* someText = _urlAddress;
    NSArray *dataShare = [[NSArray alloc] initWithObjects:someText, nil];
    UIActivityViewController* activityViewController =
    [[UIActivityViewController alloc] initWithActivityItems:dataShare
                                      applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:^{}];
}

-(IBAction)webGoBack
{
	if ([webView canGoBack]) {
		[webView goBack];
	}
}

-(IBAction)webGoForward
{
	if ([webView canGoForward]) {
		[webView goForward];
	}
}

-(IBAction)webStop
{
    [webView stopLoading];
}

-(IBAction)webRefresh
{
	[webView reload];
}

-(IBAction)dismissModal {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"showNaviBtn" object:self];
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (void)webViewDidStartLoad:(UIWebView *)webPage
{
	[activityIndicator startAnimating];
	NSLog(@"start animating");
}

- (void)webViewDidFinishLoad:(UIWebView *)webPage
{
	[activityIndicator stopAnimating];
	NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	ebTitle.text = theTitle;
	NSLog(@"STOP animating");
    
    NSString*  jScriptString1 = [NSString stringWithFormat:@"(document.getElementById('oAuthFrame').contentWindow).document.forms[0].elements['user_username'].value = 'PCampot_boston';"];
    NSString*  jScriptString2 = [NSString stringWithFormat:@"(document.getElementById('oAuthFrame').contentWindow).document.forms[0].elements['user_password'].value = 'suffolk1';"];
    //NSString*  jScriptString2 = [NSString stringWithFormat:@"document.getElementById('user_password').value='suffolk1'"];
    [webPage stringByEvaluatingJavaScriptFromString:jScriptString1];
    [webPage stringByEvaluatingJavaScriptFromString:jScriptString2];
}

- (void)webPage:(UIWebView *)webPages didFailLoadWithError:(NSError *)error
{
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><br /><br /><font size=+5 color='red'>Error<br /><br />Your request %@</font></center></html>",
							 error.localizedDescription];
	[webPages loadHTMLString:errorString baseURL:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft | interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

-(void)viewDidUnload {
	[self setTitle:nil];
}

-(void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}


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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

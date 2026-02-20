//
//  WKWebViewController.m
//  B a n e c t i
//
//  Created by Mourad BRAHIM on 16/09/2021.
//

#import "WKWebViewController.h"
#import <WebKit/WKPreferences.h>
#import <WebKit/WKWebViewConfiguration.h>
#import <WebKit/WKWebpagePreferences.h>

@implementation WKWebViewController

- (instancetype)initWithURL:(NSURL *)url navigationDelegate:(id<WKNavigationDelegate>)navigationDelegate uiDelegate:(id<WKUIDelegate>)uiDelegate {
    if (self = [super init]) {
        _url = url;
        
        if (@available(iOS 14.0, *)) {
            self.webView = [[WKWebView alloc] initWithFrame:CGRectZero];
            self.webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = YES;
        } else {
            WKPreferences *preferences = [[WKPreferences alloc] init];
            preferences.javaScriptEnabled = YES;
            WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
            configuration.preferences = preferences;
            self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
        }
        self.webView.navigationDelegate = navigationDelegate;
        self.webView.UIDelegate = uiDelegate;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (![self.view.subviews containsObject:self.webView]) {
        [self.view addSubview:self.webView];
        // Load request
        [self.webView loadRequest:[NSURLRequest requestWithURL:_url]];
    }
    [UIViewController attemptRotationToDeviceOrientation];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    //
    self.webView.frame = self.view.bounds;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Helpers : Create/Show/Hide Activity Indicator

-(void)createActivityView {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, self.activityIndicator.frame.size.width,  self.activityIndicator.frame.size.height)];
    [self.activityIndicator setActivityIndicatorViewStyle: UIActivityIndicatorViewStyleWhiteLarge];
    [self.activityIndicator setColor:[UIColor orangeColor]];
    [self.view addSubview:self.activityIndicator];
    self.activityIndicator.center = CGPointMake(self.view.frame.size.width  / 2,
                                                self.view.frame.size.height / 2);
}

-(void)startActivityIndicator {
    [self createActivityView];
    [self.activityIndicator startAnimating];
}

-(void)stopActivityIndicator {
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
}

@end

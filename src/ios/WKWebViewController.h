//
//  WKWebViewController.h
//  B a n e c t i
//
//  Created by Mourad BRAHIM on 16/09/2021.
//

#import <UIKit/UIKit.h>
#import <WebKit/WKWebView.h>

NS_ASSUME_NONNULL_BEGIN

@interface WKWebViewController : UIViewController

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic) id<WKNavigationDelegate> navigationDelegate;

- (instancetype)initWithURL:(NSURL *)url navigationDelegate:(id<WKNavigationDelegate>)navigationDelegate uiDelegate:(id<WKUIDelegate>)uiDelegate;

-(void)createActivityView;
-(void)startActivityIndicator;
-(void)stopActivityIndicator;
@end

NS_ASSUME_NONNULL_END

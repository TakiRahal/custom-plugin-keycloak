// BankeriseKeycloakAuthentication.m

#import "BankeriseKeycloakAuthentication.h"
#import "WKWebViewController.h"
#import <WebKit/WKNavigationAction.h>
#import <WebKit/WKWebViewConfiguration.h>
#import <WebKit/WKWindowFeatures.h>

@interface BankeriseKeycloakAuthentication ()

@property (nonatomic, strong) WKWebViewController *vc;
@property (nonatomic, copy) NSString *scheme;

@end

@implementation BankeriseKeycloakAuthentication

@synthesize vc;
@synthesize scheme;

- (void) isAvailable:(CDVInvokedUrlCommand*)command {
  bool avail = NSClassFromString(@"WKWebViewController") != nil;
  CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:avail];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void) show:(CDVInvokedUrlCommand*)command {
  NSDictionary* options = [command.arguments objectAtIndex:0];
  NSString* urlString = options[@"url"];
  if (urlString == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"url can't be empty"] callbackId:command.callbackId];
    return;
  }
  if (![[urlString lowercaseString] hasPrefix:@"http"]) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"url must start with http or https"] callbackId:command.callbackId];
    return;
  }
  NSURL *url = [NSURL URLWithString:urlString];
  if (url == nil) {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"bad url"] callbackId:command.callbackId];
    return;
  }
  self.animated = [options[@"animated"] isEqual:[NSNumber numberWithBool:YES]];
  self.scheme = options[@"scheme"];
  self.callbackId = command.callbackId;

  vc = [[WKWebViewController alloc] initWithURL:url navigationDelegate:self uiDelegate:self];

  bool hidden = [options[@"hidden"] isEqualToNumber:[NSNumber numberWithBool:YES]];
  if (hidden) {
    vc.view.userInteractionEnabled = NO;
    vc.view.alpha = 0.05;
    [self.viewController addChildViewController:vc];
    [self.viewController.view addSubview:vc.view];
    [vc didMoveToParentViewController:self.viewController];
    vc.view.frame = CGRectMake(0.0, 0.0, 0.5, 0.5);
  } else {
    if (self.animated) {
      // note that Apple dropped support for other animations in iOS 9.2 or 9.3 in favor of a slide-back gesture
      vc.modalTransitionStyle = [self getTransitionStyle];
      vc.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [self.viewController presentViewController:vc animated:self.animated completion:nil];
  }

  CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"opened"}];
  [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (UIModalTransitionStyle) getTransitionStyle {
    return UIModalTransitionStyleCoverVertical;
}

- (void) hide:(CDVInvokedUrlCommand*)command {
  WKWebViewController *childVc = [self.viewController.childViewControllers lastObject];
  if (childVc != nil) {
    [childVc willMoveToParentViewController:nil];
    [childVc.view removeFromSuperview];
    [childVc removeFromParentViewController];
    childVc = nil;
  }
  
  if (vc != nil) {
      __weak BankeriseKeycloakAuthentication *weakSelf = self;
      [self.viewController dismissViewControllerAnimated:self.animated completion:^{
          weakSelf.vc = nil;
      }];
  }

  [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"closed"}] callbackId:command.callbackId];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [self.vc startActivityIndicator];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.vc stopActivityIndicator];
    if ([webView.URL.absoluteString isEqualToString:vc.url.absoluteString]) {
        //Invoked when the loading of the URL that you pass to initializer completes.
        //It is not invoked for any subsequent page loads.
        if (self.callbackId != nil) {
          CDVPluginResult * pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:@{@"event":@"loaded"}];
          [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
          [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        }
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error{
    [self.vc stopActivityIndicator];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    if ([url.scheme isEqualToString:self.scheme] && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            //
        }];
        decisionHandler(WKNavigationActionPolicyCancel);

        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - WKUIDelegate
- (nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    WKWebView *aWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:configuration];
    aWebView.navigationDelegate = self;
    [self.vc.view addSubview:aWebView];
    [aWebView loadRequest:[NSURLRequest requestWithURL:navigationAction.request.URL]];
    
    return aWebView;
}

@end

#import <Cordova/CDVPlugin.h>
#import <WebKit/WKNavigationDelegate.h>
#import <WebKit/WKUIDelegate.h>

@interface BankeriseKeycloakAuthentication : CDVPlugin <WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, copy) NSString *callbackId;
@property (nonatomic) bool animated;

- (void) isAvailable:(CDVInvokedUrlCommand *)command;
- (void) show:(CDVInvokedUrlCommand *)command;
- (void) hide:(CDVInvokedUrlCommand *)command;

@end

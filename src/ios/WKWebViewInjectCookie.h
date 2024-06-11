#import <Cordova/CDV.h>

@interface WKWebViewInjectCookie : CDVPlugin

- (void)setCookie:(CDVInvokedUrlCommand *)command;
- (void)getCookies:(CDVInvokedUrlCommand *)command;

@property (nonatomic, strong) NSString* callbackId;

@end
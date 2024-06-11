#import "WKWebViewInjectCookie.h"
#import <WebKit/WebKit.h>
#import <Cordova/CDV.h>

@implementation WKWebViewInjectCookie

- (void)setCookie:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;

    NSString *domain = command.arguments[0];
    NSString *path = command.arguments[1];
    NSString *name = command.arguments[2];
    NSString *value = command.arguments[3];
    NSString *expire = command.arguments[4];
    NSString *secure = command.arguments[5];
    NSString *maxAge = command.arguments[6];

    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];

    WKWebView* wkWebView = (WKWebView*) self.webView;

    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:name forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:path forKey:NSHTTPCookiePath];
    if ([secure boolValue]) {
        [cookieProperties setObject:@"TRUE" forKey:NSHTTPCookieSecure];
    }
    [cookieProperties setObject:maxAge forKey:NSHTTPCookieMaximumAge];

    @try {
        if (![expire isEqual:[NSNull null]]) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
            NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            [formatter setLocale:posix];
            NSDate *date = [formatter dateFromString:expire];
            [cookieProperties setObject:date forKey:NSHTTPCookieExpires];
        }

        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];

        if (@available(iOS 11.0, *)) {
            [wkWebView.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{
                NSLog(@"Cookie set successfully for iOS 11+");
            }];
        } else {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }

    } @catch(NSException *e) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Unknown exception"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
        return;
    }

    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
}

- (void)getCookies:(CDVInvokedUrlCommand *)command {
    self.callbackId = command.callbackId;

    NSString *url = [command.arguments objectAtIndex:0];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZZ"];
    [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];

    WKHTTPCookieStore *cookieStore = [WKWebsiteDataStore defaultDataStore].httpCookieStore;

    [cookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull allCookies) {
        NSMutableArray<NSDictionary*> *array = [NSMutableArray array];

        for (NSHTTPCookie *cookie in allCookies) {
            if (url == nil || [url length] == 0 || [url rangeOfString:cookie.domain].location != NSNotFound) {
                NSDictionary *item = @{
                    @"domain": cookie.domain,
                    @"expireDate": (cookie.expiresDate ? [dateFormatter stringFromDate:cookie.expiresDate] : [NSNull null]),
                    @"name": cookie.name,
                    @"path": cookie.path,
                    @"HTTPOnly": @(cookie.HTTPOnly),
                    @"sessionOnly": @(cookie.sessionOnly),
                    @"value": cookie.value
                };
                [array addObject:item];
            }
        }

        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array] callbackId:command.callbackId];
    }];
}

@end

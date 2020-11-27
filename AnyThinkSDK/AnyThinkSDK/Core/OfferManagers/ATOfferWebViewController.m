//
//  ATOfferWebViewController.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/9/30.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferWebViewController.h"
#import <WebKit/WebKit.h>
#import "Utilities.h"

@interface ATOfferWebViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *web;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIButton *forwardBtn;

@end

@implementation ATOfferWebViewController

- (WKWebView *)webView {
    
    if (_web == nil) {
        WKWebViewConfiguration *config = [WKWebViewConfiguration new];
        _web = [[WKWebView alloc]initWithFrame:self.view.bounds configuration:config];
        _web.navigationDelegate = self;
        _web.UIDelegate = self;
    }
    return  _web;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.urlString = [self.urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self.view addSubview: self.webView];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    NSURL *url = [[NSURL alloc]initWithString: self.urlString];
    if (url != nil) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    
    [self.navigationController setToolbarHidden:NO animated:YES];
    [self setupBarbuttons];

    [self.web addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.web addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    
    self.navigationController.toolbar.barTintColor = [UIColor whiteColor];
}

- (void)setupBarbuttons {
    
    CGFloat width = 48;
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _backBtn.frame = CGRectMake(0, 0, width, width);
    [_backBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_goback_normal@3x"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_goback_hl"] forState:UIControlStateHighlighted];
    _backBtn.imageView.contentMode = UIViewContentModeCenter;
    [_backBtn addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc]initWithCustomView:_backBtn];
    
    _forwardBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _forwardBtn.frame = CGRectMake(0, 0, width, width);
    [_forwardBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_forward_normal@3x"] forState:UIControlStateNormal];
    [_forwardBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_forward_hl"] forState:UIControlStateHighlighted];
    _forwardBtn.imageView.contentMode = UIViewContentModeCenter;
    [_forwardBtn addTarget:self action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc]initWithCustomView:_forwardBtn];

    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshBtn.frame = CGRectMake(0, 0, width, width);
    [refreshBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_refresh@3x"] forState:UIControlStateNormal];
    [refreshBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_refresh_hl"] forState:UIControlStateHighlighted];
    refreshBtn.imageView.contentMode = UIViewContentModeCenter;
    [refreshBtn addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *refreshItem = [[UIBarButtonItem alloc]initWithCustomView:refreshBtn];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, width, width);
    [closeBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_close@3x"] forState:UIControlStateNormal];
    [closeBtn setImage:[UIImage anythink_imageWithName:@"icon_webview_close_hl"] forState:UIControlStateHighlighted];

    closeBtn.imageView.contentMode = UIViewContentModeCenter;
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc]initWithCustomView:closeBtn];

    NSArray *items = @[
        [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
        backItem,
        [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
        forwardItem,
        [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
        refreshItem,
        [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL],
        closeItem,
        [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL]
    ];
    [self setToolbarItems:items animated:YES];
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    BOOL condition = [change[@"new"] integerValue] == 1;
    if ([keyPath isEqualToString:@"canGoBack"]) {
        
        UIImage *image = [UIImage anythink_imageWithName:condition ? @"icon_webview_goback@3x": @"icon_webview_goback_normal@3x"];
        [_backBtn setImage:image forState:UIControlStateNormal];

        return;
    }
    
    if ([keyPath isEqualToString:@"canGoForward"]) {
        UIImage *image = [UIImage anythink_imageWithName:condition ? @"icon_webview_forward@3x": @"icon_webview_forward_normal@3x"];
        [_forwardBtn setImage:image forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [self.web removeObserver:self forKeyPath:@"canGoBack"];
    [self.web removeObserver:self forKeyPath:@"canGoForward"];
}
// MARK:- actions

- (void)goBack {
    [self.web goBack];
}

- (void)goForward {
    [self.web goForward];
}

- (void)close {
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)refresh {
    [self.web reload];
}
// MARK:- web navigation delegate

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    if ([webView.URL.absoluteString containsString:@"apps.apple.com"] ||
        [webView.URL.absoluteString containsString:@"itunes.apple.com"]) {
        
        [[UIApplication sharedApplication] openURL:webView.URL];
        return;
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.navigationItem.title = webView.title;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if(navigationAction.targetFrame == nil){
        [webView loadRequest:navigationAction.request];
    }
    if (![[navigationAction.request.URL scheme] isEqualToString:@"https"] &&
        ![[navigationAction.request.URL scheme] isEqualToString:@"http"] &&
        ![[navigationAction.request.URL scheme] isEqualToString:@"about"]) {
        UIApplication *application = [UIApplication sharedApplication];
        if ([application openURL:navigationAction.request.URL]) {
            
        }else {
            [application openURL:[NSURL URLWithString:self.storeUrlStr]];
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

// MARK:- wk ui delegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    if(navigationAction.targetFrame.isMainFrame == NO) {
        [webView loadRequest: navigationAction.request];
    }
    return nil;
}
@end

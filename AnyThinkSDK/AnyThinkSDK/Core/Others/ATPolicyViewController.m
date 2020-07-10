//
//  ATPolicyViewController.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 18/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATPolicyViewController.h"
#import "ATAPI.h"
#import "ATAppSettingManager.h"
#import "Utilities.h"
#import <WebKit/WebKit.h>
@interface ATPolicyViewController ()<WKNavigationDelegate>
@property(nonatomic, readonly) UIButton *closeButton;
@property(nonatomic, readonly) WKWebView *webView;
@property(nonatomic, readonly) UIImageView *loadingImageView;
@property(nonatomic, readonly) UIButton *refreshButton;
@property(nonatomic, readonly) UIButton *declineButton;
@property(nonatomic, readonly) UIButton *agreeButton;
@property(nonatomic, readonly) UILabel *descLabel;

@property(nonatomic, readonly) NSMutableArray<NSLayoutConstraint*>* landscapeConstraints;
@property(nonatomic, readonly) NSMutableArray<NSLayoutConstraint*>* portraitConstraints;
@end

@implementation ATPolicyViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initSubviews];
    [self makeSubviewsForSubviews];
}

-(void) closeButtonTapped {
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.dismissalCallback != nil) { self.dismissalCallback(); }
    }];
}

-(void) declineButtonTapped {
    [[ATAPI sharedInstance] setDataConsentSet:ATDataConsentSetNonpersonalized consentString:nil];
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.dismissalCallback != nil) { self.dismissalCallback(); }
    }];
}

-(void) agreeButtonTapped {
    [[ATAPI sharedInstance] setDataConsentSet:ATDataConsentSetPersonalized consentString:nil];
    [self dismissViewControllerAnimated:YES completion:^(void) {
        if (self.dismissalCallback != nil) { self.dismissalCallback(); }
    }];
}

-(void) refreshButtonTapped {
    _refreshButton.hidden = YES;
    [self startLoadingAnimation];
    [_webView reload];
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [self startLoadingAnimation];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    _refreshButton.hidden = !(_loadingImageView.hidden = YES);
    [_loadingImageView.layer removeAllAnimations];
    if (_loadingFailureCallback != nil) { _loadingFailureCallback(error); }
    
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [_loadingImageView.layer removeAllAnimations];
    _loadingImageView.hidden = YES;
    
}
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    if ([ATAppSettingManager sharedManager].currentSetting[kATAppSettingGDPRPolicyURLKey] == nil || [navigationAction.request.URL.absoluteString isEqualToString:[ATAppSettingManager sharedManager].currentSetting[kATAppSettingGDPRPolicyURLKey]]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Open this link with Safari:" message:navigationAction.request.URL.absoluteString preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:navigationAction.request.URL options:nil completionHandler:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
        decisionHandler(WKNavigationActionPolicyCancel);
    }

}


-(void) startLoadingAnimation {
    _loadingImageView.hidden = NO;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0;
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 1;
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    [_loadingImageView.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void) setPolicyPageURL:(NSURL *)policyPageURL {
    _policyPageURL = policyPageURL;
    [_webView loadRequest:[NSURLRequest requestWithURL:_policyPageURL]];
}

-(void) initSubviews {
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_closeButton setImage:[UIImage anythink_imageWithName:@"icon_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    _closeButton.hidden = YES;
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    _webView = [[WKWebView alloc] initWithFrame:self.view.frame configuration:config];
    _webView.backgroundColor = [UIColor whiteColor];
    _webView.translatesAutoresizingMaskIntoConstraints = NO;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [_webView loadRequest:[NSURLRequest requestWithURL:_policyPageURL]];
    
    _loadingImageView = [[UIImageView alloc] init];
    _loadingImageView.translatesAutoresizingMaskIntoConstraints = NO;
    _loadingImageView.image = [UIImage anythink_imageWithName:@"icon_loading"];
    [self.view addSubview:_loadingImageView];
    
    _refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_refreshButton addTarget:self action:@selector(refreshButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [_refreshButton setImage:[UIImage anythink_imageWithName:@"icon_refresh"] forState:UIControlStateNormal];
    [self.view addSubview:_refreshButton];
    _refreshButton.hidden = YES;
    
    _declineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_declineButton addTarget:self action:@selector(declineButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _declineButton.translatesAutoresizingMaskIntoConstraints = NO;
    [_declineButton setAttributedTitle:^NSAttributedString*{
        return [[NSAttributedString alloc] initWithString:@"No, thanks" attributes:@{
                                                                                     NSFontAttributeName:[UIFont systemFontOfSize:15.0f],
                                                                                     NSForegroundColorAttributeName:[UIColor blackColor],
                                                                                     NSUnderlineColorAttributeName:[UIColor blackColor],
                                                                                     NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
                                                                                     }];
    }() forState:UIControlStateNormal];
    
    [self.view addSubview:_declineButton];
    
    _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_agreeButton addTarget:self action:@selector(agreeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    _agreeButton.translatesAutoresizingMaskIntoConstraints = NO;
    _agreeButton.layer.cornerRadius = 20.0f;
    _agreeButton.backgroundColor = _agreeButton.tintColor;
    [_agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _agreeButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [_agreeButton setTitle:@"Yes, I Agree" forState:UIControlStateNormal];
    [self.view addSubview:_agreeButton];
    
    _descLabel = [[UILabel alloc] init];
    _descLabel.numberOfLines = 2;
    _descLabel.translatesAutoresizingMaskIntoConstraints = NO;
    _descLabel.font = [UIFont systemFontOfSize:12.0f];
    _descLabel.textColor = [UIColor grayColor];
    _descLabel.text = @"I understand that I will still see ads, but they may not be as relevant to my interests.";
    [self.view addSubview:_descLabel];
}

-(void) makeSubviewsForSubviews {
    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_closeButton, _webView, _declineButton, _agreeButton, _descLabel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"[_closeButton(25)]-15-|" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[_closeButton(25)][_webView]" options:0 metrics:nil views:viewsDict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[_webView]-30-|" options:0 metrics:nil views:viewsDict]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_refreshButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_refreshButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_loadingImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_loadingImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:_webView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:.0f]];
    
    _portraitConstraints = [NSMutableArray<NSLayoutConstraint*> array];
    [_portraitConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_webView]-30-[_agreeButton(40)]-20-[_declineButton(40)]-15-[_descLabel]-25-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:nil views:viewsDict]];
    
    _landscapeConstraints = [NSMutableArray<NSLayoutConstraint*> array];
    [_landscapeConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|-30-[_declineButton]-20-[_agreeButton(_declineButton)]-30-|" options:NSLayoutFormatAlignAllTop metrics:nil views:viewsDict]];
    [_landscapeConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_declineButton]-10-[_descLabel]-10-|" options:NSLayoutFormatAlignAllLeading | NSLayoutFormatAlignAllTrailing metrics:nil views:viewsDict]];
    [_landscapeConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_webView]-35-[_agreeButton(40)]" options:0 metrics:nil views:viewsDict]];
}

-(BOOL) prefersStatusBarHidden {
    return YES;
}

-(void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation)) {
        [NSLayoutConstraint deactivateConstraints:_landscapeConstraints];
        [NSLayoutConstraint activateConstraints:_portraitConstraints];
    } else {
        [NSLayoutConstraint deactivateConstraints:_portraitConstraints];
        [NSLayoutConstraint activateConstraints:_landscapeConstraints];
    }
}
@end

//
//  ATMyOfferProgressHud.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/10/8.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferProgressHud.h"

@interface ATMyOfferProgressHud ()
@property (nonatomic)UIActivityIndicatorView *indicatorView;

@end
@implementation ATMyOfferProgressHud

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.indicatorView.frame = frame;
    }
    return self;
}
//Method 1 :
+(void)showProgressHud:(UIView *)view {
    ATMyOfferProgressHud *hud = [[ATMyOfferProgressHud alloc]initWithFrame:view.frame];
    hud.indicatorView.center = view.center;
    [hud.indicatorView startAnimating];
    [hud addSubview:hud.indicatorView];
    [view addSubview:hud];
}

+(void)hideProgressHud:(UIView *)view {
    ATMyOfferProgressHud *hud = [self hudForView:view];
    if (hud != nil) {
        [hud.indicatorView stopAnimating];
        [hud removeFromSuperview];
    }
}

+(ATMyOfferProgressHud *)hudForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            ATMyOfferProgressHud *hud = (ATMyOfferProgressHud *)subview;
            return hud;
        }
    }
    return nil;
}
//Method 2:
+(instancetype)showProgressHudWithView:(UIView *)view {
    ATMyOfferProgressHud *hud = [[ATMyOfferProgressHud alloc]initWithFrame:view.frame];
    hud.indicatorView.center = view.center;
    [hud.indicatorView startAnimating];
    [hud addSubview:hud.indicatorView];
    [view addSubview:hud];
    return hud;
}

-(void)hiddenProgressHud {
    [self.indicatorView stopAnimating];
    [self removeFromSuperview];
}

@end

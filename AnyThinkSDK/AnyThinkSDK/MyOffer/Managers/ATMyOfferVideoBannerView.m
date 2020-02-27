//
//  ATMyOfferVideoBannerView.m
//  AnyThinkMyOffer
//
//  Created by Topon on 2019/9/27.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferVideoBannerView.h"

@interface ATMyOfferVideoBannerView ()

@end
@implementation ATMyOfferVideoBannerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.8];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self layoutView];
    }
    return self;
}

-(void)layoutView {
    [self addSubview:self.iconImage];
    [self addSubview:self.title];
    [self addSubview:self.desc];
    [self addSubview:self.ctaButton];
    [self addSubview:self.logoImage];
    
}

+(ATMyOfferVideoBannerView *)bannerForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            ATMyOfferVideoBannerView *banner = (ATMyOfferVideoBannerView *)subview;
            return banner;
        }
    }
    return nil;
}
-(UIButton *)ctaButton {
    if (!_ctaButton) {
        _ctaButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 140, self.frame.size.height/2 - 15, 130, 30)];
        [_ctaButton setBackgroundColor:[UIColor colorWithRed:110.0/255.0 green:171.0/255.0 blue:49.0/255.0 alpha:1]];
        _ctaButton.layer.cornerRadius = 5;
        _ctaButton.layer.masksToBounds = YES;
        _ctaButton.titleLabel.font = [UIFont fontWithName:@"Source Han Sans CN" size:15];
    }
    return _ctaButton;
}

-(UIImageView *)iconImage {
    if (!_iconImage) {
        _iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(11, self.frame.size.height/2 - 25.5, 51, 51)];
        
    }
    return _iconImage;
}
-(UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc]initWithFrame:CGRectMake(70,15,self.frame.size.width - 220, 20)];
        [_title setTextColor:[UIColor colorWithRed:42.0/255.0 green:45.0/255.0 blue:52.0/255.0 alpha:1]];
        [_title setFont:[UIFont systemFontOfSize:15]];
        _title.textAlignment = NSTextAlignmentLeft;
    }
    return _title;
}
-(UILabel *)desc {
    if (!_desc) {
        _desc = [[UILabel alloc]initWithFrame:CGRectMake(70,45,self.frame.size.width - 220, self.frame.size.height - 70)];
        [_desc setTextColor:[UIColor colorWithRed:42.0/255.0 green:45.0/255.0 blue:52.0/255.0 alpha:1]];
        [_desc setFont:[UIFont systemFontOfSize:12]];
        _desc.textAlignment = NSTextAlignmentLeft;
        _desc.backgroundColor = [UIColor clearColor];
        _desc.userInteractionEnabled = NO;
    }
    return _desc;
}
-(UIImageView *)logoImage {
    if (!_logoImage) {
        _logoImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 51, self.frame.size.height/2 + 20, 36, 10)];
    }
    return _logoImage;
}

@end

//
//  ATMyOfferVideoBannerView.m
//  AnyThinkMyOffer
//
//  Created by Topon on 2019/9/27.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATOfferVideoBannerView.h"
#import "Utilities.h"

@interface ATOfferVideoBannerView ()
@property (nonatomic , readonly)ATOfferModel *offerModel;

@end
@implementation ATOfferVideoBannerView

- (instancetype)initWithFrame:(CGRect)frame offerModel:(ATOfferModel*)offerModel{
    self = [super initWithFrame:frame];
    if (self) {
        _offerModel = offerModel;
        self.backgroundColor = [UIColor colorWithRed:255.0/255 green:255.0/255 blue:255.0/255 alpha:0.8];
        self.layer.cornerRadius = 10;
        self.layer.masksToBounds = YES;
        [self layoutView];
    }
    return self;
}

- (BOOL)showCtaBtn {
    return [Utilities isEmpty:self.offerModel.CTA] == NO;
}

-(void)layoutView {
    if(self.iconImage != nil){
        [self addSubview:self.iconImage];
    }
    if(self.desc != nil){
        [self addSubview:self.desc];
    }
    
    [self addSubview:self.title];
    
    if (self.showCtaBtn) {
        [self addSubview:self.ctaButton];
    }
    if ([Utilities isEmpty:self.offerModel.logoURL] == NO) {
        [self addSubview:self.logoImage];
    }
}

+(ATOfferVideoBannerView *)bannerForView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            ATOfferVideoBannerView *banner = (ATOfferVideoBannerView *)subview;
            return banner;
        }
    }
    return nil;
}

-(UIButton *)ctaButton {
    if (!_ctaButton) {
        _ctaButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width - 140, self.frame.size.height/2 - 22, 130, 44)];
        [_ctaButton setBackgroundColor:[UIColor colorWithRed:110.0/255.0 green:171.0/255.0 blue:49.0/255.0 alpha:1]];
        _ctaButton.layer.cornerRadius = 5;
        _ctaButton.layer.masksToBounds = YES;
        _ctaButton.titleLabel.font = [UIFont fontWithName:@"Source Han Sans CN" size:15];
    }
    return _ctaButton;
}

-(UIImageView *)iconImage {
    if (!_iconImage && _offerModel != nil && _offerModel.iconURL != nil && _offerModel.iconURL.length > 0) {
        _iconImage = [[UIImageView alloc]initWithFrame:CGRectMake(11, self.frame.size.height/2 - 30, 60, 60)];
        _iconImage.layer.cornerRadius = 4.0f;
        _iconImage.layer.masksToBounds = YES;
        
    }
    return _iconImage;
}

-(UILabel *)title {
    if (!_title) {
        CGFloat x = 79.0f;
        CGFloat width = self.frame.size.width - 220;
        CGFloat y = 15.0f;
        CGFloat fontSize = 15.0f;
        CGFloat height = 20.0f;
        if(!_iconImage){
            x = x - 60.0f;
            width = width + 60.0f;
        }
        if(!_desc){
            y = y + 10.0f;
            fontSize = 20.0f;
            height = 30.0f;
        }
        if (_offerModel.CTA.length <= 0) {
            width += 130;
        }
        _title = [[UILabel alloc]initWithFrame:CGRectMake(x, y, width, height)];
        [_title setTextColor:[UIColor colorWithRed:42.0/255.0 green:45.0/255.0 blue:52.0/255.0 alpha:1]];
        [_title setFont:[UIFont systemFontOfSize:fontSize]];
        _title.textAlignment = NSTextAlignmentLeft;
    }
    return _title;
}

-(UILabel *)desc {
    if (!_desc && _offerModel != nil && _offerModel.text && _offerModel.text.length > 0) {
        CGFloat x = 79.0f;
        CGFloat y = 45.0f;
        CGFloat width = self.frame.size.width - 220;
        CGFloat height = self.frame.size.height - 65;
        if(!_iconImage){
            x = x - 60.0f;
            width = width + 60.0f;
        }
        if (_offerModel.CTA.length <= 0) {
            width += 130;
        }
        _desc = [[UILabel alloc]initWithFrame:CGRectMake(x,y,width, height)];
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
        _logoImage = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width - 50, self.frame.size.height - 15, 50, 15)];
    }

    return _logoImage;
}

@end

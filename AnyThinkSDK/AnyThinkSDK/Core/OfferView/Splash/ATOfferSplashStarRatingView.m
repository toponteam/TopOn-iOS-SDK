//
//  ATOfferSplashStarRatingView.m
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATOfferSplashStarRatingView.h"
#import "UIView+AutoLayout.h"
#import "Utilities.h"

@interface ATOfferSplashStarRatingView ()

@property(nonatomic, readonly) UIImageView *star0;
@property(nonatomic, readonly) UIImageView *star1;
@property(nonatomic, readonly) UIImageView *star2;
@property(nonatomic, readonly) UIImageView *star3;
@property(nonatomic, readonly) UIImageView *star4;

@end
@implementation ATOfferSplashStarRatingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self != nil) {
        [self initSubviews];
        [self makeConstraintsForSubviews];
    }
    return self;
}

-(void) initSubviews {
    _star0 = [UIImageView internal_autolayoutView];
    [self addSubview:_star0];
    
    _star1 = [UIImageView internal_autolayoutView];
    [self addSubview:_star1];
    
    _star2 = [UIImageView internal_autolayoutView];
    [self addSubview:_star2];
    
    _star3 = [UIImageView internal_autolayoutView];
    [self addSubview:_star3];
    
    _star4 = [UIImageView internal_autolayoutView];
    [self addSubview:_star4];
}

-(void) makeConstraintsForSubviews {
    [self internal_addConstraintsWithVisualFormat:@"|[_star0(18)]-10-[_star1(18)]-10-[_star2(18)]-10-[_star3(18)]-10-[_star4(18)]" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:0 views:NSDictionaryOfVariableBindings(_star0, _star1, _star2, _star3, _star4)];
    [self internal_addConstraintsWithVisualFormat:@"V:|[_star0(18)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_star0, _star1, _star2, _star3, _star4)];
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(18.0f * 5.0f + 10.0f * 4.0f, 18.0f);
}

- (void)configureStar:(CGFloat)star {
    NSArray<UIImageView*>* stars = self.subviews;
    NSInteger consumedStar = 0;
    CGFloat remainStar = star;
    while (consumedStar < 5) {
        stars[consumedStar++].image = [UIImage anythink_imageWithName:remainStar >= 1.0f ? @"native_splash_star_on" : remainStar > .0f ? @"native_splash_semi_star" : @"native_splash_star_off"];
        remainStar -= remainStar > 1.0f ? 1.0f : remainStar > .0f ? remainStar : .0f;
    }
}

@end

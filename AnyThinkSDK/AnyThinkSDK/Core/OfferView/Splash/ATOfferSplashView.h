//
//  ATOfferSplashView.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/28.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATOfferModel.h"

static NSString *const kSkipTextFormatString = @"%lds%@";

@interface ATOfferSplashView : UIView

@property(nonatomic, readonly) UIVisualEffectView *blurView;
@property(nonatomic, readonly) UIButton *skipButton;
@property(nonatomic, readonly) NSLayoutConstraint *skipButtonWidthConstraint;

@property(nonatomic, readonly) UILabel *textLabel;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UILabel *ctaLabel;
@property(nonatomic, readonly) UIImageView *iconImageView;
@property(nonatomic, readonly) UIImageView *mainImageView;
@property(nonatomic, readonly) UIImageView *sponsorImageView;
@property(nonatomic, readonly) UIImageView *backgroundImageView;
@property(nonatomic, readonly) UIImageView *ctaBackgroundImageView;
@property(nonatomic, readonly) UIView *bottomImageView;
@property(nonatomic, readonly) UILabel *adNoteLabel;

@property(nonatomic, readonly) UIView *containerView;
/**
 portrait: Whether the orientation of a splash view is portrait.
 */
- (instancetype) initWithFrame:(CGRect)frame containerView:(UIView *)containerView offerModel:(ATOfferModel*)offerModel isPortrait:(BOOL)portrait;

- (NSArray<UIView*> *)clickableViews;

- (void)setStarts:(CGFloat)starts;
@end

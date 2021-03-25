//
//  ATOfferFeedBackView.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/11.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class ATOfferFeedBackView;

@protocol ATOfferFeedBackViewDelegate <NSObject>

- (void)feedbackView:(ATOfferFeedBackView *)feedback didSelectItemAtIndex:(NSInteger)index extraMsg:(NSString *)msg;
@optional
- (void)feedbackViewWillDismiss:(ATOfferFeedBackView *)feedback;
@end

@interface ATOfferFeedBackView : UIView

@property(nonatomic, weak) id<ATOfferFeedBackViewDelegate> delegate;

+ (instancetype)create;

- (void)showInView:(UIView *)kSuperView;
//- (void)showInView:(UIView *)kSuperView positionY:(CGFloat)offset;

//- (void)dismiss;
@end

NS_ASSUME_NONNULL_END

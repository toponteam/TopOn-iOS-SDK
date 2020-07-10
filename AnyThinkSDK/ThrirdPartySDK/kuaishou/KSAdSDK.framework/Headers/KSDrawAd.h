//
//  KSDrawAd.h
//  KSAdSDK
//
//  Created by xuzhijun on 2019/12/6.
//

#import "KSAd.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KSDrawAdDelegate;

@interface KSDrawAd : KSAd


@property (nonatomic, weak) id<KSDrawAdDelegate> delegate;

- (void)registerContainer:(UIView *)containerView;
- (void)unregisterView;


@end

@protocol KSDrawAdDelegate <NSObject>
@optional
- (void)drawAdViewWillShow:(KSDrawAd *)drawAd;
- (void)drawAdDidClick:(KSDrawAd *)drawAd;
- (void)drawAdDidShowOtherController:(KSDrawAd *)drawAd interactionType:(KSAdInteractionType)interactionType;
- (void)drawAdDidCloseOtherController:(KSDrawAd *)drawAd interactionType:(KSAdInteractionType)interactionType;


@end

NS_ASSUME_NONNULL_END

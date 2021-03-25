//
//  ATBaiduBannerAdapter.h
//  AnyThinkBaiduBannerAdapter
//
//  Created by Martin Lau on 2018/11/30.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ATBaiduBannerAdapter : NSObject

@end

typedef enum _BaiduMobAdViewType {
    BaiduMobAdViewTypeBanner = 0
} BaiduMobAdViewType;

@protocol BaiduMobAdViewDelegate;
@protocol ATBaiduMobAdView<NSObject>
@property(nonatomic) CGRect frame;
@property (nonatomic, weak) UIViewController *presentAdViewController;
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@property(nonatomic, weak) id<BaiduMobAdViewDelegate> delegate;
@property(nonatomic,assign) BaiduMobAdViewType AdType;
@property(nonatomic, copy) NSString *AdUnitTag;
@property(nonatomic, readonly) NSString *Version;
- (void)start;
@end

@protocol BaiduMobAdViewDelegate <NSObject>
@required
- (NSString *)publisherId;
@optional
- (NSString *)channelId;
- (BOOL)enableLocation;
- (void)willDisplayAd:(id<ATBaiduMobAdView>)adview;
- (void)failedDisplayAd:(NSInteger)reason;
- (void)didAdImpressed;
- (void)didAdClicked;
- (void)didDismissLandingPage;
- (void)didAdClose;
@end

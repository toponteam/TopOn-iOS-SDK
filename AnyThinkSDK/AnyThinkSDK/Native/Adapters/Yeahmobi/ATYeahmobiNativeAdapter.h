//
//  ATYeahmobiNativeAdapter.h
//  AnyThinkYeahmobiNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const kYearmobiNativeAssetsCustomEventKey;
@interface ATYeahmobiNativeAdapter : NSObject
@end

@protocol ATCTService<NSObject>
#pragma mark - CTService config Method
+ (instancetype)shareManager;
- (void)loadRequestGetCTSDKConfigBySlot_id:(NSString *)slot_id;
- (void)uploadConsentValue:(NSString *)consentValue consentType:(NSString *)consentType complete:(void(^)(BOOL state))complete;
- (void)getMultitermNativeADswithSlotId:(NSString *)slot_id adNumbers:(NSInteger)num delegate:(id)delegate imageWidthHightRate:(NSUInteger)WHRate isTest:(BOOL)isTest success:(void (^)(NSArray *nativeArr))success failure:(void (^)(NSError *error))failure;
- (NSString*)getSDKVersion;
@end

@protocol CTNativeModelDelegate <NSObject>
@optional
-(void)CTNativeAdDidIntoLandingPage:(NSObject *)nativeModel;
-(void)CTNativeAdWillLeaveApplication:(NSObject *)nativeModel;
-(void)CTNativeAdJumpfail:(NSObject *)nativeModel;

@end

@protocol ATCTNativeAdModel<NSObject>
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *icon; //icon url
@property (nonatomic, strong)NSString *image; //big image url
@property (nonatomic, strong)UIImage *iconImage;//icon image ,only for preloadNativeADswithSlotId interface
@property (nonatomic, strong)UIImage *AdImage; //Ad big image, only for preloadNativeADswithSlotId interface
@property (nonatomic, strong)NSString *desc;
@property (nonatomic, strong)NSString *button;
@property (nonatomic, assign)float star;
@property (nonatomic, strong)UIImage *ADsignImage;
@property (nonatomic, strong)NSString *choices_link_url;
@property (nonatomic, assign)NSInteger offer_type;//1:download ad type 2:no download ad type
//以下变量及其方法为保留参数，暂不做处理
@property (nonatomic, assign)NSInteger objCode;
@property (nonatomic, assign)BOOL isFb;
- (void)clickAdJumpToMarker;
- (void)impressionForAd;
@property (nonatomic, weak)id <CTNativeModelDelegate> delegate;
@end
NS_ASSUME_NONNULL_END

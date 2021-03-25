//
//  ATNendBannerAdapter.h
//  AnyThinkNendBannerAdapter
//
//  Created by Martin Lau on 2019/4/19.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATNendBannerAdapter : NSObject

@end

@protocol ATNADView;

@protocol NADViewDelegate <NSObject>
@optional
- (void)nadViewDidFinishLoad:(id<ATNADView>)adView;
- (void)nadViewDidReceiveAd:(id<ATNADView>)adView;
- (void)nadViewDidFailToReceiveAd:(id<ATNADView>)adView;
- (void)nadViewDidClickAd:(id<ATNADView>)adView;
- (void)nadViewDidClickInformation:(id<ATNADView>)adView;
@end

@protocol ATNADView<NSObject>
@property(nonatomic) CGRect frame;
@property(nonatomic) UIViewAutoresizing autoresizingMask;
@property (nonatomic, weak) id<NADViewDelegate> delegate;
@property (nonatomic) BOOL isOutputLog __deprecated_msg("This method is deprecated. Use setLogLevel: method of NADLogger instead.");
@property (nonatomic) NSError *error;
@property (nonatomic, copy) NSString *nendApiKey;
@property (nonatomic, copy) NSString *nendSpotID;
- (instancetype)initWithIsAdjustAdSize:(BOOL)isAdjust;
- (instancetype)initWithFrame:(CGRect)frame isAdjustAdSize:(BOOL)isAdjust;
- (void)setNendID:(NSString *)apiKey spotID:(NSString *)spotID;
- (void)load;
- (void)load:(NSDictionary *)parameter;
- (void)pause;
- (void)resume;
@end

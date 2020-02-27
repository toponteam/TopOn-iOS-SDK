//
//  BaiduMobAdPrerollDelegate.h
//  BaiduMobAdSdk
//
//  Created by lishan04 on 15-6-8.
//
//

#import <Foundation/Foundation.h>
#import "BaiduMobAdCommonConfig.h"

@class BaiduMobAdPreroll;

@protocol BaiduMobAdPrerollDelegate <NSObject>

@optional

/**
 *  加载成功
 *  @param  adMaterialType  BaiduMobMaterialType
 */
- (void)prerollAdloadSuccess:(BaiduMobAdPreroll *)preroll withAdMaterialType:(NSString *)adMaterialType;

/**
 *  加载失败
 */
- (void)prerollAdLoadFail:(BaiduMobAdPreroll *)preroll;

/**
 *  展示成功
 */
- (void)prerollAdDidStart:(BaiduMobAdPreroll *)preroll;

/**
 *  广告展示失败
 */
- (void)prerollAdDidFailed:(BaiduMobAdPreroll *)preroll withError:(BaiduMobFailReason) reason;

/**
 *  广告展示结束
 */
- (void)prerollAdDidFinish:(BaiduMobAdPreroll *)preroll;

/**
 *  广告点击
 */
- (void)prerollAdDidClicked:(BaiduMobAdPreroll *)preroll;

@end

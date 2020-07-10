//
//  KSCUContentPage.h
//  KSAdSDK
//
//  Created by jie cai on 2020/5/2.
//

#import <Foundation/Foundation.h>
#import "KSCUEmbedAdConfig.h"
#import "KSCUContentStateDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSCUContentPage : NSObject<NSCopying>

@property (nonatomic, readonly) UIViewController *viewController;
///  内嵌广告配置.详情见 KSCUEmbedAdConfig 说明
@property (nonatomic, strong, readonly) KSCUEmbedAdConfig *embedAdConfig;
///  视频状态代理
@property (nonatomic, weak) id<KSCUVideoStateDelegate> videoStateDelegate;
///  页面状态代理
@property (nonatomic, weak) id<KSCUContentStateDelegate> stateDelegate;


- (instancetype)initWithPosId:(NSString *)posId;
/// 根据推送 deepLink 内容确认跳转界面，生成的 viewController，从 KSCUContentPage.viewController 获取
/// @param posId 广告位 id
/// @param deepLink 推送透传内容
/// @return KSCUContentPage
- (instancetype)initWithPosId:(NSString *)posId withDeepLink:(NSString *)deepLink;

@end

NS_ASSUME_NONNULL_END

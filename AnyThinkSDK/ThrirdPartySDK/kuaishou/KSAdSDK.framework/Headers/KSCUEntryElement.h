//
//  KSCUEntryElement.h
//  KSAdSDK
//
//  Created by jie cai on 2020/4/9.
//

#import <Foundation/Foundation.h>
#import "KSCUEmbedAdConfig.h"
#import "KSCUContentPage.h"
@protocol KSCUEntryElementDelegate;

NS_ASSUME_NONNULL_BEGIN

/*
  建议：入口组件贴屏幕左右两边
 
 */

@interface KSCUEntryElement : NSObject

/// 入口组件视图 entryElementSuccessToLoad 成功时获取
@property (nonatomic, strong, readonly, nullable) UIView *entryView;
/// 入口组件 size 大小 entryElementSuccessToLoad 成功时获取
@property (nonatomic, assign, readonly) CGSize entryExpectedSize;
/// 回调代理
@property (nonatomic, weak) id<KSCUEntryElementDelegate> delegate;

/// 默认 padding 左右各 16，上 8 下 0 ，在 loadData之前配置
@property (nonatomic, assign) UIEdgeInsets entryPadding;
///  入口组件默认为屏幕宽度，在 loadData之前配置
@property (nonatomic, assign) CGFloat expectedWidth;

/// 判断是否正在加载请求
@property (nonatomic, assign, readonly) BOOL isLoading;

- (instancetype)initWithPosId:(NSString *)posId;

- (instancetype)initWithContentPage:(KSCUContentPage *)contentPage;

/// 数据请求加载，通过代理回调,
- (void)loadData;

@end

@protocol KSCUEntryElementDelegate <NSObject>

@required
/// 成功回调通知
/*
   通过 entryView 获取具体的视图
   entryExpectedSize 为期望的宽高
 */
- (void)entryElementSuccessToLoad:(KSCUEntryElement *)entryElement;

///  点击单个feed事件回调
/*
 内部构造 UIViewController
 外部对 viewController 处理，具体 push / present 或者 容器组操作
 */
- (void)entryElement:(KSCUEntryElement *)entryElement didFeedClickCallBack:(KSCUContentPage *)contentPage;

@optional
/// 失败回调
- (void)entryElement:(KSCUEntryElement *)entryElement didFailWithError:(NSError *_Nullable)error;

@end

NS_ASSUME_NONNULL_END

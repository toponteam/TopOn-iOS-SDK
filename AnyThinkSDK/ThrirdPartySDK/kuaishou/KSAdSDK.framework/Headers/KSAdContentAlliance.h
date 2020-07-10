//
//  KSAdContentAlliance.h
//  Aspects
//
//  Created by xuzhijun on 2020/1/9.
//

#import <UIKit/UIKit.h>
#import "KSCUEmbedAdConfig.h"

NS_ASSUME_NONNULL_BEGIN


__attribute__((deprecated("KSAdContentAlliance is not supported; pls use KSCUContentPage class")))
@interface KSAdContentAlliance : NSObject

@property (nonatomic, readonly) UIViewController *viewController;

- (instancetype)initWithPosId:(NSString *)posId;

@end

NS_ASSUME_NONNULL_END


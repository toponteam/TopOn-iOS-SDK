//
//  UIColor+KAKit.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/11.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (KAKit)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
- (UIImage*)imageWithSize:(CGSize)size;
@end

NS_ASSUME_NONNULL_END

//
//  ATKeychain.h
//  AnyThinkSDK
//
//  Created by Topon on 7/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATKeychain : NSObject

// 保存数据到keychain中
+ (BOOL)saveData:(id)date withService:(NSString *)service;
// 从keychain中查找数据
+ (id)searchDateWithService:(NSString *)service;
// 更新keychain中的数据
+ (BOOL)updateDate:(id)date withService:(NSString *)service;
// 删除keychain中的数据
+ (BOOL)deleteDateiWithService:(NSString *)service;

@end

NS_ASSUME_NONNULL_END

//
//  ATRequestConfiguration.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/16.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATOnlineApiPlacementSetting.h"

typedef void(^ATResponseCallback)(id _Nullable model, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface ATRequestConfiguration : NSObject

@property (nonatomic) NSInteger networkFirmID;
@property (nonatomic, copy) NSString *unitID;

@property (nonatomic, readwrite) ATOnlineApiPlacementSetting *setting;
@property (nonatomic, copy) NSString *requestID;
@property (nonatomic) NSInteger bannerWidth;
@property (nonatomic) NSInteger bannerHight;
@property (nonatomic, copy) NSString *trafficGroupID;

@property (nonatomic, copy) ATResponseCallback callback;

@property (nonatomic) NSInteger format;
@property (nonatomic) NSInteger groupID;

@property (nonatomic, weak) id delegate;

@property (nonatomic, copy) NSDictionary *extraInfo;
@property (nonatomic, copy) NSDictionary *requestParam;

@end

NS_ASSUME_NONNULL_END

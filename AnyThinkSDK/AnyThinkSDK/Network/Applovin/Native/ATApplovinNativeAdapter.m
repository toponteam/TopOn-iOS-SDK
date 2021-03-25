//
//  ATApplovinNativeAdapter.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATApplovinNativeAdapter.h"
#import "ATApplovinRenderer.h"
#import "ATApplovinCustomEvent.h"
#import "NSObject+ExtraInfo.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAdAdapter.h"
#import "ATAppSettingManager.h"
#import "ATApplovinBaseManager.h"

@interface ATApplovinNativeAdapter()
@property(nonatomic, readonly) ATApplovinCustomEvent *customEvent;
@end
@implementation ATApplovinNativeAdapter
+(Class) rendererClass {
    return [ATApplovinRenderer class];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATApplovinBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary*> *assets, NSError *error))completion {
    _customEvent = [[ATApplovinCustomEvent alloc] init];
    _customEvent.unitID = serverInfo[@"sdkkey"];
    _customEvent.requestCompletionBlock = completion;
    NSDictionary *extraInfo = localInfo;
    _customEvent.requestExtra = extraInfo;
    _customEvent.requestNumber = [serverInfo[@"request_num"] integerValue];
    id<ATALSdk> sdk = [NSClassFromString(@"ALSdk") sharedWithKey:serverInfo[@"sdkkey"]];
    [sdk.nativeAdService loadNextAdAndNotify:_customEvent];
}
@end

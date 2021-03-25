//
//  ATMobrainSplashAdapter.m
//  AnyThinkMobrainAdapter
//
//  Created by Topon on 2/1/21.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATMobrainSplashAdapter.h"
#import "ATMobrainSplashApis.h"
#import "ATSplash.h"
#import "ATSplashDelegate.h"
#import "ATMobrainSplashCustomEvent.h"
#import "ATAdManager+Splash.h"
#import "ATSplashManager.h"

@interface ATMobrainSplashAdapter ()

@property(nonatomic, strong) id<ATABUSplashAd> splashAd;
@property(nonatomic, strong) ATMobrainSplashCustomEvent *customEvent;

@end

@implementation ATMobrainSplashAdapter

+(BOOL) adReadyWithCustomObject:(id)customObject info:(NSDictionary*)info {
    return ((id<ATABUSplashAd>)customObject).isAdValid;
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        [ATMobrainBaseManager initWithCustomInfo:serverInfo localInfo:localInfo];
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    Class udClass = NSClassFromString(@"ABUSplashUserData");
    Class adClass = NSClassFromString(@"ABUSplashAd");
    if (udClass == nil || adClass == nil) {
        
        completion(nil,[NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadSplashADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, @"Mobrain"]}]);
        return;
    }
    
    self.customEvent = [[ATMobrainSplashCustomEvent alloc]initWithInfo:serverInfo localInfo:localInfo];
    self.customEvent.requestCompletionBlock = completion;
    
    NSDictionary *slotInfo = [NSJSONSerialization JSONObjectWithData:[serverInfo[@"slot_info"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];

    dispatch_async(dispatch_get_main_queue(), ^{
        _splashAd = [[adClass alloc] initWithAdUnitID:serverInfo[@"slot_id"]];
        _splashAd.rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;    //required
        _splashAd.delegate = (id<ABUSplashAdDelegate>)self.customEvent;
                
        _splashAd.getExpressAdIfCan = [slotInfo[@"common"][@"ad_style_type"] integerValue] == 1;
                           
        //用于在广告位还在失败，采用传入的rit进行广告加载;该配置需要在load前设置
        id<ATABUSplashUserData> userData = [[udClass alloc]init];
        if(localInfo[kATSplashExtraMobrainAdnTypeKey] != nil){
            userData.adnType = [localInfo[kATSplashExtraMobrainAdnTypeKey] intValue];
            userData.appKey = localInfo[kATSplashExtraMobrainAppKeyKey];
            userData.appID = localInfo[kATSplashExtraAppIDKey];     // 如果使用穿山甲兜底，请务必传入与MSDK初始化时一致的appID
            userData.rit = localInfo[kATSplashExtraRIDKey];    // 开屏对应的代码位
        }
       
        NSError *error = nil;
        // 在广告位配置拉取失败后，会使用传入的rit和appID兜底，进行广告加载，需要在创建manager时就调用该接口（仅支持穿山甲/MTG/Ks/GDT/百度）
        [_splashAd setUserData:userData error:&error];
        // ！！！如果有错误信息说明setUserData调用有误，需按错误提示重新设置
        if (error) {
            completion(nil,error);
            return;
        }
        
        // 广告加载, 前置设置无错误时再加载广告
        [_splashAd loadAdData];
    });
    
}

+ (void)showSplash:(ATSplash *)splash localInfo:(NSDictionary*)localInfo delegate:(id<ATSplashDelegate>)delegate{
    id<ATABUSplashAd> ad = splash.customObject;
    splash.customEvent.delegate = delegate;
    UIWindow *window = localInfo[kATSplashExtraWindowKey];
    [ad showInWindow:window];
}
@end

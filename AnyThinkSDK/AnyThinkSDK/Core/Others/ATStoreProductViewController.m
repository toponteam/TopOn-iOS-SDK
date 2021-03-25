//
//  ATStoreProductViewController.m
//  AnyThinkSDK
//
//  Created by stephen on 8/6/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATStoreProductViewController.h"
#import "ATThreadSafeAccessor.h"
#import "ATLogger.h"
#import "Utilities.h"
#import "ATAgentEvent.h"
#import "ATPlacementSettingManager.h"

static NSLock* ATStoreKitLock = nil;

@interface ATStoreProductViewController ()
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;
@property(nonatomic, readonly) NSMutableDictionary *preloadStorekitDict;

@end
@implementation ATStoreProductViewController

+ (void)at_presentStorekit:(ATStoreProductViewController *)presentedVC presenting:(UIViewController *)presentingVC {
    if (presentedVC.presented) {
        // 正在展示就直接返回
        return;
    }
    presentedVC.parentVC = presentingVC;
    presentedVC.presented = YES;
    presentedVC.storekit.delegate = presentedVC;
    [presentingVC presentViewController:presentedVC.storekit animated:YES completion:nil];
}

+ (void)at_dismissStorekit:(ATStoreProductViewController *)presentedVC {
    [presentedVC.storekit dismissViewControllerAnimated:YES completion:nil];
    presentedVC.presented = NO;
}

+ (instancetype)storekitWithPackageName:(NSString *)packageName skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate{
    NSString *appIDString = [packageName stringByReplacingOccurrencesOfString:@"id" withString:@""];
    return [self at_storeWithAppid:[appIDString integerValue] skDelegate:skDelegate];
}

+ (instancetype)at_storeWithAppid:(NSInteger)APPID skDelegate:(id<SKStoreProductViewControllerDelegate>)skDelegate
{
    // Store kit should init with 初始化需要依次进行，同时初始化内部会crash
    static dispatch_once_t ATOnceToken;
    dispatch_once(&ATOnceToken, ^{
        ATStoreKitLock = [[NSLock alloc] init];
    });
    
    [ATStoreKitLock lock];
    ATStoreProductViewController *holder = [[ATStoreProductViewController alloc] init];
    SKStoreProductViewController *sk = [[SKStoreProductViewController alloc] init];
    holder.skDelegate = skDelegate;
    holder.storekit = sk;
    [ATStoreKitLock unlock];
    return holder;
}

- (void)atLoadProductWithOfferModel:(ATOfferModel *)offerModel packageName:(NSString *)packageName placementID:(NSString *)placementID offerID:(NSString *)offerID pkgName:(NSString *)pkgName finished:(void (^)(BOOL result, NSError *error, NSTimeInterval loadTime))finished {
    NSString *appIDString = [packageName stringByReplacingOccurrencesOfString:@"id" withString:@""];
    NSInteger APPID = [appIDString integerValue];
    if([NSThread isMainThread]){
        [self loadProductWithAPPID:APPID placementID:placementID offerID:offerID offerModel:offerModel pkgName:pkgName finished:finished];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadProductWithAPPID:APPID placementID:placementID offerID:offerID offerModel:offerModel pkgName:pkgName finished:finished];
        });
    }
}

- (void)loadProductWithAPPID:(NSInteger)APPID placementID:(NSString *)placementID offerID:(NSString *)offerID offerModel:(ATOfferModel *)offerModel pkgName:(NSString *)pkgName finished:(void (^)(BOOL result, NSError *error, NSTimeInterval loadTime))finished {
    if (APPID <= 0 ) {
        if(finished) {
            finished(NO, [NSError errorWithDomain:@"appid invalid" code:-1 userInfo:nil], 0);
        }
        return;
    }
    
//    NSDate *startDate = [NSDate date];
    NSNumber *startTimeStamp =  [Utilities normalizedTimeStamp];
    [ATLogger logError:[NSString stringWithFormat:@"storekit load start APPID ==== %ld ",(long)APPID]  type:ATLogTypeInternal];
    
    ATPlacementModel *placementModel = [[ATPlacementSettingManager sharedManager] placementSettingWithPlacementID:placementID];
    NSDictionary *skParames = nil;
    if (@available(iOS 14, *)) {
//        skParames = @{
//            SKStoreProductParameterITunesItemIdentifier : @(APPID),
//            @"_MSPNC_Tag":@"1",
//            SKStoreProductParameterCampaignToken: placementModel.campaign};
        skParames = @{SKStoreProductParameterITunesItemIdentifier : @(APPID),@"_MSPNC_Tag":@"1"};

    }else{
        skParames = @{SKStoreProductParameterITunesItemIdentifier : @(APPID),@"_MSPNC_Tag":@"1"};
    }
    
    [self.storekit loadProductWithParameters:skParames completionBlock:^(BOOL result, NSError *error){
        
        if(result){
            if (self.realtimeLoad) {
                self.realtimeLoad = NO;
                // 实时加载的只看 storekit 回调的 result
            }
            self.loadSuccessed = (result == YES) && !error;
        }
       
        [ATLogger logError:[NSString stringWithFormat:@"storekit load finish APPID====%ld ,result====%d,loadSuccessed=%d ", (long)APPID, result, self.loadSuccessed] type:ATLogTypeInternal];
        
        NSNumber *endTimeStamp =  [Utilities normalizedTimeStamp];
        NSTimeInterval loadTime = [endTimeStamp doubleValue] - [startTimeStamp doubleValue];
        [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyPreloadStorekitResultKey placementID:placementID unitGroupModel:nil extraInfo:@{kAgentEventExtraInfoMyOfferOfferIDKey:offerID, kAgentEventExtraInfoAdTypeKey:@(offerModel.offerModelType), kAgentEventExtraInfoAdPkgNameKey:pkgName, kAgentEventExtraInfoIsSuccessKey:result?@1:@0,  kAgentEventExtraInfoLoadStartTimeKey:startTimeStamp, kAgentEventExtraInfoLoadStopTimeKey:endTimeStamp}];
        
        if(finished) {
            finished(result, error, loadTime);
        }
        
    }];
}

- (void)dealloc {
}


#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addChildViewController:self.storekit];
    UIView *view = self.storekit.view;
    view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    // [view mtg_addConstraintsWithTop:@(0) left:@(0) bottom:@(0) right:@(0) width:nil height:nil];
    [self.view addSubview:view];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.storekit.view removeFromSuperview];
    [self.storekit removeFromParentViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
}


- (BOOL)shouldAutorotate {
    return NO;
}

#pragma storekit delegate
- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    [viewController dismissViewControllerAnimated:YES completion:nil];
    [viewController.view removeFromSuperview];
    [ATStoreProductViewController at_dismissStorekit:self];
    if ([self.skDelegate respondsToSelector:@selector(productViewControllerDidFinish:)]) {
        [self.skDelegate productViewControllerDidFinish:viewController];
    }
}


@end

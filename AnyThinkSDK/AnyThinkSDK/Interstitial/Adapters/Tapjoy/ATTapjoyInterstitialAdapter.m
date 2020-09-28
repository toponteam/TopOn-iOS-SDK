//
//  ATTapjoyInterstitialAdapter.m
//  AnyThinkTapjoyInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATTapjoyInterstitialAdapter.h"
#import "ATTapjoyInterstitialCustomEvent.h"
#import "ATAPI+Internal.h"
#import "Utilities.h"
#import "ATAppSettingManager.h"

static NSString *const kConnectSuccessNotification = @"TJC_Connect_Success";
static NSString *const kConnectFailureNotification = @"TJC_Connect_Failed";
@interface ATTapjoyInterstitialAdapter()
@property(nonatomic, readonly) NSDictionary *info;
@property(nonatomic, readonly) ATTapjoyInterstitialCustomEvent *customEvent;
@end

static NSString *const kTapjoyClassName = @"Tapjoy";
static NSString *const kPlacementNameKey = @"placement_name";
@implementation ATTapjoyInterstitialAdapter
+(BOOL) adReadyWithCustomObject:(id<ATTJPlacement>)customObject info:(NSDictionary*)info {
    return customObject.isContentReady;
}

+(void) showInterstitial:(ATInterstitial*)interstitial inViewController:(UIViewController*)viewController delegate:(id<ATInterstitialDelegate>)delegate {
    interstitial.customEvent.delegate = delegate;
    ((id<ATTJPlacement>)interstitial.customObject).videoDelegate = (ATTapjoyInterstitialCustomEvent*)interstitial.customEvent;
    [((id<ATTJPlacement>)interstitial.customObject) showContentWithViewController:viewController];
}

-(instancetype) initWithNetworkCustomInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo {
    self = [super init];
    if (self != nil) {
        _info = serverInfo;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [[ATAPI sharedInstance] setVersion:[NSClassFromString(@"Tapjoy") getVersion] forNetwork:kNetworkNameTapjoy];
            if (![[ATAPI sharedInstance] initFlagForNetwork:kNetworkNameTapjoy]) {
                [[ATAPI sharedInstance] setInitFlagForNetwork:kNetworkNameTapjoy];
                if ([[ATAPI sharedInstance].networkConsentInfo containsObjectForKey:kNetworkNameTapjoy]) {
                    [NSClassFromString(kTapjoyClassName) setUserConsent:[ATAPI sharedInstance].networkConsentInfo[kNetworkNameTapjoy][kTapjoyConsentValueKey]];
                    [NSClassFromString(kTapjoyClassName) subjectToGDPR:[[ATAPI sharedInstance].networkConsentInfo[kNetworkNameTapjoy][kTapjoyGDPRSubjectionKey] boolValue]];
                } else {
                    BOOL set = NO;
                    ATUnitGroupModel *unitGroupModel =(ATUnitGroupModel*)serverInfo[kAdapterCustomInfoUnitGroupModelKey];
                    BOOL limit = [[ATAppSettingManager sharedManager] limitThirdPartySDKDataCollection:&set networkFirmID:unitGroupModel.networkFirmID];
                    if (set) {
                        /*
                        setUserConsent: 1 Personalized, 0 Nonpersonalized
                        */
                        [NSClassFromString(kTapjoyClassName) setUserConsent:limit ? @"0" : @"1"];
                        [NSClassFromString(kTapjoyClassName) subjectToGDPR:[[ATAPI sharedInstance] inDataProtectionArea]];
                    }
                }
            }
        });
    }
    return self;
}

-(void) loadADWithInfo:(NSDictionary*)serverInfo localInfo:(NSDictionary*)localInfo completion:(void (^)(NSArray<NSDictionary *> *, NSError *))completion {
    if (NSClassFromString(kTapjoyClassName)) {
        _customEvent = [[ATTapjoyInterstitialCustomEvent alloc] initWithInfo:serverInfo localInfo:localInfo];
        _customEvent.requestCompletionBlock = completion;
        _customEvent.customEventMetaDataDidLoadedBlock = self.metaDataDidLoadedBlock;
        if ([NSClassFromString(kTapjoyClassName) isConnected]) {
            [ATLogger logMessage:@"Tapjoy: Connected alreadly, will start load" type:ATLogTypeExternal];
            [self startLoad];
        } else {
            [ATLogger logMessage:@"Tapjoy: Not yet connected, will connect" type:ATLogTypeExternal];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tjcConnectSuccess:)
                                                         name:kConnectSuccessNotification
                                                       object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(tjcConnectFail:)
                                                         name:kConnectFailureNotification
                                                       object:nil];
            [NSClassFromString(kTapjoyClassName) connect:serverInfo[@"sdk_key"]];
        }
    } else {
        [ATLogger logError:@"Tapjoy: Failed to load, Tapjoy class not found." type:ATLogTypeExternal];
        completion(nil, [NSError errorWithDomain:ATADLoadingErrorDomain code:ATADLoadingErrorCodeThirdPartySDKNotImportedProperly userInfo:@{NSLocalizedDescriptionKey:kATSDKFailedToLoadInterstitialADMsg, NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:kSDKImportIssueErrorReason, kTapjoyClassName]}]);
    }
}

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void) startLoad {
    id<ATTJPlacement> placement = [NSClassFromString(@"TJPlacement") placementWithName:_info[kPlacementNameKey] delegate:_customEvent];
    [placement requestContent];
}
#pragma mark - notification
-(void)tjcConnectSuccess:(NSNotification*)notifyObj {
    [ATLogger logMessage:@"tjcConnectSuccess:" type:ATLogTypeExternal];
    [self startLoad];
}

-(void)tjcConnectFail:(NSNotification*)notifyObj {
    [ATLogger logError:@"tjcConnectFail:" type:ATLogTypeExternal];
}
@end

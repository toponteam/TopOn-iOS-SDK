//
//  ATStartAppInterstitialAdapter.h
//  AnyThinkStartAppInterstitialAdapter
//
//  Created by Martin Lau on 2020/3/19.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ATStartAppInterstitialAdapter : NSObject

@end

@protocol ATSTAAdPreferences<NSObject>
@property (nonatomic, assign) double minCPM;
@property (nonatomic, strong) NSString *adTag;
+ (instancetype)preferencesWithMinCPM:(double)minCPM;
@end

@protocol STADelegateProtocol<NSObject>
@end

@protocol ATSTAAbstractAd<NSObject>
@end
@protocol ATSTAStartAppAd<ATSTAAbstractAd>
- (void) loadVideoAdWithDelegate:(id<STADelegateProtocol>) delegate withAdPreferences:(id<ATSTAAdPreferences>) adPrefs;
- (void) loadAdWithDelegate:(id<STADelegateProtocol>) delegate withAdPreferences:(id<ATSTAAdPreferences>) adPrefs;
- (void) showAdWithAdTag:(NSString *)adTag;
- (BOOL) isReady;
@end

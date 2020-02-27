//
//  ATInterstitialCustomEvent.h
//  AnyThinkInterstitial
//
//  Created by Martin Lau on 21/09/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdCustomEvent.h"
#import "ATInterstitial.h"
#import "ATInterstitialDelegate.h"
#import "ATTracker.h"
@interface ATInterstitialCustomEvent : ATAdCustomEvent
-(void) trackVideoStart;
-(void) trackVideoEnd;
-(ATNativeADSourceType) adSourceType;
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo;
@property(nonatomic, weak) id<ATInterstitialDelegate> delegate;
@property(nonatomic, weak) ATInterstitial *interstitial;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, assign) NSInteger priorityIndex;
@end

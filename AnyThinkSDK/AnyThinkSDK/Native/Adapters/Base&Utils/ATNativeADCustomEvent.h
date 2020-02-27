//
//  ATNativeADCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 25/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATNativeADView.h"
#import "ATTracker.h"
@class ATNativeADCache;
@interface ATNativeADCustomEvent : NSObject
-(void) handleAssets:(NSDictionary*)assets;
-(void) handleLoadingFailure:(NSError*)error;
-(void) didAttachMediaView;
-(void) willDetachOffer:(ATNativeADCache*)offer fromAdView:(ATNativeADView*)adView;
/**
 *@para refresh: whether the show is trigered by a ad refresh.
 */
-(void) trackShow:(BOOL)refresh;
-(void) trackClick;
-(void) trackVideoStart;
-(void) trackVideoEnd;
-(ATNativeADSourceType) sourceType;
@property(nonatomic, copy) void(^requestCompletionBlock)(NSArray<NSDictionary*> *assets, NSError *error);
@property(nonatomic, weak) ATNativeADView *adView;
@property(nonatomic) NSInteger requestNumber;
/**
 * Failed or successful, a request's considered finished.
 */
@property(nonatomic) NSInteger numberOfFinishedRequests;
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* assets;
@property(nonatomic) NSDictionary *requestExtra;
@end

@interface ATNativeADView(Event)
-(void) notifyNativeAdClick;
-(void) notifyVideoStart;
-(void) notifyVideoEnd;
-(void) notifyVideoEnterFullScreen;
-(void) notifyVideoExitFullScreen;
-(void) notifyCloseButtonTapped;
@end

//
//  ATRewardedVideoCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdCustomEvent.h"
#import "ATRewardedVideoDelegate.h"
#import "ATRewardedVideo.h"

@interface ATRewardedVideoCustomEvent : ATAdCustomEvent
-(void) saveVideoPlayEventWithError:(NSError*)error;
-(void) saveVideoCloseEventRewarded:(BOOL)rewarded;
-(void) trackVideoStart;
-(void) trackVideoEnd;
-(void) trackClick;
-(void) trackShow;

-(NSDictionary*)delegateExtra;

-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo;
@property(nonatomic, weak) id<ATRewardedVideoDelegate> delegate;
@property(nonatomic, weak) ATRewardedVideo *rewardedVideo;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic) NSString *userID;
@property(nonatomic, assign) NSInteger priorityIndex;
@end

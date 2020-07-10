//
//  ATAdCustomEvent.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 05/07/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATAd.h"
#import "ATTracker.h"
extern NSString *const kSDKImportIssueErrorReason;
extern NSString *const kATAdAssetsAppIDKey;
@interface ATAdCustomEvent : NSObject
+(NSDictionary*)customInfoWithUnitGroupModel:(ATUnitGroupModel*)unitGroupModel extra:(NSDictionary*)extra;
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo;
-(void) handleAssets:(NSDictionary*)assets;
-(void) handleLoadingFailure:(NSError*)error;
-(void) handleClose;
-(void) trackShow;
-(void) trackClick;
-(ATNativeADSourceType) adSourceType;
@property(nonatomic, weak) id<ATAd> ad;
@property(nonatomic) NSNumber *sdkTime;
@property(nonatomic, copy) void(^requestCompletionBlock)(NSArray<NSDictionary*> *assets, NSError *error);
@property(nonatomic) NSInteger requestNumber;
@property (nonatomic,copy) void (^customEventMetaDataDidLoadedBlock)(void);
/**
 * Failed or successful, a request's considered finished.
 */
@property(nonatomic) NSInteger numberOfFinishedRequests;
@property(nonatomic, readonly) NSMutableArray<NSDictionary*>* assets;
@property(nonatomic, readonly) NSDictionary *customInfo;
@property(nonatomic) BOOL rewardGranted;

-(void) saveShowAPIContext;
@property(nonatomic, readonly) NSDate *showDate;
@property(nonatomic, readonly) NSString *psIDOnShow;

+(NSInteger) calculateAdPriority:(id<ATAd>)ad;
@end

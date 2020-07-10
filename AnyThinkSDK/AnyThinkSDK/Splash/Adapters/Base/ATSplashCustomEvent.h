//
//  ATSplashCustomEvent.h
//  AnyThinkSplash
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATAdCustomEvent.h"

@class ATSplash;
@protocol ATSplashDelegate;
@interface ATSplashCustomEvent : ATAdCustomEvent
-(instancetype) initWithUnitID:(NSString*)unitID customInfo:(NSDictionary*)customInfo;
@property(nonatomic, assign) id<ATSplashDelegate> delegate;
@property(nonatomic, readonly) NSString *unitID;
@property(nonatomic, assign) NSInteger priorityIndex;
-(NSDictionary*)delegateExtra;
@end

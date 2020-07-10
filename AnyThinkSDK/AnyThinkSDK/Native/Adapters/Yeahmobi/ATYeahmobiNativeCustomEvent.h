//
//  ATYeahmobiNativeCustomEvent.h
//  AnyThinkYeahmobiNativeAdapter
//
//  Created by Martin Lau on 2018/10/15.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeADCustomEvent.h"
#import "ATYeahmobiNativeAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATYeahmobiNativeCustomEvent : ATNativeADCustomEvent<CTNativeModelDelegate>
-(void) loadSuccessed:(NSArray*)ads;
-(void) loadFailed:(NSError*)error;
@end

NS_ASSUME_NONNULL_END

//
//  ATYeahmobiInterstitialCustomEvent.h
//  AnyThinkYeahmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/16.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATYeahmobiInterstitialAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface ATYeahmobiInterstitialCustomEvent : ATInterstitialCustomEvent<CTAdViewDelegate>
-(void) handleShow;
@end

NS_ASSUME_NONNULL_END

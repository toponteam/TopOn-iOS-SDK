//
//  ATInmobiInterstitialCustomEvent.h
//  AnyThinkInmobiInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/8.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATInmobiInterstitialAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ATIMAdMetaInfo;

@interface ATInmobiInterstitialCustomEvent : ATInterstitialCustomEvent<ATIMInterstitialDelegate>

@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *bidID;

@end

NS_ASSUME_NONNULL_END

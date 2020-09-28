//
//  ATVungleInterstitialCustomEvent.h
//  AnyThinkVungleInterstitialAdapter
//
//  Created by Martin Lau on 2018/10/9.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATVungleInterstitialAdapter.h"
NS_ASSUME_NONNULL_BEGIN

@interface ATVungleInterstitialCustomEvent : ATInterstitialCustomEvent<ATVungleSDKDelegate>
-(instancetype) initWithInfo:(NSDictionary *)serverInfo localInfo:(NSDictionary *)localInfo adapter:(ATVungleInterstitialAdapter*)adapter;
-(void) handlerPlayError:(NSError*)error;
@end

NS_ASSUME_NONNULL_END

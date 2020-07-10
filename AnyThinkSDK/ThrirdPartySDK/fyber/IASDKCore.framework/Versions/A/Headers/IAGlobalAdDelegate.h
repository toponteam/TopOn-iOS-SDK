//
//  IAGlobalAdDelegate.h
//  IASDKCore
//
//  Created by Avi Gelkop on 08/12/2019.
//  Copyright © 2019 Inneractive. All rights reserved.
//

#ifndef IAGlobalAdDelegate_h
#define IAGlobalAdDelegate_h

#import "IAAdRequest.h"
#import "IAImpressionData.h"

@protocol IAGlobalAdDelegate <NSObject>

@required
/**
 *  @brief The impression info of the shown ad.
 */
- (void)adDidShowWithImpressionData:(IAImpressionData * _Nonnull)impressionData withAdRequest:(IAAdRequest * _Nonnull)adRequest;

@end

#endif /* IAGlobalAdDelegate_h */

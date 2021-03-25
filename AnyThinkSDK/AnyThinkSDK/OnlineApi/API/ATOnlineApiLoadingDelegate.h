//
//  ATOnlineApiLoadingDelegate.h
//  AnyThinkSDK
//
//  Created by Jason on 2020/10/15.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATOnlineApiLoadingDelegate_h
#define ATOnlineApiLoadingDelegate_h


@protocol ATOnlineApiLoadingDelegate <NSObject>

- (void)didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID;
- (void)didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID;
- (void)didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error;

@end

#endif /* ATOnlineApiLoadingDelegate_h */


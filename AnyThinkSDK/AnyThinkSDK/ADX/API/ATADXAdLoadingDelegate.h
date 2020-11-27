//
//  ATADXAdLoadingDelegate.h
//  AnyThinkSDK
//
//  Created by stephen on 20/8/2020.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#ifndef ATADXLoadingDelegate_h
#define ATADXLoadingDelegate_h

@protocol ATADXAdLoadingDelegate<NSObject>
-(void) didLoadADSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID;
-(void) didLoadMetaDataSuccessWithPlacementID:(NSString *)placementID unitID:(NSString *)unitID;
-(void) didFailToLoadADWithPlacementID:(NSString*)placementID unitID:(NSString *)unitID error:(NSError*)error;
@end

#endif /* ATADXLoadingDelegate_h */

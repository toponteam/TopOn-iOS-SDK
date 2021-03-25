//
//  OFMSDKApis.h
//  AnyThinkSDK
//
//  Created by Jason on 2021/2/7.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#ifndef OFMSDKApis_h
#define OFMSDKApis_h

@protocol ATOFMMediationConfig <NSObject>

@property(nonatomic, readwrite) NSInteger mediationTrafficId;

@end

@protocol ATOFMAPI <NSObject>

+(instancetype)sharedInstance;
-(id<ATOFMMediationConfig>) currentMediationConfig;
@end

#endif /* OFMSDKApis_h */

//
//  ATMopubRenderer.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 16/05/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATNativeRenderer.h"
#import "ATMopubNativeAdapter.h"
@interface ATMopubRenderSettings:NSObject<ATMPNativeAdRendererSettings>
@property (nonatomic, assign) Class renderingViewClass;
@property (nonatomic, readwrite, copy) ATMPNativeViewSizeHandler viewSizeHandler;
@end

@interface ATMopubRendererConfiguration:NSObject
@property (nonatomic, strong) id<ATMPNativeAdRendererSettings> rendererSettings;
@property (nonatomic, assign) Class rendererClass;
@property (nonatomic, strong) NSArray *supportedCustomEvents;
@end

@interface ATMopubRenderer : ATNativeRenderer<ATMPNativeAdRenderer>
@property (nonatomic, readonly) ATMPNativeViewSizeHandler viewSizeHandler;
@end

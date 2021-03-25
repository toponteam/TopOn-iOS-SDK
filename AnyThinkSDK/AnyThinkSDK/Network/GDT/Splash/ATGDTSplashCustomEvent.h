//
//  ATGDTSplashCustomEvent.h
//  AnyThinkGDTSplashAdapter
//
//  Created by Martin Lau on 2018/12/20.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "ATSplashCustomEvent.h"
#import "ATGDTSplashAdapter.h"

@interface ATGDTSplashCustomEvent : ATSplashCustomEvent<GDTSplashAdDelegate, GDTSplashZoomOutViewDelegate>
@property(nonatomic, weak) UIImageView *backgroundImageView;
@end

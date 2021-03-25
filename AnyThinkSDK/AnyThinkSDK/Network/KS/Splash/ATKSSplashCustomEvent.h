//
//  ATKSSplashCustomEvent.h
//  AnyThinkKuaiShouAdapter
//
//  Created by Topon on 11/20/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <AnyThinkSplash/AnyThinkSplash.h>
#import "ATKSSplashAdapter.h"

NS_ASSUME_NONNULL_BEGIN

@interface ATKSSplashCustomEvent : ATSplashCustomEvent<KSAdSplashInteractDelegate>
@property(nonatomic, weak) UIWindow *window;
@end

NS_ASSUME_NONNULL_END

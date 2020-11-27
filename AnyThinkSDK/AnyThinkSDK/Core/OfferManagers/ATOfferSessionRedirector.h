//
//  ATOfferSessionRedirector.h
//  AnyThinkSDK
//
//  Created by Topon on 9/1/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATOfferSessionRedirector : NSObject
+(instancetype) redirectorWithURL:(NSURL*)URL completion:(void(^)(NSURL *finalURL, NSError *error))completion;
@end

NS_ASSUME_NONNULL_END

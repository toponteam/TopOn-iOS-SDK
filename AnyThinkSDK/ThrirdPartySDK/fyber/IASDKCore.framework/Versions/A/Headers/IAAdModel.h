//
//  IAAdModel.h
//  IASDKCore
//
//  Created by Inneractive on 13/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IAInterfaceContentModel.h"

@interface IAAdModel : NSObject <NSCopying>

@property (nonatomic, readonly, getter=isRewarded) BOOL rewarded;

/**
 *  @discussion Ad model is base; this member extends it to concrete type ad model.
 */
@property (nonatomic, strong, nullable, readonly) id<IAInterfaceContentModel> contentModel;

@end

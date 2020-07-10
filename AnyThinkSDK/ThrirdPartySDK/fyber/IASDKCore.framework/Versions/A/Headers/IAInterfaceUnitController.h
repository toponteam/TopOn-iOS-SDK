//
//  IAInterfaceUnitController.h
//  IASDKCore
//
//  Created by Inneractive on 14/03/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#ifndef IAInterfaceUnitController_h
#define IAInterfaceUnitController_h

#import <Foundation/Foundation.h>

@protocol IAUnitDelegate;
@class IAContentController;

@protocol IAUnitControllerBuilderProtocol <NSObject>

@required
- (void)addSupportedContentController:(IAContentController * _Nonnull)supportedContentController;

@end

@protocol IAInterfaceUnitController <IAUnitControllerBuilderProtocol>

@required

@property (nonatomic, weak, nullable) id<IAUnitDelegate> unitDelegate;

/**
 *  @brief The content controller, that is relevant to the received ad unit.
 */
@property (nonatomic, weak, readonly, nullable) IAContentController *activeContentController;

/**
 *  @brief Cleans all internal data. After use of this method, current unit controller is no more useable until a new response of same ad unit type is received.
 */
- (void)clean;

@end

#endif /* IAInterfaceUnitController_h */

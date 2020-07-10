//
//  IAInterfaceViewProvider.h
//  IASDKCore
//
//  Created by Fyber on 19/02/2020.
//  Copyright © 2020 Fyber. All rights reserved.
//

#ifndef IAInterfaceViewProvider_h
#define IAInterfaceViewProvider_h

@class IAViewController;
@protocol IAInterfaceViewProvider <NSObject>

@required
@property (nonatomic, strong, nullable) IAViewController *viewController;

@end

#endif /* IAInterfaceViewProvider_h */

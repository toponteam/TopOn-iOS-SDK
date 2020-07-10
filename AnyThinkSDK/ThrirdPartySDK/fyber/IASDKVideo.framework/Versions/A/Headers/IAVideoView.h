//
//  IAVideoView.h
//  IASDKVideo
//
//  Created by Inneractive on 02/07/2017.
//  Copyright © 2017 Inneractive. All rights reserved.
//

#import <IASDKCore/IAMRAIDAdView.h>

#pragma mark - Statics

static const CGFloat kIALandscapeVPAIDVerticalDelta = 44.0f;

#pragma mark -

@interface IAVideoView : IAMRAIDAdView

@property (nonatomic, readonly) CGFloat defaultMRectWidth; // 300;
@property (nonatomic, readonly) CGFloat defaultMRectHeight; // 250;
@property (nonatomic, readonly) CGFloat defaultSquareEdge; // is app frame width; ratio is: 1:1;
@property (nonatomic, readonly) CGFloat defaultLandscapeWidth; // 16x (is app frame width) : 9x (derived from width + 44 to height in case of VPAID content);
@property (nonatomic, readonly) CGFloat defaultLandscapeHeight;

@end

//
//  ATVideoView.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 27/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ATVideoViewDelegate;
@interface ATVideoView : UIView
-(instancetype) initWithFrame:(CGRect)frame URL:(NSURL*)URL;
@property(nonatomic, weak) id<ATVideoViewDelegate> delegate;
@property(nonatomic) BOOL autoPlay;
@property(nonatomic) NSURL *URL;
@property(nonatomic, readonly) double progress;
@end

@protocol ATVideoViewDelegate<NSObject>
-(void) videoDidPlayInVideoView:(ATVideoView*)videoView;
-(void) videoDidFinishPlayingInVideoView:(ATVideoView*)videoView;
@end

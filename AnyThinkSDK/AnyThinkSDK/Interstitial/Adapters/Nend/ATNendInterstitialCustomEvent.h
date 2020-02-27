//
//  ATNendInterstitialCustomEvent.h
//  AnyThinkNendInterstitialAdapter
//
//  Created by Martin Lau on 2019/4/18.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATInterstitialCustomEvent.h"
#import "ATNendInterstitialAdapter.h"
@interface ATNendInterstitialCustomEvent : ATInterstitialCustomEvent<NADInterstitialVideoDelegate, NADFullBoardDelegate>
-(void) handleShowSuccess;
-(void) handleShowFailure:(NSInteger)code;
-(void) completeFullBoardLoad:(id<ATNADFullBoard>)fullBoard errorCode:(NSInteger)error;
@end

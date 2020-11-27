//
//  ATMyOfferProgressView.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface ATOfferProgressView : UIView

@property(nonatomic,assign)CGFloat signProgress;
@property(nonatomic,assign)CGFloat progress;

-(void)upDateCircleProgress:(CGFloat) progress;



@end



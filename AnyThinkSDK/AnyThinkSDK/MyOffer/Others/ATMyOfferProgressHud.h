//
//  ATMyOfferProgressHud.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/10/8.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ATMyOfferProgressHud : UIView
//方式1
+(void)showProgressHud:(UIView *)view;

+(void)hideProgressHud:(UIView *)view;

+(ATMyOfferProgressHud *)hudForView:(UIView *)view;

//方式2
+(instancetype)showProgressHudWithView:(UIView *)view;

-(void)hiddenProgressHud;



@end

NS_ASSUME_NONNULL_END

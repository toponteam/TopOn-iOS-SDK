//
//  ATMyOfferVideoBannerView.h
//  AnyThinkMyOffer
//
//  Created by Topon on 2019/9/27.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ATMyOfferVideoBannerView : UIView
@property (nonatomic , strong)UIImageView *iconImage;
@property (nonatomic , strong)UILabel *title;
@property (nonatomic , strong)UILabel *desc;
@property (nonatomic , strong)UIButton *ctaButton;
@property (nonatomic , strong)UIImageView *logoImage;

+(ATMyOfferVideoBannerView *)bannerForView:(UIView *)view;

@end



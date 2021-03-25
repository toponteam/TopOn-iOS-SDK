//
//  ATOfferBannerView.h
//  AnyThinkSDK
//
//  Created by Topon on 10/28/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATOfferSetting.h"
#import "ATOfferModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ATOfferBannerDelegate <NSObject>
-(void) offerBannerFailToShowOffer:(ATOfferModel*)offerModel error:(NSError*)error;
-(void) offerBannerShowOffer:(ATOfferModel*)offerModel;
-(void) offerBannerClickOffer:(ATOfferModel*)offerModel;
-(void) offerBannerCloseOffer:(ATOfferModel*)offerModel;
@end

@interface ATOfferBannerView : UIView
@property(nonatomic, weak) id<ATOfferBannerDelegate> delegate;
-(instancetype) initWithFrame:(CGRect)frame offerModel:(ATOfferModel*)offerModel setting:(ATOfferSetting*)setting;
-(void) initOfferBannerView;
@end

NS_ASSUME_NONNULL_END

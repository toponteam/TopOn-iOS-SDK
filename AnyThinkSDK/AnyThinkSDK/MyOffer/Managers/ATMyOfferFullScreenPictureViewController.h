//
//  ATMyOfferFullScreenPictureViewController.h
//  AnyThinkMyOffer
//
//  Created by Topon on 8/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ATMyOfferFullScreenPictureDelegate <NSObject>
-(void)myOfferFullScreenPictureEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferFullScreenPictureDidClickVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferFullScreenPictureEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;

@end

@interface ATMyOfferFullScreenPictureViewController : UIViewController

@property (nonatomic , weak) id<ATMyOfferFullScreenPictureDelegate> delegate;

- (instancetype)initWithMyOfferModel:(ATMyOfferOfferModel*)offerModel rewardedVideoSetting:(ATMyOfferSetting *)setting;

@end

NS_ASSUME_NONNULL_END

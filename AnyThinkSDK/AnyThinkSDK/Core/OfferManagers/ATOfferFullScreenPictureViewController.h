//
//  ATOfferFullScreenPictureViewController.h
//  AnyThinkMyOffer
//
//  Created by Topon on 8/14/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATOfferSetting.h"
#import "ATOfferModel.h"

NS_ASSUME_NONNULL_BEGIN
@protocol ATOfferFullScreenPictureDelegate <NSObject>
-(void)offerFullScreenPictureEndCardDidShowWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerFullScreenPictureDidClickAdWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerFullScreenPictureEndCardDidCloseWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerFullScreenPictureFeedbackViewDidSelectItemAtIndex:(NSInteger)index offerModel:(ATOfferModel *)offerModel extraMsg:(NSString *)msg;
@end

@interface ATOfferFullScreenPictureViewController : UIViewController

@property (nonatomic , weak) id<ATOfferFullScreenPictureDelegate> delegate;
- (instancetype)initWithOfferModel:(ATOfferModel*)offerModel rewardedVideoSetting:(ATOfferSetting *)setting;

@end

NS_ASSUME_NONNULL_END

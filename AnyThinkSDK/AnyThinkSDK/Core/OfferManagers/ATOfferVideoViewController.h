//
//  ATOfferVideoViewController.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATOfferSetting.h"
#import "ATOfferModel.h"
@protocol ATOfferVideoDelegate <NSObject>
-(void)offerVideoStartPlayWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoPlay25PercentWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoPlay50PercentWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoPlay75PercentWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidEndPlayWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidClickVideoWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidClickAdWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidVideoPausedWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidVideoMutedWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidVideoUnMutedWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoDidCloseWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoEndCardDidShowWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)offerVideoEndCardDidCloseWithOfferModel:(ATOfferModel *)offerModel extra:(NSDictionary *)extra;

@end

@interface ATOfferVideoViewController : UIViewController
@property (nonatomic , weak) id<ATOfferVideoDelegate> delegate;

- (instancetype)initWithOfferModel:(ATOfferModel*)offerModel rewardedVideoSetting:(ATOfferSetting *)setting;

@end



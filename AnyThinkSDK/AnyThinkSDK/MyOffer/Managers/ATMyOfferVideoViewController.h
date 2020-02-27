//
//  ATMyOfferVideoViewController.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATMyOfferSetting.h"
#import "ATMyOfferOfferModel.h"
@protocol ATMyOfferVideoDelegate <NSObject>
-(void)myOfferVideoStartPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoPlay25PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoPlay50PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoPlay75PercentWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoDidEndPlayWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoDidClickVideoWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoEndCardDidShowWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;
-(void)myOfferVideoEndCardDidCloseWithOfferModel:(ATMyOfferOfferModel *)offerModel extra:(NSDictionary *)extra;

@end

@interface ATMyOfferVideoViewController : UIViewController
@property (nonatomic , weak) id<ATMyOfferVideoDelegate> delegate;

- (instancetype)initWithMyOfferModel:(ATMyOfferOfferModel*)offerModel rewardedVideoSetting:(ATMyOfferSetting *)setting;

@end



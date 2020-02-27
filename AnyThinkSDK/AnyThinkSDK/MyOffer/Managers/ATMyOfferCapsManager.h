//
//  ATMyOfferCapsManager.h
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ATMyOfferOfferManager.h"

@interface ATMyOfferCapsManager : NSObject

+(instancetype)shareManager;
/*
 * cap+1
 */
-(void)increaseCapForOfferModel:(ATMyOfferOfferModel *)offerModel;
/*
 * 获取当前cap
 */
-(NSInteger)capForOfferModel:(ATMyOfferOfferModel*)offerModel;
/*
 * 获取上一次show的时间
 */
-(NSString*)lastShowingDateForOfferModel:(ATMyOfferOfferModel*)offerModel;

/*
 * 判断当前offer是否满足cap
 */
-(BOOL)validateCapsForOfferModel:(ATMyOfferOfferModel*)offerModel;
/*
 * 判断当前offer是否满足pacing
 */
-(BOOL)validatePacingForOfferModel:(ATMyOfferOfferModel*)offerModel;

@end



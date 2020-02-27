//
//  ATMyOfferCapsManager.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferCapsManager.h"
#import "ATThreadSafeAccessor.h"

@interface ATMyOfferCapsManager ()

@property(nonatomic, readonly) NSMutableDictionary *caps;
@property(nonatomic, readonly) ATThreadSafeAccessor *capsAccessor;

@end
static NSString *const kCapsKey = @"myOffer_caps";
static NSString *const kTimeKey = @"myOffer_lastShowTime";
static NSString *const myOfferCapsInfoFileName = @"capsInfo.anythinkMyOffer.com";
@implementation ATMyOfferCapsManager
/*
    {
     offerID:{
         date:yyyy-mm-dd HH:mm:ss
         cap:0
         }
     }
 */

+(instancetype)shareManager{
    static ATMyOfferCapsManager *shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ATMyOfferCapsManager alloc]init];
    });
    return shareManager;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _capsAccessor = [ATThreadSafeAccessor new];
        if ([[NSFileManager defaultManager]fileExistsAtPath:[self capsInfoPath]]) {
            _caps = [[NSMutableDictionary alloc] initWithContentsOfFile:[self capsInfoPath]];
        }else{
            _caps = [NSMutableDictionary dictionary];
        }
    }
    return self;
}

//cap+1
-(void)increaseCapForOfferModel:(ATMyOfferOfferModel *)offerModel{
    if ([offerModel.offerID isKindOfClass:[NSString class]]) {
        __weak typeof(self) weakSelf = self;
        [_capsAccessor writeWithBlock:^{
            NSMutableDictionary *offerInfo = weakSelf.caps[offerModel.offerID];
            if (offerInfo) {
                //caps内的时间和q当前时间是否为同一天， 0: caps = 1，更新时间     1:caps + 1 ，更新时间
                if(![ATMyOfferCapsManager istoday:offerInfo[kTimeKey]]){
                    offerInfo[kCapsKey] = @1;
                    offerInfo[kTimeKey] = [weakSelf getCurrentTime];
                }else{
                    offerInfo[kCapsKey] = @([offerInfo[kCapsKey]integerValue]+1);
                    offerInfo[kTimeKey] = [weakSelf getCurrentTime];
                }
            }else{
                //不存在offerInfo时，初始化一个offerInfo
                NSString *currentDate = [weakSelf getCurrentTime];
                offerInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:currentDate,kTimeKey,@1,kCapsKey, nil];
            }
            //更新缓存
            [weakSelf.caps setObject:offerInfo forKey:offerModel.offerID];
            [weakSelf.caps writeToFile:[weakSelf capsInfoPath] atomically:YES];
        }];
    }
}
//获取当前cap
-(NSInteger)capForOfferModel:(ATMyOfferOfferModel*)offerModel{
    __weak typeof(self) weakSelf = self;
    return [[_capsAccessor readWithBlock:^id {
        NSMutableDictionary *offerInfo = weakSelf.caps[offerModel.offerID];
        if (offerInfo) {
            //如果不是同一天 返回0
            if(![ATMyOfferCapsManager istoday:offerInfo[kTimeKey]]){
                return @0;
            }
        }
        return [weakSelf.caps[offerModel.offerID] objectForKey:kCapsKey] != nil ? [weakSelf.caps[offerModel.offerID] objectForKey:kCapsKey] : @0;
    }]integerValue];
}
//获取上一次show的时间
-(NSString*)lastShowingDateForOfferModel:(ATMyOfferOfferModel*)offerModel{
    __weak typeof(self) weakSelf = self;
    return [_capsAccessor readWithBlock:^id {
        return [weakSelf.caps[offerModel.offerID] objectForKey:kTimeKey];
    }];
}

-(BOOL)validateCapsForOfferModel:(ATMyOfferOfferModel*)offerModel {
    return [self capForOfferModel:offerModel] < offerModel.dailyCap || offerModel.dailyCap < 0;
}

-(BOOL)validatePacingForOfferModel:(ATMyOfferOfferModel*)offerModel{
    NSDate *date = [ATMyOfferCapsManager stringToDateWithString:[self lastShowingDateForOfferModel:offerModel]];
    return ([self lastShowingDateForOfferModel:offerModel] == nil || [[NSDate date] timeIntervalSinceDate:date] >= offerModel.pacing) || offerModel.pacing < 0;
}

-(NSString*)documentsPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

-(NSString*)capsInfoPath {
    return [[self documentsPath] stringByAppendingPathComponent:myOfferCapsInfoFileName];
}

-(NSString *)getCurrentTime
{
    return [ATMyOfferCapsManager currentTimeStringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
}
//使用format的格式获取当前时间
+(NSString *)currentTimeStringWithFormat:(NSString *)format
{
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = format;
    formatter.timeZone = [NSTimeZone systemTimeZone];
    return [formatter stringFromDate:currentDate];
}
//string 转 date
+(NSDate *)stringToDateWithString:(NSString *)timer{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSDate *date = [formatter dateFromString:timer];
    return date;
}
//判断time 和 当前时间是否在同一天
+(BOOL)istoday:(NSString *)timeStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    formatter.timeZone = [NSTimeZone systemTimeZone];
    NSDate *date = [formatter dateFromString:timeStr];
    
    NSDateFormatter *formatter1 = [[NSDateFormatter alloc] init];
    formatter1.dateFormat = @"yyyy-MM-dd";
    formatter1.timeZone = [NSTimeZone systemTimeZone];
    
    NSString *dateStr = [formatter1 stringFromDate:date];
    NSString *currentStr = [ATMyOfferCapsManager currentTimeStringWithFormat:@"yyyy-MM-dd"];
    
    return [dateStr isEqualToString:currentStr];
}



@end

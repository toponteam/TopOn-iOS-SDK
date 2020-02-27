//
//  NADUserFeature.h
//  NendAdFramework
//
//  Copyright © 2018年 F@N Communications, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, NADGender) {
    NADGenderMale = 1,
    NADGenderFemale = 2
};

NS_ASSUME_NONNULL_BEGIN
@interface NADUserFeature : NSObject

@property (nonatomic) NADGender gender;
@property (nonatomic) NSInteger age;

- (void)setBirthdayWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;
- (void)addCustomStringValue:(NSString *)value forKey:(NSString *)key;
- (void)addCustomBoolValue:(BOOL)value forKey:(NSString *)key;
- (void)addCustomIntegerValue:(NSInteger)value forKey:(NSString *)key;
- (void)addCustomDoubleValue:(double)value forKey:(NSString *)key;

@end
NS_ASSUME_NONNULL_END

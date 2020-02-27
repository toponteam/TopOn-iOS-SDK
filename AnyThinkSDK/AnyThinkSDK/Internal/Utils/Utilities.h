//
//  Utilities.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 10/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+KAKit.h"
#import "NSString+KAKit.h"
#import <UIKit/UIKit.h>
#import "ATLogger.h"
/*
 *To prevent exceptions from causing crash, they will be swallowed(caught and dropped).
 *Decleard as class method because of the nullability of the passed data object or not being a NSData* in the first place.
 *Not work if within Block a new thread's spawned, whinin which the exception throwing code lies. Under such circumstance, just moving the AT_SafelyRun into the dispatched block will do.
 */
void AT_SafelyRun(void(^Block)(void));
NSArray* CallstackSymbols(void);

BOOL AT_DebuggerAttached(void);
BOOL AT_ProxyEnabled(void);
@class ATPlacementModel;
@interface Utilities : NSObject
+(NSNumber*)normalizedTimeStamp;
+(NSNumber*)screenOrientation;
+(NSString*)screenResolution;
+(NSString*)appBundleName;
+(NSString*)appBundleID;
+(NSString*)appBundleVersion;
+(NSNumber*)platform;
+(NSString*)brand;
+(NSString*)model;
+(NSString*)systemName;
+(NSString*)systemVersion;
+(NSString*)language;
+(NSString*)timezone;
+(NSString*)mobileCountryCode;
+(NSString*)mobileNetworkCode;
+(NSString*)advertisingIdentifier;
+(NSString*)idfv;
+(NSString*)userAgent;
+(NSDictionary*)networkVersions;

+(NSString*) generateRequestID;

+(NSString*)documentsPath;

+(NSString*)computeSignWithParameters:(NSDictionary*)parameters;

extern NSString *const kCallStackSymbolCallerMethodKey;
extern NSString *const kCallStackSymbolCallerClassKey;
+(NSArray<NSDictionary<NSString*, NSString*>*>*)parseCallStackSymbols:(NSArray<NSString*>*)callStackSymbols;
+(BOOL) validateShowingScene:(NSString*)scene;
@end

@interface NSDate(ATUtilities)
+(instancetype) normalizaedDate;
@end

@interface NSData(ATKit)
+(instancetype) dataWithUTF8String:(const char*)string;

- (nullable NSData *)gzippedDataWithCompressionLevel_ATKit:(float)level;
- (nullable NSData *)gzippedData_ATKit;
- (nullable NSData *)gunzippedData_ATKit;
- (BOOL)isGzippedData_ATKit;
@end

@interface NSArray(ATKit)
-(NSString*) jsonString_anythink;
@end

@interface UIImage(ATKit)
+(instancetype) anythink_imageWithName:(NSString*)name;
@end

@interface NSObject(ATObjectAssociation)
-(void) AT_setObject:(id)object forKey:(NSString*)key;
-(id) AT_objectForKey:(NSString*)key;
@end

#pragma mark - UIView autolayout utilities
@interface UIView(Autolayout)
+(instancetype) internal_autolayoutView;
- (NSArray<__kindof NSLayoutConstraint *> *)internal_addConstraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *, id> *)views;
-(NSLayoutConstraint*)internal_addConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
@end

@interface UILabel(Autolayout)
+(instancetype) internal_autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment)textAlignment;
/**
 * textAlignment defaults to NSTextAlignmentLeft
 */
+(instancetype) internal_autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor;
@end

@interface UIButton(Autolayout)
+(instancetype) internal_autolayoutButtonWithType:(UIButtonType)type;
@end

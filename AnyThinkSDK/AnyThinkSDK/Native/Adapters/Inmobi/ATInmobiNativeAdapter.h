//
//  ATInmobiNativeAdapter.h
//  AnyThinkSDK
//
//  Created by Martin Lau on 21/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
extern NSString *const kInmobiNativeADAdapterAssetKey;
extern NSString *const kInmobiNativeADAdapterEventKey;
@interface ATInmobiNativeAdapter : NSObject
@end

@protocol ATIMSdk<NSObject>
+(NSString *)getVersion;
+(void)initWithAccountID:(NSString *)accountID andCompletionHandler:(void (^)(NSError * )) completionBlock;
+(void)updateGDPRConsent:(NSDictionary *)consentDictionary;
@end

@protocol IMNativeDelegate;
@protocol ATIMNative<NSObject>
-(instancetype)initWithPlacementId:(long long)placementId delegate:(id<IMNativeDelegate>)delegate;
-(void)load;
-(void)reportAdClickAndOpenLandingPage;
-(UIView*)primaryViewOfWidth:(CGFloat)width;
-(void)recyclePrimaryView;
@property (nonatomic, weak) id<IMNativeDelegate> delegate;
@property (nonatomic, strong, readonly) UIImage* adIcon;
@property (nonatomic, strong, readonly) NSString* adTitle;
@property (nonatomic, strong, readonly) NSString* adDescription;
@property (nonatomic, strong, readonly) NSString* adCtaText;
@property (nonatomic, strong, readonly) NSString* adRating;
@end

@protocol IMNativeDelegate<NSObject>
@end

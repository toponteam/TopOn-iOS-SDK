//
//  CTElementAd.h
//  CTSDK
//

#import <UIKit/UIKit.h>
#import "CTElementModel.h"
@protocol CTNativeAdDelegate;

@interface CTNativeAd : UIView
/**
 Ad source, you must set it ！
 */
@property (nonatomic, strong) CTNativeAdModel* adNativeModel;
/**
 Ad callback delegate
 */
@property (nonatomic, weak)   id<CTNativeAdDelegate> delegate;
/**
 if removeloading is yes, click ad will remove loading animation！
 */
@property (nonatomic, assign) BOOL removeLoading;
/**
 Init method

 @return self
 */
- (instancetype)init;
/**
 Init method

 @param frame Ad size

 @return self
 */
- (instancetype)initWithFrame:(CGRect)frame;

@end

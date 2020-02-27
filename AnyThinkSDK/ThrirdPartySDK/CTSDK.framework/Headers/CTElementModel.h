//
//  CTElementModel.h
//  CTSDK

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CTNativeModelDelegate.h"
@class CTElementAdListModel;

@interface CTElementModel : NSObject
@property (nonatomic, strong)NSArray<CTElementAdListModel *> *ad_list;
@property (nonatomic, strong)NSString *err_msg;
@property (nonatomic, assign)NSInteger err_no;
@end

@interface CTNativeAdModel : NSObject

@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *icon; //icon url
@property (nonatomic, strong)NSString *image; //big image url
@property (nonatomic, strong)UIImage *iconImage;//icon image ,only for preloadNativeADswithSlotId interface
@property (nonatomic, strong)UIImage *AdImage; //Ad big image, only for preloadNativeADswithSlotId interface
@property (nonatomic, strong)NSString *desc;
@property (nonatomic, strong)NSString *button;
@property (nonatomic, assign)float star;
@property (nonatomic, strong)UIImage *ADsignImage;
@property (nonatomic, strong)NSString *choices_link_url;
@property (nonatomic, assign)NSInteger offer_type;//1:download ad type 2:no download ad type
//以下变量及其方法为保留参数，暂不做处理
@property (nonatomic, assign)NSInteger objCode;
@property (nonatomic, assign)BOOL isFb;
- (void)clickAdJumpToMarker;
- (void)impressionForAd;
@property (nonatomic, weak)id <CTNativeModelDelegate> delegate;
@end

@interface CTCustomColor : NSObject
@property (nonatomic, strong)UIColor *buttonBackgroundColor;//button背景
@property (nonatomic, strong)UIColor *normlBackgroundColor;//TableView的背景
@property (nonatomic, strong)UIColor *btnNormlTextColor;//上面button字体颜色
@property (nonatomic, strong)UIColor *btnSelectedTextColor; //上面button 选中字体颜色
@property (nonatomic, strong)UIColor *cellBackgroundColor;//广告的背景色
@property (nonatomic, strong)UIColor *cellTitleColor;//广告的title的色
@property (nonatomic, strong)UIColor *cellHeadTitleColor;//cell head title color
@property (nonatomic, strong)UIColor *marketColor;
@property (nonatomic, strong)UIColor *sliderViewColor;
@end

//
//  CTADMRAIDView.h
//  CTSDK
//
//  Created by Mirinda on 2018/5/11.
//  Copyright © 2018年 Mirinda. All rights reserved.
//

#import <UIKit/UIKit.h>
/** Ad placement type.
 */
typedef enum
{
    /// 内容型广告,如banner .
    CTAdViewPlacementTypeInline = 0,
    
    //插屏
    CTAdViewPlacementTypeInterstitial
    
} CTAdViewPlacementType;

/** Event log types.
 */
typedef enum
{
    CTADViewLogEventTypeNone = 0,
    CTAdViewLogEventTypeError = 1,
    CTAdViewLogEventTypeDebug = 2,
} CTAdViewLogEventType;


@protocol CTAdViewDelegate;

@interface CTADMRAIDView : UIView
@property (nonatomic, weak) id<CTAdViewDelegate> delegate;
@property (nonatomic, readonly) CTAdViewPlacementType placementType;
@property (nonatomic, readonly) UIView* expandView;
@property (nonatomic, assign) BOOL modalDismissAfterPresent;
@property (nonatomic, assign) BOOL useInternalBrowser;
@property (nonatomic, assign) BOOL isReady;
@property (nonatomic, readonly) NSString* slot;

/** Unregisters the protocol class used to intercept the MRAID bridge request
 from rich media ads.
 
 Note: The registered NSURLProtocol class used by the SDK only intercepts requests
 for "mraid.js" from a UIWebView.
 */
- (void)unregisterProtocolClass;

@end


@protocol CTAdViewDelegate <NSObject>
@optional

//banner ad
- (void)CTAdViewDidRecieveBannerAd:(CTADMRAIDView*)adView;

//interstitial is ready, call mraidInterstitialShow to show it.
- (void)CTAdViewDidRecieveInterstitialAd;

//interstitial is ready, call mraidInterstitialShow to show it. include Request Slotid
- (void)CTAdViewDidRecieveInterstitialAdForSlot:(NSString *)slot;

//error while request ads.
- (void)CTAdView:(CTADMRAIDView*)adView didFailToReceiveAdWithError:(NSError*)error;

//jump to safari or internal webview
- (BOOL)CTAdView:(CTADMRAIDView*)adView shouldOpenURL:(NSURL*)url;

//mraid ad clicked
- (void)CTAdViewClicked:(CTADMRAIDView*)adView;

//did click close button
- (void)CTAdViewCloseButtonPressed:(CTADMRAIDView*)adView;

//mraid ad will expand
- (void)CTAdViewWillExpand:(CTADMRAIDView*)adView;

//mraid ad did expand
- (void)CTAdViewDidExpand:(CTADMRAIDView*)adView;

//mraid ad will resize frame
- (void)CTAdView:(CTADMRAIDView *)adView willResizeToFrame:(CGRect)frame;

//mraid ad did resize frame
- (void)CTAdView:(CTADMRAIDView *)adView didResizeToFrame:(CGRect)frame;

//mraid ad will collapse from expanded or resize state
- (void)CTAdViewWillCollapse:(CTADMRAIDView*)adView;

//mraid ad did collapse from expanded or resize state
- (void)CTAdViewDidCollapse:(CTADMRAIDView*)adView;

//internal webview will open click url
- (void)CTAdViewInternalBrowserWillOpen:(CTADMRAIDView*)adView;

//internal webview did open click url
- (void)CTAdViewInternalBrowserDidOpen:(CTADMRAIDView*)adView;

//internal webview will close
- (void)CTAdViewInternalBrowserWillClose:(CTADMRAIDView*)adView;

//internal webview did close
- (void)CTAdViewInternalBrowserDidClose:(CTADMRAIDView*)adView;

//will leave application
- (void)CTAdViewWillLeaveApplication:(CTADMRAIDView*)adView;

//specify the event type to print log
- (BOOL)CTAdView:(CTADMRAIDView*)adView shouldLogEvent:(NSString*)event ofType:(CTAdViewLogEventType)type;

//specify if support sms
- (BOOL)CTAdViewSupportsSMS:(CTADMRAIDView*)adView;

//specify if support phone
- (BOOL)CTAdViewSupportsPhone:(CTADMRAIDView*)adView;

//specify if support calendar, default return no
//Privacy - Calendars Usage Description
//Privacy - Reminders Usage Description
//- (BOOL)CTAdViewSupportsCalendar:(CTADMRAIDView*)adView; // Close this method Temporary

//specify if support store picture, default return no. if return yes, add privilage below to plist
//Privacy - Photo Library Additions Usage Description
//Privacy - Photo Library Usage Description
//- (BOOL)CTAdViewSupportsStorePicture:(CTADMRAIDView*)adView;//Close this method Temporary

//specify if support location, default return no. if return yes, add privilage below to plist
//Privacy - Location Always and When In Use Usage Description
//Privacy - Location When In Use Usage Description
//- (BOOL)CTAdViewSupportsLocation:(CTADMRAIDView*)adView;//Close this method Temporary

//allow mraid ad play video using safari
- (BOOL)CTAdView:(CTADMRAIDView*)adView shouldPlayVideo:(NSString*)videoURL;

//mraid ad save calender event
//- (BOOL)CTAdView:(CTADMRAIDView*)adView shouldSaveCalendarEvent:(EKEvent*)event inEventStore:(EKEventStore*)eventStore; //Close this method Temporary

//mraid ad save photo to gallery
//- (BOOL)CTAdView:(CTADMRAIDView*)adView shouldSavePhotoToCameraRoll:(UIImage*)image;//Close this method Temporary

//specify view controller to present modal vc
- (UIViewController*)CTAdViewPresentationController:(CTADMRAIDView*)adView;

//specify mraid ad resize superview
- (UIView*)CTAdViewResizeSuperview:(CTADMRAIDView*)adView;

@end


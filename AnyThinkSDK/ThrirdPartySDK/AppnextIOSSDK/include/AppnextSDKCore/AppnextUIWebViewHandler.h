//
//  AppnextUIWebViewHandler.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 31/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@protocol AppnextUIWebViewHandlerDelegate <UIWebViewDelegate>
- (void) onAppnextWebViewOpen:(NSString *)param;
- (void) onAppnextWebViewDestroy:(NSString *)param;
- (void) onAppnextWebViewImpression:(NSString *)param;
- (void) onAppnextWebViewOpenLink:(NSString *)param;
@end

@interface AppnextUIWebViewHandler : NSObject

@property (nonatomic, weak) id<AppnextUIWebViewHandlerDelegate> delegate;

- (instancetype) initWithWebView:(UIWebView *)webView delegate:(id<AppnextUIWebViewHandlerDelegate>)delegate;

@end

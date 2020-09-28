//
//  ATMyofferNativeSharedDelegate.m
//  AnyThinkMyOffer
//
//  Created by stephen on 7/31/20.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ATMyOfferNativeSharedDelegate.h"
#import "Utilities.h"
#import "ATThreadSafeAccessor.h"
#import "ATMyOfferOfferManager.h"
#import "ATMyOfferTracker.h"
#import "ATMyOfferCapsManager.h"
#import "ATPlacementSettingManager.h"
#import "ATMyOfferResourceManager.h"
@interface ATMyOfferNativeSharedDelegate()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, id<ATMyOfferNativeDelegate>> *delegates;
@property(nonatomic, readonly) ATThreadSafeAccessor *delegateStorageAccessor;
@property(nonatomic, readonly) dispatch_queue_t delegates_accessing_queue;

@property (nonatomic , strong)ATMyOfferOfferModel *offerModel;
@property (nonatomic) ATMyOfferSetting *setting;

@end

@implementation ATMyOfferNativeSharedDelegate
+(instancetype) sharedDelegate {
    static ATMyOfferNativeSharedDelegate *sharedDelegate = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDelegate = [[ATMyOfferNativeSharedDelegate alloc] init];
    });
    return sharedDelegate;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _delegates = [NSMutableDictionary<NSString*, id<ATMyOfferNativeDelegate>> dictionary];
        _delegateStorageAccessor = [ATThreadSafeAccessor new];
        _delegates_accessing_queue = dispatch_queue_create("myofferNativeDelegatesAccessingQueue.com.anythink", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void) setDelegate:(id<ATMyOfferNativeDelegate>)delegate forPlacementID:(NSString*)placementID {
    if (delegate != nil && placementID != nil) { dispatch_barrier_async(_delegates_accessing_queue, ^{ self->_delegates[placementID] = delegate; }); }
}

-(void) removeDelegateForPlacementID:(NSString*)placementID {
    if (placementID != nil) { dispatch_barrier_async(_delegates_accessing_queue, ^{ [self->_delegates removeObjectForKey:placementID]; }); }
}

-(id<ATMyOfferNativeDelegate>)delegateForPlacementID:(NSString*)placementID {
    id<ATMyOfferNativeDelegate> __block delegate = nil;
    dispatch_sync(_delegates_accessing_queue, ^{ delegate = self->_delegates[placementID]; });
    return delegate;
}

- (void)adViewTapped {
    [ATLogger logMessage:@"ATMyOfferNativeSharedDelegate::adViewTapped" type:ATLogTypeExternal];
    __weak typeof(self) weakSelf = self;
    [_delegateStorageAccessor readWithBlock:^id{
        id<ATMyOfferNativeDelegate> delegate = [weakSelf.delegates AT_weakObjectForKey:weakSelf.offerModel.offerID];
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.offerModel] : @"";
        NSMutableDictionary *trackerExtra = [NSMutableDictionary dictionaryWithObject:lifeCircleID != nil ? lifeCircleID : @"" forKey:kATMyOfferTrackerExtraLifeCircleID];
        [[ATMyOfferTracker sharedTracker] clickOfferWithOfferModel:_offerModel setting:_setting extra:@{kATMyOfferTrackerExtraLifeCircleID:lifeCircleID != nil ? lifeCircleID : @""} skDelegate:self viewController:[UIApplication sharedApplication].keyWindow.rootViewController circleId:lifeCircleID];
        [[ATMyOfferTracker sharedTracker] trackEvent:ATMyOfferTrackerEventClick offerModel:weakSelf.offerModel extra:trackerExtra];
        if ([delegate respondsToSelector:@selector(myOfferNativeClickOffer:)]) { [delegate myOfferNativeClickOffer:weakSelf.offerModel]; }
        return nil;
    }];
}


- (void)registerViewForInteraction:(UIViewController *)viewController clickableViews:(NSArray<UIView *> *)clickableViews offerModel:(ATMyOfferOfferModel*)offerModel setting:(ATMyOfferSetting*)setting delegate:(id<ATMyOfferNativeDelegate>)delegate {
    _offerModel = offerModel;
    _setting = setting;
    if ([[ATMyOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID]) {
        __weak typeof(self) weakSelf = self;
        weakSelf.viewController = viewController;
        [_delegateStorageAccessor writeWithBlock:^{
            [weakSelf.delegates AT_setWeakObject:delegate forKey:offerModel.offerID];
        }];
        if (clickableViews.count > 0) {
            [clickableViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj respondsToSelector:@selector(setUserInteractionEnabled:)]) { [obj setUserInteractionEnabled:YES]; }
                if ([obj respondsToSelector:@selector(addGestureRecognizer:)]) {
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adViewTapped)];
                    [obj addGestureRecognizer:tap];
                }
            }];
        }
        
        NSString *lifeCircleID = [delegate respondsToSelector:@selector(lifeCircleIDForOffer:)] ? [delegate lifeCircleIDForOffer:weakSelf.offerModel] : @"";
        [[ATMyOfferTracker sharedTracker] preloadStorekitForOfferModel:_offerModel setting:_setting viewController:_viewController circleId:lifeCircleID skDelegate:self];
        
        [[ATMyOfferResourceManager sharedManager] updateLastUseDateForResourceWithResourceID:offerModel.localResourceID];
        [[ATMyOfferCapsManager shareManager] increaseCapForOfferModel:offerModel];
        if ([[ATMyOfferCapsManager shareManager] validateCapsForOfferModel:offerModel]) {
            [[ATPlacementSettingManager sharedManager] removeCappedMyOfferID:offerModel.offerID];
        } else {
            [[ATPlacementSettingManager sharedManager] addCappedMyOfferID:offerModel.offerID];
        }
        
        id<ATMyOfferNativeDelegate> delegate = [self delegateForPlacementID:offerModel.offerID];
        if ([delegate respondsToSelector:@selector(myOfferNativeShowOffer:)]) {
            [delegate myOfferNativeShowOffer:offerModel];
        }
    } else {
        if ([delegate respondsToSelector:@selector(myOfferNativeFailToShowOffer:error:)]) { [delegate myOfferNativeFailToShowOffer:offerModel error:[NSError errorWithDomain:@"com.anythink.MyOfferNativeShowing" code:10001 userInfo:@{NSLocalizedDescriptionKey:@"MyOffer has failed to show Native", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"Native's not ready for offerID:%@", offerModel.offerID]}]]; }
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController*)viewController{
    
   //TODO something when storeit is close
    
}


@end



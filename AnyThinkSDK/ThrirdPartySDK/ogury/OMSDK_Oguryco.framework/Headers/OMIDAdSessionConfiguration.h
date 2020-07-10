//
//  OMIDAdSessionConfiguration.h
//  AppVerificationLibrary
//
//  Created by Saraev Vyacheslav on 15/09/2017.
//

#import <UIKit/UIKit.h>

/**
 * Identifies which integration layer is responsible for sending certain events.
 */
typedef NS_ENUM(NSUInteger, OMIDOwner) {
    /** The integration will send the event from a JavaScript session script. */
    OMIDJavaScriptOwner = 1,
    /** The integration will send the event from the native layer. */
    OMIDNativeOwner = 2,
    /** The integration will not send the event. */
    OMIDNoneOwner = 3
};


/**
 *  List of supported creative types
 */
typedef NS_ENUM(NSUInteger, OMIDCreativeType) {
    // Creative type will be set by JavaScript session script.
    // Integrations must also pass Owner.JAVASCRIPT for impressionOwner.
    OMIDCreativeTypeDefinedByJavaScript = 1,
    // Remaining values set creative type in native layer.
    OMIDCreativeTypeHtmlDisplay = 2,
    OMIDCreativeTypeNativeDisplay = 3,
    OMIDCreativeTypeVideo = 4,
    OMIDCreativeTypeAudio = 5
};

/**
 * List of supported impression types
 */
typedef NS_ENUM(NSUInteger, OMIDImpressionType) {
  // ImpressionType will be set by JavaScript session script.
  // Integrations must also pass Owner.JAVASCRIPT for impressionOwner.
  OMIDImpressionTypeDefinedByJavaScript = 1,
  // Remaining values set ImpressionType in native layer.
  OMIDImpressionTypeUnspecified = 2,
  OMIDImpressionTypeLoaded = 3,
  OMIDImpressionTypeBeginToRender = 4,
  OMIDImpressionTypeOnePixel = 5,
  OMIDImpressionTypeViewable = 6,
  OMIDImpressionTypeAudible = 7,
  OMIDImpressionTypeOther = 8
};

/**
 * The ad session configuration supplies the owner for both the impression and video events.
 * The OMID JS service will use this information to help identify where the source of these
 * events is expected to be received.
 */
@interface OMIDOgurycoAdSessionConfiguration : NSObject

@property OMIDCreativeType creativeType;
@property OMIDImpressionType impressionType;
@property OMIDOwner impressionOwner;
@property OMIDOwner mediaEventsOwner;
@property BOOL isolateVerificationScripts;

- (nullable instancetype)initWithCreativeType:(OMIDCreativeType)creativeType
                               impressionType:(OMIDImpressionType)impressionType
                              impressionOwner:(OMIDOwner)impressionOwner
                             mediaEventsOwner:(OMIDOwner)mediaEventsOwner
                   isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                        error:(NSError *_Nullable *_Nullable)error;

#pragma mark - Deprecated Methods

/**
 * Returns nil and sets error if OMID isn't active or arguments are invalid.
 * Note: Planned to be deprecated in OM SDK 1.3.2.
 * @param impressionOwner providing details of who is responsible for triggering the impression event.
 * @param videoEventsOwner providing details of who is responsible for triggering video events. This is only required for video ad sessions and should be set to videoEventsOwner:OMIDNoneOwner for display ad sessions.
 * @param isolateVerificationScripts determines whether verification scripts will be placed in a sandboxed environment. This will not have any effect for native sessions.
 */
- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                      isolateVerificationScripts:(BOOL)isolateVerificationScripts
                                           error:(NSError *_Nullable *_Nullable)error;

- (nullable instancetype)initWithImpressionOwner:(OMIDOwner)impressionOwner
                                videoEventsOwner:(OMIDOwner)videoEventsOwner
                                           error:(NSError *_Nullable *_Nullable)error __deprecated_msg("Use -initWithImpressionOwner:videoEventsOwner:isolateVerificationScripts:error: instead.");

@end


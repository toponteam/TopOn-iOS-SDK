//
//  OMIDMediaEvents.h
//  AppVerificationLibrary
//
//  Created by Justin Hines on 6/13/19.
//

#import <Foundation/Foundation.h>
#import "OMIDAdSession.h"
#import "OMIDVASTProperties.h"

/**
 *  List of supported media event player states.
 */
typedef NS_ENUM(NSUInteger, OMIDPlayerState) {
    OMIDPlayerStateMinimized,
    OMIDPlayerStateCollapsed,
    OMIDPlayerStateNormal,
    OMIDPlayerStateExpanded,
    OMIDPlayerStateFullscreen
};

/**
 *  List of supported media event user interaction types.
 */
typedef NS_ENUM(NSUInteger, OMIDInteractionType) {
    OMIDInteractionTypeClick,
    OMIDInteractionTypeAcceptInvitation
};

/**
 *  This provides a complete list of native media events supported by OMID.
 * Using this event API assumes the media player is fully responsible for communicating all media events at the appropriate times.
 * Only one media events implementation can be associated with the ad session and any attempt to create multiple instances will result in an error.
 */
@interface OMIDOgurycoMediaEvents : NSObject

/**
 *  Initializes media events instance for the associated ad session.
 *  Any attempt to create a media events instance will fail if the supplied ad session has already started.
 *
 * @param session The ad session associated with the ad events.
 * @return A new media events instance. Returns nil if the supplied ad session is nil or if a media events instance has already been registered with the ad session or if a media events instance has been created after the ad session has started.
 * @see OMIDAdSession
 */
- (nullable instancetype)initWithAdSession:(nonnull OMIDOgurycoAdSession *)session error:(NSError *_Nullable *_Nullable)error;

/**
 *  Notifies all media listeners that media content has been loaded and ready to start playing.
 *
 * @param vastProperties The parameters containing static information about the media placement.
 * @see OMIDVASTProperties
 */
- (void)loadedWithVastProperties:(nonnull OMIDOgurycoVASTProperties *)vastProperties;

/**
 *  Notifies all media listeners that media content has started playing.
 *
 * @param duration The duration of the selected media (in seconds).
 * @param mediaPlayerVolume The volume from the native media player with a range between 0 and 1.
 */
- (void)startWithDuration:(CGFloat)duration
        mediaPlayerVolume:(CGFloat)mediaPlayerVolume;

/**
 *  Notifies all media listeners that media playback has reached the first quartile.
 */
- (void)firstQuartile;

/**
 *  Notifies all media listeners that media playback has reached the midpoint.
 */
- (void)midpoint;

/**
 *  Notifies all media listeners that media playback has reached the third quartile.
 */
- (void)thirdQuartile;

/**
 *  Notifies all media listeners that media playback is complete.
 */
- (void)complete;

/**
 *  Notifies all media listeners that media playback has paused after a user interaction.
 */
- (void)pause;

/**
 *  Notifies all media listeners that media playback has resumed (after being paused) after a user interaction.
 */
- (void)resume;

/**
 *  Notifies all media listeners that media playback has stopped as a user skip interaction.
 *  Once skipped media it should not be possible for the media to resume playing content.
 */
- (void)skipped;

/**
 *  Notifies all media listeners that media playback has stopped and started buffering.
 */
- (void)bufferStart;

/**
 *  Notifies all media listeners that buffering has finished and media playback has resumed.
 */
- (void)bufferFinish;

/**
 *  Notifies all media listeners that the media player volume has changed.
 *
 * @param playerVolume The volume from the native media player with a range between 0 and 1.
 */
- (void)volumeChangeTo:(CGFloat)playerVolume;

/**
 *  Notifies all media listeners that media player state has changed. See {@link OMIDPlayerState} for list of supported states.
 *
 * @param playerState The latest media player state.
 * @see OMIDPlayerState
 */
- (void)playerStateChangeTo:(OMIDPlayerState)playerState;

/**
 *  Notifies all media listeners that the user has performed an ad interaction. See {@link OMIDInteractionType} fro list of supported types.
 *
 * @param interactionType The latest user integration.
 * @see OMIDInteractionType
 */
- (void)adUserInteractionWithType:(OMIDInteractionType)interactionType
NS_SWIFT_NAME(adUserInteraction(withType:));

@end


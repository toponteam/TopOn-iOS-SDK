//
//  KSAdPlayerCacheView.h
//  Aspects
//
//  Created by xuzhijun on 2020/2/12.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KSAdBasePlayerView.h"


//enum Status {
//    case unknown        // 初始状态
//    case buffering      // 加载中
//    case playing        // 播放中
//    case paused         // 暂停
//    case end            // 播放到末尾
//    case error          // 播放出错
//}

typedef NS_ENUM(NSInteger, KSAdPlayerStatus) {
    KSAdPlayerStatus_Unknown        =           0,  // 初始状态
    KSAdPlayerStatus_Buffering,                     // 加载中
    KSAdPlayerStatus_Playing,                       // 播放中
    KSAdPlayerStatus_Paused,                        // 暂停
    KSAdPlayerStatus_End,                           // 播放到末尾
    KSAdPlayerStatus_Error,                         // 播放出错
};


@interface KSAdPlayerCacheView : KSAdBasePlayerView

@end

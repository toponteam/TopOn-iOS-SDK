//
//  ATDrawViewController.h
//  AnyThinkSDKDemo
//
//  Created by Topon on 2020/2/25.
//  Copyright © 2020 AnyThink. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN
extern NSString *const kKSDrawPlacement;
extern NSString *const kTTDrawPlacementName;

@interface ATDrawViewController : UIViewController
-(instancetype) initWithPlacementName:(NSString*)name;
+(NSDictionary<NSString*, NSString*>*)nativePlacementIDs;
@end

NS_ASSUME_NONNULL_END

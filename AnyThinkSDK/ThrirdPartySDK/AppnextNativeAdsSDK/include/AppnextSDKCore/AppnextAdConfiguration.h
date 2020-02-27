//
//  AppnextAdConfiguration.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 11/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextAdConfiguration : NSObject

@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *postback;
@property (nonatomic, strong) NSString *buttonColor;
@property (nonatomic, strong) NSString *preferredOrientation;
@property (nonatomic, assign) BOOL clickInApp;

@end

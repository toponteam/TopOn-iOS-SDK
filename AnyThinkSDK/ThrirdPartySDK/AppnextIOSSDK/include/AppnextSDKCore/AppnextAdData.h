//
//  AppnextAdData.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 25/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextAdData : NSObject <NSCoding, NSCopying>

@property (nonatomic, strong, readonly) NSString *buttonText;
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *desc;
@property (nonatomic, strong, readonly) NSString *urlImg;
@property (nonatomic, strong, readonly) NSString *urlImgWide;
@property (nonatomic, strong, readonly) NSString *categories;
@property (nonatomic, strong, readonly) NSString *idx;
@property (nonatomic, strong, readonly) NSString *iosPackage;
@property (nonatomic, strong, readonly) NSString *supportedDevices;
@property (nonatomic, strong, readonly) NSString *urlVideo;
@property (nonatomic, strong, readonly) NSString *urlVideoHigh;
@property (nonatomic, strong, readonly) NSString *urlVideo30Sec;
@property (nonatomic, strong, readonly) NSString *urlVideo30SecHigh;
@property (nonatomic, strong, readonly) NSString *bannerId; // The Identifier
@property (nonatomic, strong, readonly) NSString *campaignId;
@property (nonatomic, strong, readonly) NSString *country;
@property (nonatomic, strong, readonly) NSString *campaignType;
@property (nonatomic, strong, readonly) NSString *supportedVersion;
@property (nonatomic, strong, readonly) NSString *storeRating;
@property (nonatomic, strong, readonly) NSString *appSize;

@end

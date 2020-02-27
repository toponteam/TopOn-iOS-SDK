//
//  AppnextAdData+InternalExtras.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 26/07/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <AppnextSDKCore/AppnextAdData.h>

@interface AppnextAdData()

@property (nonatomic, strong) NSString *buttonText;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *pixelImp;
@property (nonatomic, strong) NSString *urlImg;
@property (nonatomic, strong) NSString *urlImgWide;
@property (nonatomic, strong) NSString *urlApp;
@property (nonatomic, strong) NSString *revenueType;
@property (nonatomic, strong) NSString *revenueRate;
@property (nonatomic, strong) NSString *categories;
@property (nonatomic, strong) NSString *idx;
@property (nonatomic, strong) NSString *iosPackage;
@property (nonatomic, strong) NSString *supportedDevices;
@property (nonatomic, strong) NSString *urlVideo;
@property (nonatomic, strong) NSString *urlVideoHigh;
@property (nonatomic, strong) NSString *urlVideo30Sec;
@property (nonatomic, strong) NSString *urlVideo30SecHigh;
@property (nonatomic, strong) NSString *bannerId; // The Identifier
@property (nonatomic, strong) NSString *campaignId;
@property (nonatomic, strong) NSString *country;
@property (nonatomic, strong) NSString *campaignType;
@property (nonatomic, strong) NSString *supportedVersion;
@property (nonatomic, strong) NSString *storeRating;
@property (nonatomic, strong) NSString *appSize;
@property (nonatomic, strong) NSString *pbaBId;
@property (nonatomic, strong) NSString *pbaZId;
@property (nonatomic, strong) NSString *zId;
@property (nonatomic, assign) NSUInteger shownCount; // Application managed data
@property (nonatomic, strong) NSDate *lastShown; // Application managed data

+ (instancetype) adDataWithButtonText:(NSString *)buttonText
                                title:(NSString *)title
                          description:(NSString *)description
                             pixelImp:(NSString *)pixelImp
                             urlImage:(NSString *)urlImage
                         urlImageWide:(NSString *)urlImageWide
                       urlApplication:(NSString *)urlApplication
                          revenueType:(NSString *)revenueType
                          revenueRate:(NSString *)revenueRate
                           categories:(NSString *)categories
                                  idx:(NSString *)idx
                           iosPackage:(NSString *)iosPackage
                     supportedDevices:(NSString *)supportedDevices
                             urlVideo:(NSString *)urlVideo
                         urlVideoHigh:(NSString *)urlVideoHigh
                        urlVideo30Sec:(NSString *)urlVideo30Sec
                    urlVideo30SecHigh:(NSString *)urlVideo30SecHigh
                             bannerId:(NSString *)bannerId
                           campaignId:(NSString *)campaignId
                              country:(NSString *)country
                         campaignType:(NSString *)campaignType
                     supportedVersion:(NSString *)supportedVersion
                          storeRating:(NSString *)storeRating
                              appSize:(NSString *)appSize
                               pbaBId:(NSString *)pbaBId
                               pbaZId:(NSString *)pbaZId
                                  zId:(NSString *)zId;

+ (instancetype) adDataWithData:(AppnextAdData *)data;

- (instancetype) initWithBannerId:(NSString *)bannerId;
- (BOOL) hasImage;
- (BOOL) hasVideo;

@end

@interface AppnextAdData(InternalExtras)

@property (nonatomic, assign) BOOL urlVideoInvalid;
@property (nonatomic, assign) BOOL urlVideoHighInvalid;
@property (nonatomic, assign) BOOL urlVideo30SecInvalid;
@property (nonatomic, assign) BOOL urlVideo30SecHighInvalid;

- (void) markVideoInvalid:(NSString *)urlVideo;

@end

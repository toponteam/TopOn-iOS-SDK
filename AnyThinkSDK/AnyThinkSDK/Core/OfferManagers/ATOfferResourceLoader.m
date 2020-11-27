//
//  ATOfferResourceLoader.m
//  AnyThinkOffer
//
//  Created by Martin Lau on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATOfferResourceLoader.h"
#import "ATThreadSafeAccessor.h"
#import "ATOfferResourceManager.h"
#import "Utilities.h"
#import "ATAgentEvent.h"
@interface ATOfferResourceLoader()
@property(nonatomic, readonly) NSMutableDictionary<NSString*, NSMutableArray<void(^)(NSError*)>*>* completionCallbackStorage;
@property(nonatomic, readonly) ATThreadSafeAccessor *completionCallbackStorageAccessor;
@end
@implementation ATOfferResourceLoader
+(instancetype) sharedLoader {
    static ATOfferResourceLoader *sharedLoader = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedLoader = [[ATOfferResourceLoader alloc] init];
    });
    return sharedLoader;
}

-(instancetype) init {
    self = [super init];
    if (self != nil) {
        _completionCallbackStorage = [NSMutableDictionary<NSString*, NSMutableArray<void(^)(NSError*)>*> dictionary];
        _completionCallbackStorageAccessor = [ATThreadSafeAccessor new];
        if (![[NSFileManager defaultManager] fileExistsAtPath:[ATOfferResourceLoader resourceRootPath] isDirectory:NULL]) { [[NSFileManager defaultManager] createDirectoryAtPath:[ATOfferResourceLoader resourceRootPath] withIntermediateDirectories:NO attributes:nil error:nil]; }
    }
    return self;
}

+(NSString*)resourceRootPath {
    return [[Utilities documentsPath] stringByAppendingPathComponent:@"com.anythink.OfferResource"];
}

+(NSString*)resourcePathForURL:(NSString*)resourceURL {
    NSString *format = [[resourceURL componentsSeparatedByString:@"."] lastObject];
    return resourceURL.md5 != nil ? [NSString stringWithFormat:@"%@%@", [[ATOfferResourceLoader resourceRootPath] stringByAppendingPathComponent:resourceURL.md5], format != nil ? [@"." stringByAppendingString:format] : @""] : @"";
}

static NSString *const kOfferLoadingErrorDomain = @"com.anythink.OfferResourceLoading";
-(void)loadOfferWithOfferModel:(ATOfferModel*)offerModel placementID:(NSString *) placementID resourceDownloadTimeout:(NSTimeInterval)resourceDownloadTimeout extra:(NSDictionary*)extra completion:(void(^)(NSError *error))completion {
    if (offerModel != nil) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            ATOfferResourceModel *resourceModel = [[ATOfferResourceManager sharedManager] retrieveResourceModelWithResourceID:offerModel.localResourceID];
            
            if (resourceModel != nil) {
                completion(nil);
            } else {//Load resource for offer
                if ([offerModel.resourceURLs count] > 0) {
                    [weakSelf.completionCallbackStorageAccessor writeWithBlock:^{
                        if (weakSelf.completionCallbackStorage[offerModel.localResourceID] != nil) {
                            //Entry for offerModel.localResourceID being found in completionCallbackStorage means download for resouceID has been started before, just save the completion callback for later invocation & nothing else needs to be done.
                            if (completion != nil) { [weakSelf.completionCallbackStorage[offerModel.localResourceID] addObject:completion]; }
                        } else {
                            if (completion != nil) {
                                NSMutableArray<void(^)(NSError*)> *callbacks = [NSMutableArray<void(^)(NSError*)> arrayWithObject:completion];
                                weakSelf.completionCallbackStorage[offerModel.localResourceID] = callbacks;
                            }
                            
                            __block NSInteger numberOfFinishedDownload = 0;
                            __block NSInteger numberOfSucDownloads = 0;
                            __block BOOL requestTimeout = NO;
                            __block BOOL requestFinish = NO;
                            NSMutableDictionary<NSString*, NSError*> *errorDict = [NSMutableDictionary<NSString*, NSError*> dictionary];
                            ATOfferResourceModel *resourceModel = [[ATOfferResourceModel alloc] init];
                            dispatch_queue_t download_completion_queue = dispatch_queue_create("com.anythink.OfferResourceDownloadQueue", DISPATCH_QUEUE_SERIAL);
                            
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(resourceDownloadTimeout * NSEC_PER_SEC)), download_completion_queue, ^{
                                requestTimeout = YES;
                                if (!requestFinish) { [weakSelf finishResourceDownloadWithOfferModel:offerModel resourceModel:resourceModel error:[NSError errorWithDomain:kOfferLoadingErrorDomain code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Offer has failed to load resource", NSLocalizedFailureReasonErrorKey:@"Request timeout"}]]; }
                            });
                            
                            [offerModel.resourceURLs enumerateObjectsUsingBlock:^(NSString * _Nonnull resourceURL, NSUInteger idx, BOOL * _Nonnull stop) {
                                NSNumber *startTimestamp = [Utilities normalizedTimeStamp];
                                [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:resourceURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                    dispatch_async(download_completion_queue, ^{
                                        NSInteger downloadResult = 0;
                                        numberOfFinishedDownload++;
                                        if ([data length] > 0 && ((NSHTTPURLResponse*)response).statusCode == 200) {//Handle resource
                                            downloadResult = 1;
                                            numberOfSucDownloads++;
                                            NSString *resourcePath = [ATOfferResourceLoader resourcePathForURL:resourceURL];
                                            [data writeToFile:resourcePath atomically:YES];
                                            [resourceModel setResourcePath:resourcePath forURL:resourceURL];
                                            [resourceModel accumulateLength:[data length]];
                                        } else {
                                            errorDict[resourceURL] = error != nil ? error : [NSError errorWithDomain:kOfferLoadingErrorDomain code:((NSHTTPURLResponse*)response).statusCode userInfo:@{NSLocalizedDescriptionKey:@"Offer has failed to load resource"}];
                                        }
                                        if ([resourceURL isEqualToString:offerModel.videoURL]) {
                                            NSNumber *endTimestampe = [Utilities normalizedTimeStamp];
                                            NSMutableDictionary *agentEventExtra = [NSMutableDictionary dictionaryWithObjectsAndKeys:offerModel.offerID != nil ? offerModel.offerID : @"", kAgentEventExtraInfoMyOfferOfferIDKey, resourceURL != nil ? resourceURL : @"", kAgentEventExtraInfoMyOfferResourceURLKey, @(downloadResult), kAgentEventExtraInfoMyOfferVideoDownloadResultKey, startTimestamp, kAgentEventExtraInfoMyOfferVideoDownloadStartTimestampKey, endTimestampe, kAgentEventExtraInfoMyOfferVideoDownloadFinishTimestampKey, @(offerModel.offerModelType), kAgentEventExtraInfoMyOfferVideoDownloadModelTypeKey, nil];
                                            
                                            if (downloadResult == 1) {
                                                agentEventExtra[kAgentEventExtraInfoMyOfferVideoSizeKey] = @([data length] / 1024);
                                                agentEventExtra[kAgentEventExtraInfoMyOfferVideoDownloadTimeKey] = @([endTimestampe doubleValue] - [startTimestamp doubleValue]);
                                            } else {
                                                agentEventExtra[kAgentEventExtraInfoMyOfferVideoDownloadFailReasonKey] = [NSString stringWithFormat:@"%@%ld", error, ((NSHTTPURLResponse*)response).statusCode];
                                            }
                                            [[ATAgentEvent sharedAgent] saveEventWithKey:kATAgentEventKeyMyOfferVideoDownload placementID:placementID unitGroupModel:nil extraInfo:agentEventExtra];
                                        }
                                        
                                        if (numberOfFinishedDownload == [offerModel.resourceURLs count]) {
                                            requestFinish = YES;
                                            if (!requestTimeout) { [weakSelf finishResourceDownloadWithOfferModel:offerModel resourceModel:resourceModel error:numberOfSucDownloads == [offerModel.resourceURLs count] ? nil : [NSError errorWithDomain:kOfferLoadingErrorDomain code:10001 userInfo:@{NSLocalizedDescriptionKey:@"Offer has failed to load resource", NSLocalizedFailureReasonErrorKey:[NSString stringWithFormat:@"%@", errorDict]}]]; }
                                        }
                                    });
                                }] resume];
                            }];
                        }
                    }];
                }
            }
        });
    }
}

//This method is not thread-safe, only to be used within certain context
-(void) finishResourceDownloadWithOfferModel:(ATOfferModel*)offerModel resourceModel:(ATOfferResourceModel*)resourceModel error:(NSError*)error {
    if (error == nil && resourceModel != nil) { [[ATOfferResourceManager sharedManager] saveResourceModel:resourceModel forResourceID:offerModel.localResourceID]; }
    __weak typeof(self) weakSelf = self;
    [weakSelf.completionCallbackStorageAccessor writeWithBlock:^{
        NSMutableArray<void(^)(NSError*)> *callbacks = weakSelf.completionCallbackStorage[offerModel.localResourceID];
        [callbacks enumerateObjectsUsingBlock:^(void (^ _Nonnull callback)(NSError*), NSUInteger idx, BOOL * _Nonnull stop) { callback(error); }];
        [weakSelf.completionCallbackStorage removeObjectForKey:offerModel.localResourceID];
    }];
}
@end

//
//  Utilities.m
//  AnyThinkSDK
//
//  Created by Martin Lau on 10/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "Utilities.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/AdSupport.h>
#import "ATAPI+Internal.h"
#import "ATPlacementModel.h"
#import "ATAdManager.h"
#import "ATAdManager+Internal.h"
#import "ATAppSettingManager.h"
#import <zlib.h>
#import <objc/runtime.h>
#import <sys/utsname.h>
#import <execinfo.h>
#import <sys/sysctl.h>
#import <WebKit/WebKit.h>
#pragma clang diagnostic ignored "-Wcast-qual"
static NSString *const kAESEncryptionKey = @"0123456789abecef";
void AT_SafelyRun(void(^Block)(void)) {
    @try {
        Block();
    } @catch (NSException *exception) {
        NSArray<NSString*>* callStackSymbols = [NSThread callStackSymbols];
        if ([callStackSymbols count] > 1) {
            NSString *sourceString = [callStackSymbols objectAtIndex:1];
            NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
            NSArray<NSString*>* components = [sourceString  componentsSeparatedByCharactersInSet:separatorSet];
            if ([components count] > 0) {
                NSMutableArray<NSString*> *callerInfo = [NSMutableArray arrayWithArray:components];
                if ([callerInfo count] > 0) {
                    [callerInfo removeObject:@""];
                    if ([callerInfo count] > 4) {
                        [ATLogger logError:[NSString stringWithFormat:@"Error: Exception Caught while running block in method: %@ of class: %@, exception:%@.", callerInfo[4], callerInfo[3], exception] type:ATLogTypeInternal];
                    }
                }//End of callerInfo count
            }
        }//End of callStackSymbols count
    } @finally {
        //
    }
}

NSArray* CallstackSymbols() {
    NSMutableArray *retSymbols = [NSMutableArray arrayWithCapacity:32];
    char **symbols;
    int size = 32;
    void *buffer[32];
    int nptrs;
    nptrs = backtrace(buffer, size);
    symbols = backtrace_symbols(buffer, nptrs);
    if (symbols != NULL) {
        for (int i = 0; i < nptrs; i++) {
            if (symbols[i] != NULL) {
                NSString *str = [NSString stringWithUTF8String:(const char*)symbols[i]];
                if (str != nil) { [retSymbols addObject:str]; }
            }
        }
    }
    free(symbols);
    return retSymbols;
}

BOOL AT_DebuggerAttached(void) {
    static BOOL debuggerIsAttached = NO;
    
    static dispatch_once_t debuggerPredicate;
    dispatch_once(&debuggerPredicate, ^{
        struct kinfo_proc info;
        size_t info_size = sizeof(info);
        int name[4];
        
        name[0] = CTL_KERN;
        name[1] = KERN_PROC;
        name[2] = KERN_PROC_PID;
        name[3] = getpid(); // from unistd.h, included by Foundation
        
        if (sysctl(name, 4, &info, &info_size, NULL, 0) == -1) {
            debuggerIsAttached = NO;
        }
        
        if (!debuggerIsAttached && (info.kp_proc.p_flag & P_TRACED) != 0)
            debuggerIsAttached = YES;
    });
    
    return debuggerIsAttached;
}

BOOL AT_ProxyEnabled(void) {
    NSDictionary *proxySettings =  (__bridge NSDictionary *)(CFNetworkCopySystemProxySettings());
    NSString *host = [proxySettings objectForKey:(__bridge NSString *)kCFNetworkProxiesHTTPProxy];
    CFRelease((__bridge CFDictionaryRef)proxySettings);
    if (host && [host isKindOfClass:[NSString class]] && host.length > 0) {
        return YES;
    } else {
        return NO;
    }
}

@implementation Utilities
+(NSNumber*)normalizedTimeStamp {
    return @((NSInteger)([[NSDate date] timeIntervalSince1970] * 1000));
}

+(NSNumber*)screenOrientation {
    return UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]) ? @1 : @2;
}

+(NSString*)screenResolution {
    return [NSString stringWithFormat:@"%ld*%ld", (NSInteger)(CGRectGetWidth([UIScreen mainScreen].bounds) * [UIScreen mainScreen].scale), (NSInteger)(CGRectGetHeight([UIScreen mainScreen].bounds) * [UIScreen mainScreen].scale)];
}

+(NSString*)appBundleName {
    return [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
}

+(NSString*)appBundleID {
    return ([[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"] != nil)?[[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"]:@"";
}

+(NSString*)appBundleVersion {
    return ([[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] != nil)?[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"]:@"";
}

+(NSNumber*)platform {
    return @2;
}

+(NSString*)brand {
    return @"apple";
}

+(NSString*)model {
    NSString *model = @"";
    @try {
        struct utsname systemInfo;
        uname(&systemInfo);
        
         model = [NSString stringWithCString:systemInfo.machine
                                  encoding:NSUTF8StringEncoding];
    } @catch (NSException *exception) {
        model = @"";
    } @finally {
        
    }
    return model;
}

+(NSString*)systemName {
    return [UIDevice currentDevice].systemVersion;
}

+(NSString*)systemVersion {
    return [UIDevice currentDevice].systemVersion;
}

+(NSString*)language {
    return [NSLocale preferredLanguages][0];
}

+(NSString*)timezone {
    return [NSTimeZone systemTimeZone].abbreviation;
}

+(NSString*)mobileCountryCode {
    @try {
        CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
        return [networkInfo.subscriberCellularProvider.isoCountryCode length] > 0 ? [networkInfo.subscriberCellularProvider.isoCountryCode uppercaseString] : @"";
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Exception caught while fetching mobileCountryCode:%@", exception] type:ATLogTypeInternal];
    } @finally {
        return @"";
    }
}

+(NSString*)mobileNetworkCode {
    @try {
        CTTelephonyNetworkInfo *networkInfo = [CTTelephonyNetworkInfo new];
        return [networkInfo.subscriberCellularProvider.mobileNetworkCode length] > 0 ? networkInfo.subscriberCellularProvider.mobileNetworkCode : @"";
    } @catch (NSException *exception) {
        [ATLogger logError:[NSString stringWithFormat:@"Exception caught while fetching mobileNetworkCode:%@", exception] type:ATLogTypeInternal];
    } @finally {
        return @"";
    }
}

+(NSString*)advertisingIdentifier {
//    return [ASIdentifierManager sharedManager].advertisingTrackingEnabled ? [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString : @"";
    //remove check idfa enable to solve
    return [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString != nil ? [ASIdentifierManager sharedManager].advertisingIdentifier.UUIDString : @"";
}

+(NSString*)idfv {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString] != nil ? [[[UIDevice currentDevice] identifierForVendor] UUIDString] : @"";
}

static NSString *const UAInfoKey = @"user_agent_info_key";
static NSString *const UAInfoSystemVersionKey = @"sys_ver";
static NSString *const UAInfoUAKey = @"ua";
+(NSString*)userAgent {
   return [ATAPI sharedInstance].userAgent;
}

+(NSDictionary*)networkVersions {
    return [[ATAPI sharedInstance] networkVersions];
}

+(NSString*) generateRequestID {
    NSString *rawRequestID = [NSString stringWithFormat:@"%@&%@&%@&%d", [self advertisingIdentifier], [ATAppSettingManager sharedManager].ATID != nil ? [ATAppSettingManager sharedManager].ATID : @"", [self normalizedTimeStamp], arc4random_uniform(10000)];
    return [rawRequestID md5];
}

+(NSString*)documentsPath {
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

+(NSString*)computeSignWithParameters:(NSDictionary *)parameters {
    NSArray *keys = [[parameters allKeys] sortedArrayUsingSelector:@selector(compare:)];
    __block NSString *rawSign = @"";
    [keys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        rawSign = [rawSign stringByAppendingFormat:@"%@%@=%@", [rawSign length] > 0 ? @"&" : @"", obj, parameters[obj]];
    }];
    return [[NSString stringWithFormat:@"%@%@", [ATAPI sharedInstance].appKey, rawSign] md5];
}

NSString *const kCallStackSymbolCallerMethodKey = @"caller_method";
NSString *const kCallStackSymbolCallerClassKey = @"caller_class";
+(NSArray<NSDictionary<NSString*, NSString*>*>*)parseCallStackSymbols:(NSArray<NSString*>*)callStackSymbols {
    NSMutableArray<NSDictionary<NSString*, NSString*>*> *callerInfos = [NSMutableArray<NSDictionary<NSString*, NSString*>*> array];
    [callStackSymbols enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSCharacterSet *separatorSet = [NSCharacterSet characterSetWithCharactersInString:@" -[]+?.,"];
        NSArray<NSString*>* components = [obj componentsSeparatedByCharactersInSet:separatorSet];
        if ([components count] > 0) {
            NSMutableArray<NSString*> *callerInfo = [NSMutableArray arrayWithArray:components];
            if ([callerInfo count] > 0) {
                [callerInfo removeObject:@""];
                //3 class, 4 method
                if ([callerInfo count] > 4) { [callerInfos addObject:@{kCallStackSymbolCallerClassKey:callerInfo[3], kCallStackSymbolCallerMethodKey:callerInfo[4]}]; }
            }//End of callerInfo count
        }
    }];
    return callerInfos;
}

+(BOOL) validateShowingScene:(NSString*)scene {
    NSMutableCharacterSet *set = [NSMutableCharacterSet decimalDigitCharacterSet];
    [set formUnionWithCharacterSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    [set formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    
    return ([scene isKindOfClass:[NSString class]] && [scene length] == 14 && [scene rangeOfCharacterFromSet:[set invertedSet]].location == NSNotFound);
}

+(BOOL) validateDeviceId:(NSString*)deviceId {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0-"];
    return ([deviceId isKindOfClass:[NSString class]] && [deviceId length] > 0 && [deviceId rangeOfCharacterFromSet:[set invertedSet]].location != NSNotFound);
}

+(CGSize) sizeFromString:(NSString *)sizeStr {
    CGSize size = CGSizeZero;
    NSArray<NSString*>* comp = [sizeStr componentsSeparatedByString:@"x"];
    if ([comp count] == 2 && [comp[0] respondsToSelector:@selector(doubleValue)] && [comp[1] respondsToSelector:@selector(doubleValue)]) { size = CGSizeMake([comp[0] doubleValue], [comp[1] doubleValue]); }
    return size;
}

+(BOOL)higherThanIOS13 {
    NSString *version = [UIDevice currentDevice].systemVersion;
    return version.doubleValue >= 13.0;
}

+(BOOL)isBlankDictionary:(NSDictionary *)dic {
    if (!dic) {
        return YES;
    }
    if ([dic isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    if (!dic.count) {
        return YES;
    }
    if (dic == nil) {
        return YES;
    }
    if (dic == NULL) {
        return YES;
    }
    return NO;
}

@end

@implementation NSDate(ATUtilities)
+(instancetype) normalizaedDate {
    NSDate *normalizaedDate = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: normalizaedDate];
    normalizaedDate = [normalizaedDate dateByAddingTimeInterval:interval];
    return normalizaedDate;
}

-(NSInteger) numberOfDaysSinceDate:(NSDate*)date {
    NSDate*(^TwelveOClock)(NSDate *date) = ^NSDate*(NSDate* date){
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSString *dateStr = [formater stringFromDate:date];
        dateStr = [dateStr stringByReplacingCharactersInRange:NSMakeRange(@"yyyy-MM-dd ".length, @"HH:mm:ss".length) withString:@"12:00:00"];
        return [formater dateFromString:dateStr];
    };
    
    NSDate *twelveOClocked = TwelveOClock(self);
    NSDate *twelveOclockedDate = TwelveOClock(date);
    return [twelveOClocked timeIntervalSinceDate:twelveOclockedDate] / (24.0f * 3600.0f) + 1;
    
}
@end

@implementation NSData(ATKit)
+(instancetype) dataWithUTF8String:(const char*)string {
    return [[NSString stringWithUTF8String:string] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSData *)gzippedDataWithCompressionLevel_ATKit:(float)level
{
    if (self.length == 0 || [self isGzippedData_ATKit])
    {
        return self;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.opaque = Z_NULL;
    stream.avail_in = (uint)self.length;
    stream.next_in = (Bytef *)(void *)self.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    static const NSUInteger ChunkSize = 16384;
    
    NSMutableData *output = nil;
    int compression = (level < 0.0f)? Z_DEFAULT_COMPRESSION: (int)(roundf(level * 9));
    if (deflateInit2(&stream, compression, Z_DEFLATED, 31, 8, Z_DEFAULT_STRATEGY) == Z_OK)
    {
        output = [NSMutableData dataWithLength:ChunkSize];
        while (stream.avail_out == 0)
        {
            if (stream.total_out >= output.length)
            {
                output.length += ChunkSize;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            deflate(&stream, Z_FINISH);
        }
        deflateEnd(&stream);
        output.length = stream.total_out;
    }
    
    return output;
}

- (NSData *)gzippedData_ATKit
{
    return [self gzippedDataWithCompressionLevel_ATKit:-1.0f];
}

- (NSData *)gunzippedData_ATKit
{
    if (self.length == 0 || ![self isGzippedData_ATKit])
    {
        return self;
    }
    
    z_stream stream;
    stream.zalloc = Z_NULL;
    stream.zfree = Z_NULL;
    stream.avail_in = (uint)self.length;
    stream.next_in = (Bytef *)self.bytes;
    stream.total_out = 0;
    stream.avail_out = 0;
    
    NSMutableData *output = nil;
    if (inflateInit2(&stream, 47) == Z_OK)
    {
        int status = Z_OK;
        output = [NSMutableData dataWithCapacity:self.length * 2];
        while (status == Z_OK)
        {
            if (stream.total_out >= output.length)
            {
                output.length += self.length / 2;
            }
            stream.next_out = (uint8_t *)output.mutableBytes + stream.total_out;
            stream.avail_out = (uInt)(output.length - stream.total_out);
            status = inflate (&stream, Z_SYNC_FLUSH);
        }
        if (inflateEnd(&stream) == Z_OK)
        {
            if (status == Z_STREAM_END)
            {
                output.length = stream.total_out;
            }
        }
    }
    
    return output;
}

- (BOOL)isGzippedData_ATKit
{
    const UInt8 *bytes = (const UInt8 *)self.bytes;
    return (self.length >= 2 && bytes[0] == 0x1f && bytes[1] == 0x8b);
}
@end

@implementation NSArray (ATKit)
-(NSString*) jsonString_anythink {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:kNilOptions
                                                         error:&error];
    
    if (!jsonData) {
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

-(NSArray*) shuffledArray_anythink {
    NSMutableArray *mutableArr = [NSMutableArray arrayWithArray:self];
    for (NSUInteger i = [self count] - 1; i > 0; i--) { [mutableArr exchangeObjectAtIndex:arc4random_uniform(i + 1) withObjectAtIndex:i]; }
    return mutableArr;
}
@end

@implementation UIImage(ATKit)
+(instancetype) anythink_imageWithName:(NSString*)name {
    return [UIImage imageNamed:name inBundle:[NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"AnyThinkSDK" ofType:@"bundle"]] compatibleWithTraitCollection:nil];
}
@end

@implementation NSObject (ATObjectAssociation)
-(void) AT_setObject:(id)object forKey:(NSString*)key {
    objc_setAssociatedObject(self, (__bridge_retained void*)key, object, OBJC_ASSOCIATION_RETAIN);
}

-(id) AT_objectForKey:(NSString*)key {
    return objc_getAssociatedObject(self, (__bridge_retained void*)key);
}

+(NSString*)AT_internalKeyWithKey:(NSString*)key {
    return [NSString stringWithFormat:@"%@_%@", NSStringFromClass(self), key];
}
@end

#pragma mark - al category impl
@implementation UIView(Autolayout)
+(instancetype) internal_autolayoutView {
    UIView *view = [[self alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (NSArray<__kindof NSLayoutConstraint *> *)internal_addConstraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *, id> *)views {
    NSArray<__kindof NSLayoutConstraint*>* constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:opts metrics:metrics views:views];
    [self addConstraints:constraints];
    return constraints;
}

-(NSLayoutConstraint*)internal_addConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
    [self addConstraint:constraint];
    return constraint;
}
@end

@implementation UILabel(Autolayout)
+(instancetype) internal_autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment)textAlignment {
    UILabel *label = [UILabel internal_autolayoutView];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    return label;
}

+(instancetype) internal_autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor {
    return [self internal_autolayoutLabelFont:font textColor:textColor textAlignment:NSTextAlignmentLeft];
}
@end

@implementation UIButton(Autolayout)
+(instancetype) internal_autolayoutButtonWithType:(UIButtonType)type {
    UIButton *button = [UIButton buttonWithType:type];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}
@end

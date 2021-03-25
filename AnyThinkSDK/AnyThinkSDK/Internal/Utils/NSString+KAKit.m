//
//  NSString+KAKit.m
//  Demo
//
//  Created by Martin Lau on 27/03/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "NSString+KAKit.h"
#import "CommonCrypto/CommonDigest.h"
#import <CommonCrypto/CommonCryptor.h>
static NSString *kOriginalBase64Table = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
@implementation NSString (KAKit)
-(NSString*)stringByBase64Encoding_anythink {
    return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
}

-(NSString*)stringByBase64Decoding_anythink {
    NSString *decodedString = [[NSString alloc] initWithData:[[NSData alloc] initWithBase64EncodedString:self options:0] encoding:NSUTF8StringEncoding];
    return decodedString;
}

+(NSDictionary*)mappingDictionaryWithOriginalString:(NSString*)oriStr replacementString:recStr {
    if ([oriStr length] == 64 && [recStr length] == 64) {
        NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithCapacity:64];
        for (NSInteger i = 0; i < 64; i++) {
            [retDict setObject:[recStr substringWithRange:NSMakeRange(i, 1)] forKey:[oriStr substringWithRange:NSMakeRange(i, 1)]];
        }
        return retDict;
    } else {
        return nil;
    }
}

-(NSString*)base64EncodingUsingTable:(NSString *)table {
    NSString *base64String = [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSDictionary *encodeDic = [NSString mappingDictionaryWithOriginalString:kOriginalBase64Table replacementString:table];
    NSMutableString *encodeString = [NSMutableString string];
    
    for (int i = 0; i < base64String.length; i ++) {
        NSString *currentChracter = [base64String substringWithRange:NSMakeRange(i, 1)];
        NSString *replaceString = encodeDic[currentChracter];
        if (replaceString == nil) {
            replaceString = currentChracter;
        }
        [encodeString appendString:replaceString];
    }
    
    return encodeString;
}

-(NSString*)base64DecodingUsingTable:(NSString*)table {
    NSDictionary *decodeDic = [NSString mappingDictionaryWithOriginalString:table replacementString:kOriginalBase64Table];
    NSMutableString *decodeString = [NSMutableString string];
    
    for (int i = 0; i < self.length; i ++) {
        NSString *currentChracter = [self substringWithRange:NSMakeRange(i, 1)];
        NSString *replaceString = decodeDic[currentChracter];
        if (replaceString == nil) {
            replaceString = currentChracter;
        }
        [decodeString appendString:replaceString];
    }
    
    NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:decodeString options:0];
    NSString *finalString = [[NSString alloc] initWithData:decodeData encoding:NSUTF8StringEncoding];
    
    return finalString;
}

-(NSData*) dataByBase64EncodingUsingTable:(NSString*)table {
    NSString *base64String = [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    
    NSDictionary *encodeDic = [NSString mappingDictionaryWithOriginalString:kOriginalBase64Table replacementString:table];
    NSMutableString *encodeString = [NSMutableString string];
    
    for (int i = 0; i < base64String.length; i ++) {
        NSString *currentChracter = [base64String substringWithRange:NSMakeRange(i, 1)];
        NSString *replaceString = encodeDic[currentChracter];
        if (replaceString == nil) {
            replaceString = currentChracter;
        }
        [encodeString appendString:replaceString];
    }
    
    return [encodeString dataUsingEncoding:NSUTF8StringEncoding];
}
-(NSData*) dataByBase64DecodingUsingTable:(NSString*)table {
    NSDictionary *decodeDic = [NSString mappingDictionaryWithOriginalString:table replacementString:kOriginalBase64Table];
    NSMutableString *decodeString = [NSMutableString string];
    
    for (int i = 0; i < self.length; i ++) {
        NSString *currentChracter = [self substringWithRange:NSMakeRange(i, 1)];
        NSString *replaceString = decodeDic[currentChracter];
        if (replaceString == nil) {
            replaceString = currentChracter;
        }
        [decodeString appendString:replaceString];
    }
    
    return [[NSData alloc] initWithBase64EncodedString:decodeString options:0];
}

-(NSString*)md5 {
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

-(NSString*)stringByAES256EncryptUsingKey:(NSString*)key {
    NSData *result = [[self dataUsingEncoding:NSUTF8StringEncoding] aes256_encrypt:key];
    if (result && result.length > 0) {
        
        Byte *datas = (Byte*)[result bytes];
        NSMutableString *output = [NSMutableString stringWithCapacity:result.length * 2];
        for(int i = 0; i < result.length; i++){
            [output appendFormat:@"%02x", datas[i]];
        }
        return output;
    }
    return nil;
}

-(NSString*)stringByAES256DecryptUsingKey:(NSString*)key {
    NSMutableData *data = [NSMutableData dataWithCapacity:self.length / 2];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0', '\0', '\0'};
    int i;
    for (i=0; i < [self length] / 2; i++) {
        byte_chars[0] = [self characterAtIndex:i*2];
        byte_chars[1] = [self characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [data appendBytes:&whole_byte length:1];
    }
    NSData* result = [data aes256_decrypt:key];
    if (result && result.length > 0) {
        return [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    }
    return nil;
}

+(NSString*)stringWithData:(NSData*)data usingEncoding:(NSStringEncoding)encoding {
    return [[NSString alloc] initWithData:data encoding:encoding];
}


-(NSString*)stringUrlEncode {
    NSString *url = self;
    url = [url stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    return url;
}
-(NSString*)stringUrlDecode {
    NSString *url = self;
    url = [url stringByRemovingPercentEncoding];
    return url;
}

- (instancetype)optional {
    return self ? self : @"";
}

- (NSString *)fixECPMLoseWithPrice {
    return [[NSDecimalNumber decimalNumberWithString:self] stringValue];
}

@end

@implementation NSData(AES256)
- (NSData *)aes256_encrypt:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCBlockSizeAES128,
                                          [@"1269571569321021" dataUsingEncoding:NSUTF8StringEncoding].bytes,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}


- (NSData *)aes256_decrypt:(NSString *)key
{
    char keyPtr[kCCKeySizeAES128+1];
    bzero(keyPtr, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    NSUInteger dataLength = [self length];
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding,
                                          keyPtr, kCCBlockSizeAES128,
                                          [@"1269571569321021" dataUsingEncoding:NSUTF8StringEncoding].bytes,
                                          [self bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
        
    }
    free(buffer);
    return nil;
}
@end

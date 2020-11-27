//
//  NSString+KAKit.h
//  Demo
//
//  Created by Martin Lau on 27/03/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (KAKit)
-(NSString*)base64EncodingUsingTable:(NSString*)table;
-(NSString*)base64DecodingUsingTable:(NSString*)table;
-(NSData*) dataByBase64EncodingUsingTable:(NSString*)table;
-(NSData*) dataByBase64DecodingUsingTable:(NSString*)table;
-(NSString*)md5;
-(NSString*)stringByAES256EncryptUsingKey:(NSString*)key;
-(NSString*)stringByAES256DecryptUsingKey:(NSString*)key;

+(NSString*)stringWithData:(NSData*)data usingEncoding:(NSStringEncoding)encoding;

-(NSString*)stringByBase64Encoding_anythink;
-(NSString*)stringByBase64Decoding_anythink;

-(NSString*)stringUrlEncode;
-(NSString*)stringUrlDecode;

- (NSString *)fixECPMLoseWithPrice;

@end

@interface NSData(AES256)
-(NSData *) aes256_encrypt:(NSString *)key;
-(NSData *) aes256_decrypt:(NSString *)key;
@end

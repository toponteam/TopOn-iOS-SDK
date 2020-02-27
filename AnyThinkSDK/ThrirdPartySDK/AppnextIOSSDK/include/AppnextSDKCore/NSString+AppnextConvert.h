//
//  NSString+AppnextConvert.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 21/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AppnextConvert)

+ (NSString *) convertBOOLToString:(BOOL)value;
- (BOOL) convertToBOOL;
- (NSString *) convertToUTF8String;
- (UIInterfaceOrientation) convertToInterfaceOrientation;

@end

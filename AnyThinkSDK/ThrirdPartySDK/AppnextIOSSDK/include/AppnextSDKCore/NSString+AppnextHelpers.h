//
//  NSString+AppnextHelpers.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 28/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (AppnextHelpers)

- (BOOL) containsSubstring:(NSString *)str;
- (BOOL) rangeIsValid:(NSRange)range;

@end

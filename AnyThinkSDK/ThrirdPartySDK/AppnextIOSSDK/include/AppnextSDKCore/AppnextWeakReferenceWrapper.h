//
//  AppnextWeakReferenceWrapper.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 12/01/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

@interface AppnextWeakReferenceWrapper<__covariant ObjectType> : NSObject

+ (AppnextWeakReferenceWrapper *) weakReferenceWrapperWithObject:(ObjectType)object;

- (ObjectType) nonretainedWeakObjectValue;
- (void *) nonretainedOriginalObjectValue;
- (void) resetWrapper;

@end

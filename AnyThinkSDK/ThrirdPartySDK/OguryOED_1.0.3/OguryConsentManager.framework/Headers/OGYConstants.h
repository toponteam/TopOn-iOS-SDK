//
//  Constants.h
//  OguryConsentManager
//
//  Copyright © 2018 Ogury Ltd. All rights reserved.
//

#ifndef OGYConstants_h
#define OGYConstants_h

typedef NS_ENUM(NSInteger, ConsentManagerPurpose) {
    ConsentManagerPurposeInformation = 1,
    ConsentManagerPurposePersonalisation = 2,
    ConsentManagerPurposeAd = 3,
    ConsentManagerPurposeContent = 4,
    ConsentManagerPurposeMeasurement = 5
};

typedef NS_ENUM(NSInteger, ConsentManagerAnswer) {
    ConsentManagerAnswerFullApproval = 1,
    ConsentManagerAnswerPartialApproval = 2,
    ConsentManagerAnswerRefusal = 3,
    ConsentManagerAnswerNoAnswer = 4
};



#endif /* Constants_h */

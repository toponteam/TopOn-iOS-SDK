//
//  AppnextNetworkDefs.h
//  AppnextSDKCore
//
//  Created by Eran Mausner on 01/11/2016.
//  Copyright © 2016 Appnext. All rights reserved.
//

#ifndef AppnextNetworkDefs_h
#define AppnextNetworkDefs_h

typedef NS_ENUM(NSUInteger, StatusCodeType)
{
    statusCodeTypeNone = 0,
    statusCodeContinue = 100,
    statusCodeSwitchingProtocols = 101,
    statusCodeCheckpoint = 103,
    statusCodeTypeOK = 200,
    statusCodeCreated = 201,
    statusCodeAccepted = 202,
    statusCodeNonAuthoritativeInformation = 203,
    statusCodeNoContent = 204,
    statusCodeResetContent = 205,
    statusCodePartialContent = 206,
    statusCodeMultipleChoices = 300,
    statusCodeMovedPermanently = 301,
    statusCodeMovedTemporatyToNewURL = 302,
    statusCodeMovedToNewURL = 303,
    statusCodeTypeNotModified = 304,
    statusCodeTemporaryRedirect = 307,
    statusCodeResumeIncomplete = 308,
    statusCodeBadRequest = 400,
    statusCodeUnauthorized = 401,
    statusCodePaymentRequired = 402,
    statusCodeForbidden = 403,
    statusCodeNotFound = 404,
    statusCodeMethodNotAllowed = 405,
    statusCodeNotAcceptable = 406,
    statusCodeProxyAuthenticationRequired = 407,
    statusCodeRequestTimeout = 408,
    statusCodeConflict = 409,
    statusCodeGone = 410,
    statusCodeLengthRequired = 411,
    statusCodePreconditionFailed = 412,
    statusCodeRequestEntityTooLarge = 413,
    statusCodeRequestUriTooLong = 414,
    statusCodeUnsupportedMediaType = 415,
    statusCodeRequestedRangeNotSatisfiable = 416,
    statusCodeExpectationFailed = 417,
    statusCodeInternalServerError = 500,
    statusCodeNotImplemented = 501,
    statusCodeBadGateway = 502,
    statusCodeServiceUnavailable = 503,
    statusCodeGatewayTimeout = 504,
    statusCodeHTTPVersionNotSupported = 505,
    statusCodeNetworkAuthenticationRequired = 511,
};

typedef enum HTTPMethodType
{
    HTTPMethodTypeGet,
    HTTPMethodTypePost,
    HTTPMethodTypePut,
    HTTPMethodTypeDelete
} HTTPMethodType;

typedef void (^success)(id data, StatusCodeType statusCode, NSDictionary *moreData);
typedef void (^failure)(NSString *errorMessage, StatusCodeType statusCode, NSDictionary *moreData);

typedef BOOL (^networkRequest)(NSString *urlExtension, success completionBlock, failure failedBlock);

#endif /* AppnextNetworkDefs_h */

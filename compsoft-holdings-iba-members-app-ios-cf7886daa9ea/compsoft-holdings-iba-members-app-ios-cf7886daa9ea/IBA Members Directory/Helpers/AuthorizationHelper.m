//
//  AuthorizationHelper.m
//  PIXWUP
//
//  Created by Louisa Mousley on 06/01/2015.
//  Copyright (c) 2015 Compsoft. All rights reserved.
//

#import "AuthorizationHelper.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation AuthorizationHelper


+ (NSData *)hmacForKey:(NSString *)key andData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
}






@end

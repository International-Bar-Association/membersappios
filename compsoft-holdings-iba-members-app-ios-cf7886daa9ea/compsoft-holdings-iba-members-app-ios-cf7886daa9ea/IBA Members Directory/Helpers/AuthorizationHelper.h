//
//  AuthorizationHelper.h
//  PIXWUP
//
//  Created by Louisa Mousley on 06/01/2015.
//  Copyright (c) 2015 Compsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorizationHelper : NSObject


+ (NSData *)hmacForKey:(NSString *)key andData:(NSString *)data;

@end

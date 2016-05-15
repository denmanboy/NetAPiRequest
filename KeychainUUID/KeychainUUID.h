//
//  KeychainUUID.h
//  TestUUIDKeychain
//
//  Created by denman on 15/3/20.
//  Copyright (c) 2015年 yxld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainUUID : NSObject {
    
}

+ (NSString *)KeychainIdentifier;
+ (NSString*)value;
+ (void)Reset;

@end
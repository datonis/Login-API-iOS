//
//  T9Login.h
//  LoginAPITester
//
//  Created by Jeremy White on 5/10/13.
//  Copyright (c) 2013 Ten 90 Group. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface T9Login : NSObject

@property (nonatomic, readonly) NSString *appUUID;
@property (nonatomic) NSString *deviceUUID;

+ (T9Login *)sharedLogin;

- (void) startWithAppUUID:(NSString *)appUUID;

@end

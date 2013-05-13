//
//  T9Login.m
//  LoginAPITester
//
//  Created by Jeremy White on 5/10/13.
//  Copyright (c) 2013 Ten 90 Group. All rights reserved.
//

#import "T9Login.h"
#import "T9LoginViewController.h"

@implementation T9Login

+ (T9Login *)sharedLogin
{
    static T9Login *sharedLogin;
    
    @synchronized(self)
    {
        if (!sharedLogin)
            sharedLogin = [[T9Login alloc] init];
        
        return sharedLogin;
    }
}

- (id) init
{
    self = [super init];
    
    if (self)
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _deviceUUID = [defaults objectForKey:@"deviceUUID"];
    }
    
    return self;
}

- (void) startWithAppUUID:(NSString *)appUUID
{
    _appUUID = appUUID;
    
    UIWindow *mainWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:0];
    T9LoginViewController *login = [[T9LoginViewController alloc] init];
    [mainWindow.rootViewController presentViewController:login animated:YES completion:nil];
}

- (void) setDeviceUUID:(NSString *)deviceUUID
{
    if (_deviceUUID != deviceUUID && ![_deviceUUID isEqualToString:deviceUUID])
    {
        _deviceUUID = nil;
        _deviceUUID = deviceUUID;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:_deviceUUID forKey:@"deviceUUID"];
    }
}

@end

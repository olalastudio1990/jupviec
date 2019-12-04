//
//  User.m
//  JupViec
//
//  Created by Khanhlt on 11/28/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "User.h"

@implementation User

-(id)initUserWithInfoData:(NSDictionary *)infoDict
{
    self = [super init];
    if (self && infoDict != nil)
    {
        _userIDStr = [infoDict objectForKey:@"id"];
        _userPhoneNum = [infoDict objectForKey:@"phone"];
        _userRoleStr = [infoDict objectForKey:@"role"];
        if ([infoDict objectForKey:@"username"]) {
            _userNameStr = [[infoDict objectForKey:@"username"]stringValue];
        }
        _dictUserInfo = [infoDict objectForKey:@"general_information"];
        if ([infoDict objectForKey:@"status"]) {
            _userStatus = [[infoDict objectForKey:@"status"]integerValue];
        }
        if ([infoDict objectForKey:@"level"]) {
            _userLevel = [[infoDict objectForKey:@"level"]integerValue];
        }
    }
    
    return self;
}

@end

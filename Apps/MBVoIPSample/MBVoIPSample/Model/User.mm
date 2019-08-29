//
//  User.m
//  VOIP
//
//  Created by qinyihui on 2019/8/24.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "User.h"

@implementation User
+ (instancetype)shareUser{
    static User *user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        user = [User new];
    });
    return user;
}
@end

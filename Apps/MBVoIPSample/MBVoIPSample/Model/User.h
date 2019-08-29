//
//  User.h
//  VOIP
//
//  Created by qinyihui on 2019/8/24.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface User : NSObject
@property(nonatomic,strong)NSString *userName;
@property(nonatomic,strong)NSString *phone;
@property(nonatomic,strong)NSString *userIDCard;

+ (instancetype)shareUser;
@end

NS_ASSUME_NONNULL_END

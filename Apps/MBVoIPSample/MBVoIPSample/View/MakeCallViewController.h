//
//  MakeCallViewController.h
//  VOIP
//
//  Created by qinyihui on 2019/8/20.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    VOIPMakeCallViewStatusWaiting,
    VOIPMakeCallViewStatusQueue,
    VOIPMakeCallViewStatusSuccess,
    VOIPMakeCallViewStatusFailure,
} VOIPMakeCallViewStatus;

@interface MakeCallViewController : UIViewController
@property(nonatomic,assign)VOIPMakeCallViewStatus currentStatus;

@end

NS_ASSUME_NONNULL_END

//
//  MakCallQueueView.h
//  VOIP
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MakeCallQueueView : UIView
- (void)hideView;
- (void)showView;

- (void)setPosition:(NSInteger)position;
@end

NS_ASSUME_NONNULL_END

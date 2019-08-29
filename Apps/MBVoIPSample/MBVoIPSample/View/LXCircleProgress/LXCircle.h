//
//  LXCircle.h
//  LXBezierPath
//
//  Created by zhongzhi on 2017/7/21.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXCircle : UIView
-(instancetype)initWithFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth;

- (void)startAnimation;
- (void)stopAnimation;
- (void)setPosition:(NSInteger)position;
@end

//
//  MakeCallWaitingView.m
//  VOIP
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "MakeCallWaitingView.h"
#import "LXCircleProgress/LXCircle.h"

@interface MakeCallWaitingView(){
    LXCircle *_circleView;
}
@end

@implementation MakeCallWaitingView

- (id)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView{
    UILabel *labelTop = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 90, self.frame.size.width, 40)];
    labelTop.text = @"等待接听中";
    labelTop.textColor = [UIColor blackColor];
    labelTop.font = [UIFont boldSystemFontOfSize:22];
    labelTop.textAlignment = NSTextAlignmentCenter;
    
    
    UILabel *labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 40, self.frame.size.width, 40)];
    labelBottom.text = @"客服马上为您服务";
    labelTop.textColor = [UIColor blackColor];
    labelTop.font = [UIFont systemFontOfSize:20];
    labelBottom.textAlignment = NSTextAlignmentCenter;
    
    [self addSubview:labelTop];
    [self addSubview:labelBottom];
    
    _circleView = [[LXCircle alloc] initWithFrame:CGRectMake((VOIP_SCREEN_WIDTH - 100)/2.f, self.frame.size.height - 100 - 90, 100, 100) lineWidth:10];
    [self addSubview:_circleView];
}

- (void)hideView{
    [_circleView stopAnimation];
}

- (void)showView{
    [_circleView startAnimation];    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

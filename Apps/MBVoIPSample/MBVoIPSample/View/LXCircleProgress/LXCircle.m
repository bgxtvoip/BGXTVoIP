//
//  LXCircle.m
//  LXBezierPath
//
//  Created by zhongzhi on 2017/7/21.
//  Copyright © 2017年 漫漫. All rights reserved.
//

#import "LXCircle.h"
#import "UIColor+Expanded.h"
#define LBColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
@interface LXCircle()

@property(nonatomic,strong)UILabel *label;
@property(nonatomic,assign)CGFloat lineWidth;

@property(nonatomic,strong)CAShapeLayer *foreLayer;//蒙版layer
@property(nonatomic,strong)CALayer *circleLayer;
@end
@implementation LXCircle
-(instancetype)initWithFrame:(CGRect)frame lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _lineWidth = lineWidth;
    
        [self seup:frame];
    }
    return self;
}
-(void)seup:(CGRect) rect{
    
    self.circleLayer = [CALayer layer];
    self.circleLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.width);
    self.circleLayer.backgroundColor = [UIColor hexStringToColor:@"#f37272"].CGColor;
    [self.layer addSublayer:self.circleLayer];
    
    //创建圆环
    CGPoint center =  CGPointMake((rect.size.width )/2, (rect.size.width)/2);
    
    UIBezierPath *bezierPath =[UIBezierPath bezierPathWithArcCenter:center radius:(rect.size.width- _lineWidth)/2 startAngle:-0.5 *M_PI endAngle:1.5 *M_PI clockwise:YES];
    //圆环遮罩
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.lineWidth = _lineWidth;
    shapeLayer.strokeStart = 0;
    shapeLayer.strokeEnd = 1;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineDashPhase = 0.8;
    shapeLayer.path = bezierPath.CGPath;
    [self.circleLayer setMask:shapeLayer];
    
    NSMutableArray *colors = [NSMutableArray arrayWithObjects:(id)[UIColor hexStringToColor:@"#f37272"].CGColor,(id)[UIColor hexStringToColor:@"#ffffff" andAlpha:0.5].CGColor, nil];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.shadowPath = bezierPath.CGPath;
    gradientLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height/2.f);
    gradientLayer.startPoint = CGPointMake(1, 0);
    gradientLayer.endPoint = CGPointMake(0, 0);
    [gradientLayer setColors:[NSArray arrayWithArray:colors]];
    
    NSMutableArray *colors1 = [NSMutableArray arrayWithObjects:(id)[UIColor hexStringToColor:@"#ffffff" andAlpha:0.5].CGColor,(id)[[UIColor whiteColor] CGColor], nil];
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.shadowPath = bezierPath.CGPath;
    gradientLayer1.frame = CGRectMake(0, rect.size.height/2.f, rect.size.width, rect.size.height/2.f);
    gradientLayer1.startPoint = CGPointMake(0, 1);
    gradientLayer1.endPoint = CGPointMake(1, 1);
    [gradientLayer1 setColors:[NSArray arrayWithArray:colors1]];
    [self.circleLayer addSublayer:gradientLayer]; //设置颜色渐变
    [self.circleLayer addSublayer:gradientLayer1];
    
    self.label =[[UILabel alloc]initWithFrame:self.bounds];
    self.label.text  = @"";
    [self addSubview:self.label];
    
    self.label.font =[UIFont boldSystemFontOfSize:60];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor =[UIColor blueColor];
}

- (void)startAnimation {
    //动画
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = [NSNumber numberWithFloat:0];
    rotationAnimation.toValue = [NSNumber numberWithFloat:2.0*M_PI];
    rotationAnimation.repeatCount = MAXFLOAT;
    rotationAnimation.duration = 1;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [self.circleLayer addAnimation:rotationAnimation forKey:@"rotationAnnimation"];
}

- (void)stopAnimation{    
    [self.circleLayer removeAnimationForKey:@"rotationAnnimation"];
}

- (void)setPosition:(NSInteger)position{
    self.label.text = [NSString stringWithFormat:@"%ld",position];
}

- (void)dealloc{
    [self stopAnimation];
}

@end

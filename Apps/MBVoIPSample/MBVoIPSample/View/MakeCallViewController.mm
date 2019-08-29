//
//  MakeCallViewController.m
//  VOIP
//
//  Created by qinyihui on 2019/8/19.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "MakeCallViewController.h"
#import "MakeCallWaitingView.h"
#import "MakeCallQueueView.h"
#import "UIColor+Expanded.h"
#import "VoipManager.h"
#import "MBVoIPManager.h"
#import "AppDelegate.h"
#import "AppDelegate+MBVoIP.h"
#import "User.h"

@interface MakeCallViewController ()
@property(nonatomic,strong) UIView *topView;

@property(nonatomic,strong) MakeCallWaitingView *waitingView;
@property(nonatomic,strong) MakeCallQueueView *queueView;
@property(nonatomic,strong) UIButton *cancelButton;
@end

@implementation MakeCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createView];
    [self showWaitingView];    
    
    [[VoipManager shareManager] getTempUser:^(BOOL result) {
        if (result) {
            [[VoipManager shareManager] makeVideoCall:^(BOOL callSuccess) {
                if (callSuccess) {
                    [[VoipManager shareManager] getQueuePosition:^(BOOL success) {
                        self.currentStatus = VOIPMakeCallViewStatusQueue;
                        if (success) {
                            
                            [self setVoIPConfig];
                            if ([VoipManager shareManager].queuePosition<1) {
                                [[MBVoIPManager sharedInstance] makeVideoCall:[NSString stringWithFormat:@"%ld",(long)[VoipManager shareManager].roomId]];
                            }else{
                                [self showQueueView];
                                [self.queueView setPosition:[VoipManager shareManager].queuePosition];
                            }
                        }else{
                            [self quiteQueue];
                        }
                    }];
                }else{
                    [self quiteQueue];
                }
            }];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(180 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                //3分钟后
                if (self.currentStatus == VOIPMakeCallViewStatusWaiting) {
                    [self hideWaitingView];
                    [self showQueueView];
                }
            });
        }else{
            NSLog(@"getTempUser fail");
            [self stopWaiting];
        }
    }];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];    
}

#pragma mark - event
- (void)cancelDidClick{
    if (self.currentStatus == VOIPMakeCallViewStatusWaiting) {
        [self stopWaiting];
    }else if (self.currentStatus == VOIPMakeCallViewStatusQueue){
        [self quiteQueue];
    }
}

- (void)stopWaiting{
    self.currentStatus = VOIPMakeCallViewStatusFailure;
    [[VoipManager shareManager] releaseTempUser:^(BOOL reuslt) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)quiteQueue{
    self.currentStatus = VOIPMakeCallViewStatusFailure;
    
    [[MBVoIPManager sharedInstance] dropCalls];
    [[VoipManager shareManager] releaseTempUser:^(BOOL result) {
        
    }];
    
    [[VoipManager shareManager] cancelVideoCall:^(BOOL result) {
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
            return ;
        }
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)setVoIPConfig{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.voipConfiguration setValue:[VoipManager shareManager].userName forKey:kMBVoIPConfigurationUsernameKey];
    [appDelegate.voipConfiguration setValue:[VoipManager shareManager].userPwd forKey:kMBVoIPConfigurationPasswordKey];
    [appDelegate.voipConfiguration setValue:[VoipManager shareManager].userPwd forKey:kMBVoIPConfigurationDisplayNameKey];
    
    [[MBVoIPManager sharedInstance] commitConfiguration:appDelegate.voipConfiguration];
}

#pragma mark - View
- (void)createView{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"温馨提示：\n为避免声音嘈杂，保证通话质量，发起视频前建议佩戴耳机，然后按照客服指引进行操作"];
    [text addAttribute:NSFontAttributeName
                 value:[UIFont boldSystemFontOfSize:24.0] range:NSMakeRange(0, 4)];
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, 4)];
    
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(5, 21)];
    
    [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(26, 6)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(40.f, VOIP_SCREEN_HEIGHT / 2.f, VOIP_SCREEN_WIDTH - 80 , 200.f)];
    label.text = @"温馨提示";
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.attributedText = text;
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(10, VOIP_SCREEN_HEIGHT - 100, VOIP_SCREEN_WIDTH - 20, 60);
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelButton.backgroundColor = [UIColor hexStringToColor:@"#d0d0d0"];
    self.cancelButton.layer.cornerRadius = 4.f;
    self.cancelButton.layer.shadowColor = [UIColor hexStringToColor:@"#e0e0e0" andAlpha:0.5].CGColor;
    self.cancelButton.layer.shadowOffset = CGSizeMake(0, 1);
    self.cancelButton.layer.shadowRadius = 4;
    [self.cancelButton addTarget:self action:@selector(cancelDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.cancelButton];
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VOIP_SCREEN_WIDTH, VOIP_SCREEN_HEIGHT/2.f)];
    [self.view addSubview:self.topView];
}

- (void)showWaitingView{
    if (!self.waitingView) {
        self.waitingView = [[MakeCallWaitingView alloc] initWithFrame:_topView.frame];
    }
    [self.topView addSubview:self.waitingView];
    [self.waitingView showView];
    self.currentStatus = VOIPMakeCallViewStatusWaiting;
}

- (void)hideWaitingView{
    [self.waitingView hideView];
    [self.waitingView removeFromSuperview];
}

- (void)showQueueView{
    if (!self.queueView) {
        self.queueView = [[MakeCallQueueView alloc] initWithFrame:_topView.frame];
    }
    [self.topView addSubview:self.queueView];
    [self.queueView showView];
    self.currentStatus = VOIPMakeCallViewStatusQueue;
}

- (void)hideQueueView{
    [self.queueView removeFromSuperview];
}
@end

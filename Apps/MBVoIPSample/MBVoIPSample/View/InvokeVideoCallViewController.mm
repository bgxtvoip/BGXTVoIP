//
//  InvokeVideoCallViewController.m
//  VOIP
//
//  Created by qinyihui on 2019/8/24.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "InvokeVideoCallViewController.h"
#import "User.h"
#import "MakeCallViewController.h"
#import "VoipManager.h"

@interface InvokeVideoCallViewController ()
@property (weak, nonatomic) IBOutlet UITextView *titleTextView;

@property (weak, nonatomic) IBOutlet UIButton *invokeVideoButton;
@end

@implementation InvokeVideoCallViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleTextView.text = [NSString stringWithFormat:@"%@ 女士，您好！\n欢迎选择捷信分期！\n\n点击\"发起视频\"将开始贷款申请，您同意捷信录制、保存并使用视频办单全程的音视频资料及您的个人信息，且通话内容均为您的真实意思表示。\n\n通话前请您准备好身份证及常用银行卡。",[User shareUser].userName];
    self.invokeVideoButton.backgroundColor = BUTTON_RED_COLOR;
    
    self.invokeVideoButton.tintColor = [UIColor whiteColor];
    self.invokeVideoButton.layer.cornerRadius = 5;
    self.invokeVideoButton.layer.shadowOffset =  CGSizeMake(0, 0);
    self.invokeVideoButton.layer.shadowOpacity = 0.8;
    self.invokeVideoButton.layer.shadowColor =  [UIColor blackColor].CGColor;
}

- (IBAction)invokeVideo:(id)sender {        
    MakeCallViewController *vc = [MakeCallViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end

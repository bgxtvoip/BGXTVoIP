//
//  InputViewController.m
//  VOIP
//
//  Created by qinyihui on 2019/8/23.
//  Copyright © 2019年 qinyihui. All rights reserved.
//

#import "InputViewController.h"
#import "User.h"
#import "InvokeVideoCallViewController.h"

@interface InputViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIDCardTextField;

@property (weak, nonatomic) IBOutlet UIButton *reviewButton;

@end

@implementation InputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setButtonUI];
}


- (void)setButtonUI{
    self.reviewButton.backgroundColor = BUTTON_RED_COLOR;
    self.reviewButton.tintColor = [UIColor whiteColor];
    
    self.reviewButton.layer.cornerRadius = 10.f;
    self.reviewButton.layer.shadowOffset = CGSizeMake(0, 4);
    self.reviewButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.reviewButton.layer.shadowOpacity = 0.8;
}

- (IBAction)reviewThroughVideo:(id)sender {
    User *user = [User shareUser];
    user.userName = self.userNameTextField.text;
    user.phone = self.phoneTextField.text;
    user.userIDCard = self.userIDCardTextField.text;
    
    InvokeVideoCallViewController *vc = [[InvokeVideoCallViewController alloc] initWithNibName:@"InvokeVideoCallViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}
@end

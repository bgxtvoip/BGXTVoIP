//
//  ContractViewController.m
//  MBVoIPSample
//
//  Created by qinyihui on 2019/8/29.
//

#import "ContractViewController.h"

@interface ContractViewController ()
@property (weak, nonatomic) IBOutlet UIButton *preButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ContractViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setDefaultButtonUI];
}


#pragma mark -
- (void)setDefaultButtonUI{
    self.preButton.backgroundColor = BUTTON_GRAY_COLOR;
    self.nextButton.backgroundColor = BUTTON_GRAY_COLOR;
    self.agreeButton.backgroundColor = BUTTON_GRAY_COLOR;
    self.cancelButton.backgroundColor = BUTTON_GRAY_COLOR;
}

- (void)setButtonShadow:(UIButton *)button{
    button.layer.shadowColor = BUTTON_GRAY_SHADOW_COLOR;
    button.layer.shadowOffset = CGSizeMake(0, 1);
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

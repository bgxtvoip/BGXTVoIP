//
//  ViewController.m
//  MBVoIPSample
//
//  Created by qinyihui on 2019/8/28.
//

#import "ViewController.h"
#import "VoipManager.h"
#import "MakeCallViewController.h"
#import "InputViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)showInputView{
    InputViewController *vc = [InputViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

//- (void)showMakeCallView{
//    MakeCallViewController *vc = [MakeCallViewController new];
//    [self addChildViewController:vc];
//    [vc didMoveToParentViewController:self];
//    [vc.view setFrame:self.view.bounds];
//    [self.view addSubview:vc.view];
//}

- (IBAction)start:(id)sender {
    [self showInputView];
}
@end

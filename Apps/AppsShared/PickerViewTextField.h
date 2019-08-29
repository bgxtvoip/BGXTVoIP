#import <UIKit/UIKit.h>

@interface PickerViewTextField : UITextField <UIKeyInput, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, atomic) UIView *inputView;
@property (assign, nonatomic) IBOutlet id<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate> delegate;

@end

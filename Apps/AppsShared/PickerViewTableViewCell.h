#import <UIKit/UIKit.h>

@interface PickerViewTableViewCell : UITableViewCell <UIKeyInput, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) UIView *inputView;
@property (assign, nonatomic) IBOutlet id<UIPickerViewDelegate, UIPickerViewDataSource> delegate;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *contentLabel;

@end

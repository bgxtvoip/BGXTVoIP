#import "PickerViewTableViewCell.h"

@implementation PickerViewTableViewCell

#pragma mark - property

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected) {
        if (selected) {
            if ([self isFirstResponder] == NO) {
                [self becomeFirstResponder];
            }
        }
    }
    else {
        if ([self isFirstResponder] == YES) {
            [self resignFirstResponder];
        }
    }
    
    return;
}

- (UIPickerView *)pickerView
{
    if (_pickerView == nil) {
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
        pickerView.showsSelectionIndicator = YES;
        pickerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        pickerView.dataSource = self;
        pickerView.delegate = self;
        self.pickerView = pickerView;
    }
    return _pickerView;
}

- (UIView *)inputView
{
    if (_inputView == nil) {
        self.inputView = self.pickerView;
    }
    
    return _inputView;
}

#pragma mark - UIResponder

- (BOOL)becomeFirstResponder
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedDeviceOrientation:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self.inputView setNeedsLayout];
    
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    
    return [super resignFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - UIKeyInput

- (BOOL)hasText
{
    return YES;
}

- (void)insertText:(NSString *)text
{
    return;
}

- (void)deleteBackward
{
    return;
}

#pragma mark - Notification

- (void)changedDeviceOrientation:(NSNotification *)notification
{
    [self.inputView setNeedsLayout];
    
    return;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSInteger result = 0;
    if ([[self.delegate class] conformsToProtocol:@protocol(UIPickerViewDataSource)]) {
        if ([self.delegate respondsToSelector:@selector(numberOfComponentsInPickerView:)]) {
            result = [self.delegate numberOfComponentsInPickerView:pickerView];
        }
    }
    
    return result;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger result = 0;
    if ([[self.delegate class] conformsToProtocol:@protocol(UIPickerViewDataSource)]) {
        if ([self.delegate respondsToSelector:@selector(pickerView:numberOfRowsInComponent:)]) {
            result = [self.delegate pickerView:pickerView numberOfRowsInComponent:component];
        }
    }
    
    return result;
}

#pragma mark - UIPickerViewDelegate

//- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
//{
//    return 0;
//}

//- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
//{
//    return 0;
//}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *result = 0;
    if ([[self.delegate class] conformsToProtocol:@protocol(UIPickerViewDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(pickerView:titleForRow:forComponent:)]) {
            result = [self.delegate pickerView:pickerView titleForRow:row forComponent:component];
        }
    }
    
    return result;
}

//- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    NSAttributedString *result = 0;
//    if ([[self.delegate class] conformsToProtocol:@protocol(UIPickerViewDelegate)]) {
//        if ([self.delegate respondsToSelector:@selector(pickerView:attributedTitleForRow:forComponent:)]) {
//            result = [self.delegate pickerView:pickerView attributedTitleForRow:row forComponent:component];
//        }
//    }
//    
//    return result;
//}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//    UIView *result = 0;
//    if ([[self.delegate class] conformsToProtocol:@protocol(UIPickerViewDelegate)]) {
//        if ([self.delegate respondsToSelector:@selector(pickerView:viewForRow:forComponent:reusingView:)]) {
//            result = [self.delegate pickerView:pickerView viewForRow:row forComponent:component reusingView:view];
//        }
//    }
//    
//    return result;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([[self.delegate class] conformsToProtocol:@protocol(UIPickerViewDelegate)]) {
        if ([self.delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
            [self.delegate pickerView:pickerView didSelectRow:row inComponent:component];
        }
    }
    
    return;
}

@end

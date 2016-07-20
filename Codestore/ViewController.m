//
//  ViewController.m
//  Codestore
//
//  Created by Mikko Harju on 20/07/16.
//  Copyright © 2016 Mikko Harju. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *codeInputField;
@property (weak, nonatomic) IBOutlet UILabel *resultCodeField;

@property (strong, nonatomic) NSArray *numbers;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.resultCodeField.text = @"";
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"codes" ofType:@"txt"];
    if (filePath) {
        NSString *text = [NSString stringWithContentsOfFile:filePath];
        self.numbers = [text componentsSeparatedByString:@"\n"];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeactivate:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) didDeactivate:(NSNotification*)notification
{
    self.codeInputField.text = @"";
}

- (void) didBecomeActive:(NSNotification*)notification
{
    self.codeInputField.text = @"";
    self.resultCodeField.text = @"";
    [self.codeInputField becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.codeInputField becomeFirstResponder];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = @"";
    self.resultCodeField.text = @"";
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(newString.length == 3) {
        textField.text = newString;
        [textField resignFirstResponder];
    }
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    NSInteger current = [textField.text integerValue];
    if(current > 0 && current < self.numbers.count) {
        self.resultCodeField.textColor = [UIColor colorWithRed:0xfd/255.0 green:0xae/255.0 blue:0x70/255.0 alpha:1.0];
        self.resultCodeField.text = self.numbers[current-1];
    } else {
        self.resultCodeField.textColor = [UIColor colorWithRed:0xec/255.0 green:0xc7/255.0 blue:0xc0/255.0 alpha:1.0];
        self.resultCodeField.text = @"NO";
    }
}

@end

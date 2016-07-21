//
//  ViewController.m
//  Codestore
//
//  Created by Mikko Harju on 20/07/16.
//  Copyright © 2016 Mikko Harju. All rights reserved.
//

#import "ViewController.h"

@import LocalAuthentication;

NSString* kLastAuthentication = @"LastSuccessfulAuthentication";
const NSTimeInterval kAuthenticationDelay = 15;

@interface ViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *codeInputField;
@property (weak, nonatomic) IBOutlet UILabel *resultCodeField;
@property (assign) BOOL isAuthenticating;

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
    
    [self authenticateIfNeeded];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willDeactivate:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void) willDeactivate:(NSNotification*)notification
{
    self.codeInputField.text = @"";
    
    // XXX Does not clear out the actual password or anything so the user can check it in case it was
    // forgotten. Is this a good idea or not?
}

- (void) didBecomeActive:(NSNotification*)notification
{
    self.codeInputField.text = @"";
    self.resultCodeField.text = @"";
    
    [self authenticateIfNeeded];
}

- (void)authenticateIfNeeded
{
    if(!self.isAuthenticating && [self canEvaluatePolicy]) {
        NSDate* date = [[[NSUserDefaults standardUserDefaults] objectForKey:kLastAuthentication] dateByAddingTimeInterval:kAuthenticationDelay];
        NSDate* now = [NSDate date];
        if([date earlierDate:now] == date) {
            [self evaluatePolicy];
        } else {
            [self.codeInputField becomeFirstResponder];
        }
    }
}

- (BOOL)canEvaluatePolicy
{
    LAContext *context = [[LAContext alloc] init];
    return [context canEvaluatePolicy: LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil];
}

- (void)evaluatePolicy {
    NSLog(@"Is authenticating now");
    self.isAuthenticating = YES;

    LAContext *context = [[LAContext alloc] init];

    // Show the authentication UI with our reason string.
    [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
            localizedReason:@"SORMENJÄLKI SIIHEN KU OLIS JO"
                      reply:^(BOOL success, NSError *authenticationError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                self.codeInputField.enabled = YES;
                [self.codeInputField becomeFirstResponder];

                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastAuthentication];
            }
            else {
                self.codeInputField.enabled = NO;
                self.resultCodeField.text = @"NO";
            }

            self.isAuthenticating = NO;
            NSLog(@"Authentication completed.");
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated
{
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

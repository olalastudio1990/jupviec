//
//  LoginWithPasswordViewController.m
//  JupViec
//
//  Created by KienVu on 11/29/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "LoginWithPasswordViewController.h"
#import "APIRequest.h"
#import "SignInViewController.h"
#import "AccountInfoViewController.h"
#import "HomeViewController.h"
#import "LoadingViewController.h"

#import "JButton.h"
#import "JTextField.h"

@interface LoginWithPasswordViewController ()
{
    NSInteger keyboardheight;
}

@end

@implementation LoginWithPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.view.layer.masksToBounds = YES;
    
    [_txtInputUserPhone setDelegate:self];
    [_txtInputUserPass setDelegate:self];
    
    [_btForgotPassword setTitleColor:UIColorFromRGB(0x5C5C5C) forState:UIControlStateNormal];
    [_btRegisterNow setTitleColor:UIColorFromRGB(0x5C5C5C) forState:UIControlStateNormal];
    
    [_txtInputUserPhone setFont:[UIFont fontWithName:@"Roboto-Bold" size:14]];
    [_txtInputUserPass setFont:[UIFont fontWithName:@"Roboto-Bold" size:14]];
    
    NSAttributedString *phoneAttribute = [[NSAttributedString alloc] initWithString:_txtInputUserPhone.placeholder
                                                                         attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x5C5C5C), NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:14]}];
    [_txtInputUserPhone setAttributedPlaceholder:phoneAttribute];
    
    NSAttributedString *passAttribute = [[NSAttributedString alloc] initWithString:_txtInputUserPass.placeholder
                                                                         attributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x5C5C5C), NSFontAttributeName: [UIFont fontWithName:@"Roboto-Regular" size:14]}];
    [_txtInputUserPass setAttributedPlaceholder:passAttribute];
    
    [_txtInputUserPhone setTextColor:UIColorFromRGB(0x5C5C5C)];
    [_txtInputUserPass setTextColor:UIColorFromRGB(0x5C5C5C)];
    [_txtQuestion setTextColor:UIColorFromRGB(0x5C5C5C)];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont fontWithName:@"Comfortaa-Regular" size:20]}];
    
    keyboardheight = 0;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.tabBarController.tabBar setHidden:NO];
    [self.navigationController.navigationBar setHidden:YES];
    
    [self registerFromKeyboardNotification];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unregisterFromKeyboardNotification];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

-(NSString*)userToken
{
    return strToken;
}

-(NSString*)userPhoneNumber
{
    return strUserphone;
}

-(void)registerFromKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)unregisterFromKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardDidShow:(NSNotification*)notification
{
    NSDictionary *userinfo = [notification userInfo];
    NSValue *keyboardbeginrect = [userinfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue *keyboardendrect = [userinfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect beginrect = [keyboardbeginrect CGRectValue];
    CGRect endrect = [keyboardendrect CGRectValue];
    
    keyboardheight = beginrect.origin.y - endrect.origin.y;
    
    _bottomConstraint.constant += keyboardheight;
    
    [self.view layoutIfNeeded];
}

-(void)keyboardDidHide:(NSNotification*)notification
{
    NSDictionary *userinfo = [notification userInfo];
    NSValue *keyboardbeginrect = [userinfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue *keyboardendrect = [userinfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect beginrect = [keyboardbeginrect CGRectValue];
    CGRect endrect = [keyboardendrect CGRectValue];

    keyboardheight = endrect.origin.y - beginrect.origin.y;
    
    if ((_bottomConstraint.constant - keyboardheight) > 0) {
        _bottomConstraint.constant -= keyboardheight;
    }
    
    [self.view layoutIfNeeded];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma - UITextFielDelegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (void)showPopupNewUserPhone
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Popup" message:@"So dien thoai chua duoc dang ky" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* alertAct = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:alertAct];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)showPopupIncorrectUserPassword
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Popup" message:@"Mat khau chua chinh xac" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* alertAct = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:alertAct];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"idLoginToNewRegister"])
    {
        SignInViewController* signInVC = segue.destinationViewController;
        [signInVC setIntActionMode:intActionMode];
    }
    else if ([segue.identifier isEqualToString:@"idLoginToHomeView"])
    {
        HomeViewController* homeVC = segue.destinationViewController;
        homeVC.strPhoneNum = strUserphone;
        homeVC.strUserToken = strToken;
    }
}

#pragma - Actions
- (IBAction)didClickedFogetPassword:(id)sender
{
    NSLog(@"clicked forget password");
    
    [self.view endEditing:YES];
    intActionMode = MODE_FORGOT_PASSWORD;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"idLoginToNewRegister" sender:self];
    });
}

- (IBAction)didClickedRegisterNewAcc:(id)sender
{
    
    NSLog(@"create new account");
    
    intActionMode = MODE_REGISTER_NEW_ACC;
    [self.view endEditing:YES];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSegueWithIdentifier:@"idLoginToNewRegister" sender:self];
    });
}

- (IBAction)didClickedLogin:(id)sender
{
    [self.view endEditing:YES];
    
    if ([_txtInputUserPhone text] && [_txtInputUserPass text])
    {
        strUserPass = [_txtInputUserPass text];
        strUserphone = [_txtInputUserPhone text];
        
        LoadingViewController *loadingview = [self.storyboard instantiateViewControllerWithIdentifier:@"idloadingview"];
        [loadingview show:self];
        
        APIRequest *request = [[APIRequest alloc]init];
        [request requestAPILogin:strUserphone password:strUserPass completionHandler:^(NSString * _Nullable token, NSError * _Nonnull error) {
            [loadingview dismiss];
            if (error.code == RESPONSE_CODE_NORMARL)
            {
                self->strToken = token;
                [JUntil showPopup:self responsecode:RESPONSE_CODE_LOGIN_SUCCESS completionHandler:^(POPUP_ACTION action) {}];
            }
            else if (error.code == RESPONSE_CODE_INVALID_PASSWORD)
            {
                NSLog(@"invalid password");
                [JUntil showPopup:self responsecode:RESPONSE_CODE_INVALID_PASSWORD];
            }
            else if (error.code == RESPONSE_CODE_API_NOT_FOUND)
            {
                NSLog(@"phone number is not registed");
                [JUntil showPopup:self responsecode:RESPONSE_CODE_API_NOT_FOUND];
            }
            else if (error.code == RESPONSE_CODE_TIMEOUT)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_TIMEOUT];
            }
            else
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_OTHER];
            }
        }];
    }
}

-(void)confirmLoginSuccess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (UINavigationController *item in [self.tabBarController viewControllers])
        {
            UIViewController *vc = [[item viewControllers] objectAtIndex:0];
            if ([vc isKindOfClass:[HomeViewController class]])
            {
                [(HomeViewController*)vc logIn:[self userToken] phoneNumber:[self userPhoneNumber]];
                [self.tabBarController setSelectedViewController:item];
                
                NSLog(@"lofin success: go to home view");
                break;
            }
        }
    });
}

-(void)didCloseAlertPopupWithCode:(POPUP_ACTION)code
{
    if (code == ACTION_OK)
    {
        if ([self userToken]) {
            [self confirmLoginSuccess];
        }
    }
}
@end

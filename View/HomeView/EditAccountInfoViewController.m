//
//  EditAccountInfoViewController.m
//  JupViec
//
//  Created by Khanhlt on 12/16/19.
//  Copyright © 2019 Olala. All rights reserved.
//

#import "EditAccountInfoViewController.h"
#import "APIRequest.h"
#import "AccountInfoViewController.h"
#import "HomeViewController.h"
#import "LoadingViewController.h"

@interface EditAccountInfoViewController ()

@end

@implementation EditAccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_userNameTF setDelegate:self];
    _isChangeInfo = NO;
    _accountGeneralInfo = [[_user dictUserInfo] mutableCopy];
    
    [_userNameTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_emailTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_ageTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_addressTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_identifyCardTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [_sexTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [_userNameLbTitle setTextColor:[UIColor blackColor]];
    [_emailLbTitle setTextColor:[UIColor blackColor]];
    [_addressLbTitle setTextColor:[UIColor blackColor]];
    [_userNameTF setTextColor:[UIColor blackColor]];
    [_emailTF setTextColor:[UIColor blackColor]];
    [_addressTF setTextColor:[UIColor blackColor]];
    [_sexTitleLb setTextColor:[UIColor blackColor]];
    [_sexTF setTextColor:[UIColor blackColor]];
    
    self.view.layer.masksToBounds = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    _accountGeneralInfo = [NSMutableDictionary dictionaryWithDictionary:[_user dictUserInfo]];
    if (_accountGeneralInfo) {
        if ([[_accountGeneralInfo objectForKey:@"name"] isKindOfClass:[NSString class]]) {
            _userNameTF.text = [_accountGeneralInfo objectForKey:@"name"];
        }
        else{
            _userNameTF.text = @"";
        }
        if ([[_accountGeneralInfo objectForKey:@"email"] isKindOfClass:[NSString class]]) {
            _emailTF.text = [_accountGeneralInfo objectForKey:@"email"];
        }
        else{
            _emailTF.text = @"";
        }
        if ([[_accountGeneralInfo objectForKey:@"age"] isKindOfClass:[NSNumber class]]) {
            _ageTF.text = [[_accountGeneralInfo objectForKey:@"age"]stringValue];
        }
        else{
            _ageTF.text = @"";
        }
        if ([[_accountGeneralInfo objectForKey:@"address"] isKindOfClass:[NSString class]]) {
            _addressTF.text = [_accountGeneralInfo objectForKey:@"address"];
        }
        else{
            _addressTF.text = @"";
        }
        if ([[_accountGeneralInfo objectForKey:@"identity_card"] isKindOfClass:[NSNumber class]]) {
            _identifyCardTF.text = [[_accountGeneralInfo objectForKey:@"identity_card"]stringValue];
        }
        else{
            _identifyCardTF.text = @"";
        }
        
        if ([[_accountGeneralInfo objectForKey:@"sex"] isKindOfClass:[NSNumber class]]) {
            if ([[_accountGeneralInfo objectForKey:@"sex"] boolValue] == YES) {
                _sexTF.text = @"nam";
            }else
                _sexTF.text = @"nữ";
        }else{
            _sexTF.text = @"";
        }
    }
}

- (void)textFieldDidChange:(UITextField*)textField
{
    if (!_isChangeInfo) {
        _isChangeInfo = YES;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (IBAction)changeEdittedAccountInfo:(id)sender {
    
    if (_isChangeInfo && _user && [_user userToken])
    {
        [_accountGeneralInfo setObject:_userNameTF.text forKey:@"name"];
        [_accountGeneralInfo setObject:_emailTF.text forKey:@"email"];
        [_accountGeneralInfo setObject:[NSNumber numberWithInteger:[_ageTF.text integerValue]] forKey:@"age"];
        [_accountGeneralInfo setObject:_addressTF.text forKey:@"address"];
        [_accountGeneralInfo setObject:[NSNumber numberWithInteger:[_identifyCardTF.text integerValue]] forKey:@"identity_card"];
        if ([[_sexTF.text lowercaseString] isEqualToString:@"nam"]) {
            [_accountGeneralInfo setObject:[NSNumber numberWithBool:YES] forKey:@"sex"];
        }else
            [_accountGeneralInfo setObject:[NSNumber numberWithBool:NO] forKey:@"sex"];
        
        LoadingViewController *loadingview = [self.storyboard instantiateViewControllerWithIdentifier:@"idloadingview"];
        [loadingview show:self];
        
        APIRequest* api = [[APIRequest alloc]init];
        
        [api requestAPIUpdateAccountInfo:[_user userToken] accountInfo:_accountGeneralInfo completionHandler:^(User * _Nullable user, NSError * _Nonnull error)
        {
            [loadingview dismiss];
            if (error.code == 200)
            {
                [user setUserToken:[self.user userToken]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self didSuccessChangeAccountInfo:user];
                });
            }
            else if (error.code == RESPONSE_CODE_NODATA)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_NODATA];
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

- (void)didSuccessChangeAccountInfo:(User*)user
{
    NSArray* viewControllersArr = [self.navigationController viewControllers];
    
    for (UIViewController* vc in viewControllersArr) {
        if ([vc isKindOfClass:[AccountInfoViewController class]])
        {
            AccountInfoViewController* accountInfoVC = (AccountInfoViewController*)vc;
            accountInfoVC.user = user;
            [accountInfoVC updateContentView];
        }
        else if ([vc isKindOfClass:[HomeViewController class]])
        {
            HomeViewController* homeview = (HomeViewController*)vc;
            [homeview setUser:user];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}
@end

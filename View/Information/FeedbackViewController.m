//
//  FeedbackViewController.m
//  JupViec
//
//  Created by Khanhlt on 1/16/20.
//  Copyright © 2020 Olala. All rights reserved.
//

#import "FeedbackViewController.h"

@interface FeedbackViewController ()

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setTitle:@"Góp ý"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setHidden:NO];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_contentTextView endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didClickSendFeedbackButton:(id)sender {
    APIRequest* api = [[APIRequest alloc]init];
    if (_user && _contentTextView.text)
    {
        NSString* dateTimeStr = [JUntil stringFromDateAndTime:[NSDate date]];
        NSMutableDictionary* feedbackDict = [[NSMutableDictionary alloc]init];
        [feedbackDict setObject:_contentTextView.text forKey:@"content"];
        [feedbackDict setObject:_user.userPhoneNum forKey:@"phone"];
        [feedbackDict setObject:dateTimeStr forKey:@"created_at"];
        [api requestAPISendFeedbackForApp:feedbackDict withToken:[_user userToken] completionHandler:^(NSDictionary * _Nullable resultDict, NSError * _Nonnull error) {
            if (error.code != 200)
            {
                [JUntil showPopup:self responsecode:RESPONSE_CODE_OTHER];
            }
        }];
    }
}
@end
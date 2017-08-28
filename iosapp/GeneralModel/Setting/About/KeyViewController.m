//
//  KeyViewController.m
//  iosapp
//
//  Created by Barat Semet on 30/11/2016.
//  Copyright © 2016 oschina. All rights reserved.
//

#import "KeyViewController.h"
#import "Utils.h"

@interface KeyViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UITextField *txtInput;

@end

@implementation KeyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.title = @"幻觉";
	self.view.backgroundColor = [UIColor themeColor];
}


- (IBAction)btnClicked:(id)sender {
	[_txtInput resignFirstResponder];
	if ([_txtInput.text isEqualToString:App_Token_Key]) {
		NSString* token = [Utils getAppToken];
		_lblMessage.text = token;
		[[UIPasteboard generalPasteboard] setString: token];
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end

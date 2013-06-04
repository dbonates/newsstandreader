//
//  OptionsViewController.h
//  Teste
//
//  Created by Daniel Bonates on 5/4/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UISwitch *readyIssuesFilterSwitch;

// allViews
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *assinanteView;
@property (weak, nonatomic) IBOutlet UIView *restaurarComprasView;
@property (weak, nonatomic) IBOutlet UIView *escolherBk;
@property (weak, nonatomic) IBOutlet UIView *filtroView;
@property (weak, nonatomic) IBOutlet UIView *generalOptionsView;

@property (weak, nonatomic) IBOutlet UIView *loginFormView;
@property (weak, nonatomic) IBOutlet UIView *infoAssinanteView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;


@property (weak, nonatomic) IBOutlet UIButton *bkBtn3;
@property (weak, nonatomic) IBOutlet UIButton *bkBtn13;
@property (weak, nonatomic) IBOutlet UIButton *bkBtn7;
@property (weak, nonatomic) IBOutlet UIButton *bkBtn9;
@property (weak, nonatomic) IBOutlet UITextView *debugInfo;

- (IBAction)changeBk:(id)sender;
- (IBAction)restaurarCompras:(id)sender;

- (IBAction)getThere:(id)sender;
- (IBAction)clearToken:(id)sender;

- (void)tokenSaved:(NSNotification *)notification;
- (void)tokenExpiredProvidences:(NSNotification *)notification;

- (IBAction)filterReadyIssues:(id)sender;

- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;

- (NSString *)getValueForKeyFromJsonObject:(NSString *)key jsonObject:(id)jsonObject;

@end

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

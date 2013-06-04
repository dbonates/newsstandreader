//
//  OptionsViewController.m
//  Teste
//
//  Created by Daniel Bonates on 5/4/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "OptionsViewController.h"
#import "MBProgressHUD.h"
#import "InAppStore.h"
#import "UIViewController+MMDrawerController.h"
#import "CredentialStore.h"
#import "LoginViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>

@interface OptionsViewController ()
@property (nonatomic, strong) CredentialStore *credentialStore;
@property (nonatomic, strong) NSArray *allViews;


@end

@implementation OptionsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupAssinanteInfo];
    
    [self setupShadowsOnBkButtons];
    
    self.allViews = @[self.headerView,
                      self.assinanteView,
                      self.restaurarComprasView,
                      self.escolherBk,
                      self.filtroView,
                      self.generalOptionsView];
    
    [self layoutViews];

    self.scroller.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern14_lateral"]];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern14_lateral"]];
    self.readyIssuesFilterSwitch.onTintColor = [UIColor colorWithRed:0.670 green:0.431 blue:0.171 alpha:1.000];
    self.readyIssuesFilterSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"showOnlyReadyIssues"];
    // login stuff
    self.credentialStore = [[CredentialStore alloc] init];
    
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenExpiredProvidences:) name:@"token-expired" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenSaved:) name:@"token-changed" object:nil];

}

- (void)setupAssinanteInfo
{
    if ([self.credentialStore isLoggedIn]) {
        self.usernameLabel.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        self.loginFormView.hidden = YES;
        self.infoAssinanteView.hidden = NO;
        
        CGRect frame = CGRectMake(0, 0, 320, 77);
        self.assinanteView.frame = frame;
    }
    else
    {
        self.loginFormView.hidden = NO;
        self.infoAssinanteView.hidden = YES;
        CGRect frame = CGRectMake(0, 0, 320, 275);
        self.assinanteView.frame = frame;

    }
}

- (void)setupShadowsOnBkButtons
{
    // shadowzinha nos botoes de bk
    self.bkBtn3.layer.borderColor = [UIColor colorWithRed:0.906 green:0.917 blue:0.798 alpha:1.000].CGColor;
    self.bkBtn3.layer.borderWidth = 3.0f;
    self.bkBtn3.layer.cornerRadius = 10.0f;
    self.bkBtn3.layer.masksToBounds = NO;
    self.bkBtn3.layer.shadowOffset = CGSizeMake(3, 3);
    self.bkBtn3.layer.shadowRadius = 5;
    self.bkBtn3.layer.shadowOpacity = 0.5;
    
    self.bkBtn13.layer.borderColor = [UIColor colorWithRed:0.906 green:0.917 blue:0.798 alpha:1.000].CGColor;
    self.bkBtn13.layer.borderWidth = 3.0f;
    self.bkBtn13.layer.cornerRadius = 10.0f;
    self.bkBtn13.layer.masksToBounds = NO;
    self.bkBtn13.layer.shadowOffset = CGSizeMake(3, 3);
    self.bkBtn13.layer.shadowRadius = 5;
    self.bkBtn13.layer.shadowOpacity = 0.5;
    
    self.bkBtn7.layer.borderColor = [UIColor colorWithRed:0.906 green:0.917 blue:0.798 alpha:1.000].CGColor;
    self.bkBtn7.layer.borderWidth = 3.0f;
    self.bkBtn7.layer.cornerRadius = 10.0f;
    self.bkBtn7.layer.masksToBounds = NO;
    self.bkBtn7.layer.shadowOffset = CGSizeMake(3, 3);
    self.bkBtn7.layer.shadowRadius = 5;
    self.bkBtn7.layer.shadowOpacity = 0.5;
    
    self.bkBtn9.layer.borderColor = [UIColor colorWithRed:0.906 green:0.917 blue:0.798 alpha:1.000].CGColor;
    self.bkBtn9.layer.borderWidth = 3.0f;
    self.bkBtn9.layer.cornerRadius = 10.0f;
    self.bkBtn9.layer.masksToBounds = NO;
    self.bkBtn9.layer.shadowOffset = CGSizeMake(3, 3);
    self.bkBtn9.layer.shadowRadius = 5;
    self.bkBtn9.layer.shadowOpacity = 0.5;
}

- (void)layoutViews
{
    int total = self.allViews.count;
    CGRect frame;
    UIView *optionView;
    UIView *precedentView;
    
    for (int i=0; i<total; i++) {
        
        optionView = [self.allViews objectAtIndex:i];
        precedentView = i > 0 ? [self.allViews objectAtIndex:i-1] : nil;

        
        frame = i == 0 ?
        CGRectMake(0, 0, optionView.frame.size.width, optionView.frame.size.height) : 
        CGRectMake(0, precedentView.frame.origin.y + precedentView.frame.size.height, optionView.frame.size.width, optionView.frame.size.height);
        
        
        optionView.frame = frame;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    self.scroller.contentSize = CGSizeMake(320, 1024);
//    self.scroller.scrollEnabled = YES;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"token.save.error"] == YES) {
        self.debugInfo.text = [defaults valueForKey:@"token.save.error.message"];
    }
    else
    {
        self.debugInfo.text = [defaults valueForKey:@"token.string.saved"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeBk:(id)sender {
    
    int tagNumber = [sender tag];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"pattern%d", tagNumber] forKey:@"patternBk"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"panorama.backgroundChanged" object:self userInfo:userInfo];
}

- (IBAction)restaurarCompras:(id)sender {
    
    [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    MBProgressHUD *temp_hud = [MBProgressHUD showHUDAddedTo:self.mm_drawerController.centerViewController.view animated:YES];
    
    // Configure for text only and offset down
    temp_hud.mode = MBProgressHUDModeText;
    temp_hud.dimBackground = YES;
    temp_hud.labelText = NSLocalizedString(@"AGUARDANDO", nil);
    temp_hud.removeFromSuperViewOnHide = YES;
    [[InAppStore sharedInstance] restorePurchasesWithCompletionBlock:^(){
        temp_hud.labelText = NSLocalizedString(@"COMPRAS RESTAURADAS", nil);
        [temp_hud hide:YES afterDelay:1];
    } failureBlock:^(NSError*error){
        temp_hud.labelText = NSLocalizedString(@"FALHA AO RESTAURAR COMPRAS", nil);
        [temp_hud hide:YES afterDelay:1];
    }];
}



#pragma mark -
#pragma mark all login stuff

- (IBAction)getThere:(id)sender {
    if ([self.credentialStore isLoggedIn])
    {
        //NSLog(@"token a provar: %@", self.credentialStore.authToken);
        [SVProgressHUD show];
        
        
        [[AuthAPIClient sharedClient] getPath:@"/home/index"
                                   parameters:@{@"auth_toke": @"edae859ddd7e7de19e41c804290e44b97ac6b775"}
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          //                                          NSLog(@"passou com o token %@",self.credentialStore.authToken);
                                          
                                          //NSDictionary *jsonPeople = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
                                          //self.logText.text = [jsonPeople description];
                                          [SVProgressHUD dismiss];
                                      }
                                      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                          //                                          NSLog(@"erro, limpar token %@", self.credentialStore.authToken);
                                          //                                          NSLog(@"erro: %@", [self getValueForKeyFromJsonObject:@"error" jsonObject:operation.responseData]);
                                          
                                          if (operation.response.statusCode == 403 || operation.response.statusCode == 401) { // Forbidden, token expirou
                                              [self.credentialStore clearSavedCredentials];
                                              
                                              
                                          }
                                          // a api retorna um json com uma key "error"
                                          NSString *errorMsg = [self getValueForKeyFromJsonObject:@"error" jsonObject:operation.responseData];
                                          [SVProgressHUD showErrorWithStatus:errorMsg];
                                      }];
        
        
    }
    else
    {
        /*
        UIBarButtonItem *buttonItem = sender;
        UIView* btnView = [buttonItem valueForKey:@"view"];
        
        UIStoryboard *sb = self.parentViewController.storyboard;
        LoginViewController *loginWViewController = (LoginViewController *)[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        
        self.assinanteLoginPopover = [[FPPopoverController alloc] initWithViewController:loginWViewController];
        //                                           self.popover.border = NO;
        self.assinanteLoginPopover.contentSize = LOGIN_WINSIZE;
        [self.assinanteLoginPopover setArrowDirection:FPPopoverArrowDirectionUp];
        [self.assinanteLoginPopover presentPopoverFromView:btnView];
        */
    }
}



- (void)tokenSaved:(NSNotification *)notification
{
    [self.mm_drawerController closeDrawerAnimated:YES completion:^(BOOL finished) {

        [[InAppStore sharedInstance] fakeSubscriber];
    }];
    
    [self ativarAssinante];
}


- (void)ativarAssinante
{
    [self setupAssinanteInfo];
    [self layoutViews];
}

- (void)tokenExpiredProvidences:(NSNotification *)notification
{
    //[self.logText setText:@"aguardando login"];
}

- (IBAction)filterReadyIssues:(id)sender {
    //@"panorama.filterReadyIssues"
    
    UISwitch *filter = (UISwitch *)sender;
    NSDictionary *userInfo =  @{@"filterReadyIssues": filter.isOn ? @"YES" : @"NO"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"panorama.filterReadyIssues" object:self userInfo:userInfo];
}



- (IBAction)clearToken:(id)sender {
    
    [self.credentialStore clearSavedCredentials];
}


- (void)login:(id)sender
{
    [self.view endEditing:YES];
    [SVProgressHUD show];
    // iLOG(@"login...");
    id params = @{
                  @"username": self.usernameField.text,
                  @"password": self.passwordField.text
                  };
    // iLOG(@"params definidos como: %@...", params);
    [[NSUserDefaults standardUserDefaults] setObject:self.usernameField.text forKey:@"username"];
    [[AuthAPIClient sharedClient] postPath:@"auth/signin" parameters:params
                                   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                       sLOG(@"Sucesso ao logar");
                                       
                                       // a api retorna um json no caso de sucesso
                                       NSString *authToken = [self getValueForKeyFromJsonObject:@"auth_token" jsonObject:responseObject];
                                       [self.credentialStore setAuthToken:authToken];
                                       [SVProgressHUD dismiss];
                                       [self dismissViewControllerAnimated:YES completion:nil];
                                       
                                       NSLog(@"passou com o token %@",self.credentialStore.authToken);
                                       
                                       
                                       
                                   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                       dLOG(@"Erro ao tentar logar usuario");
                                       // a api retorna um json com uma key "error"
                                       NSString *errorMsg = [self getValueForKeyFromJsonObject:@"error" jsonObject:operation.responseData];
                                       [SVProgressHUD showErrorWithStatus:errorMsg];
                                       
                                   }];
};

- (NSString *)getValueForKeyFromJsonObject:(NSString *)key jsonObject:(id)jsonObject
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonObject options:0 error:nil];
    NSString *stringToReturn = [json objectForKey:key];
    
    return stringToReturn;
}

- (void)cancel:(id)sender
{
    [self.view endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

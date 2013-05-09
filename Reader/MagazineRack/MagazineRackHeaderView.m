//
//  MagazineRackHeaderView.m
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineRackHeaderView.h"
//#import "PurchaseManager.h"
#import "MBProgressHUD.h"
#import "InAppStore.h"
#import "Issue.h"
#import "MagazineRackViewController.h"

// adicionado
#import "CredentialStore.h"
#import "LoginViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"

@interface MagazineRackHeaderView()
    @property (strong, nonatomic) UIButton *restoreButton;
    @property (strong, nonatomic) UIButton *subscribeButton;
@end

@implementation MagazineRackHeaderView

    UIView *_topView;
    UIImageView *_backgroundImageView;




#pragma mark -
#pragma mark all login stuff

- (IBAction)getThere:(id)sender {
    if ([self.credentialStore isLoggedIn])
    {
        
        if ([_loginButton.titleLabel.text isEqualToString:@"Sair"]) {
            NSLog(@"apenas sair...");
            [self.credentialStore clearSavedCredentials];
            
            return;
        }
        
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
        
        [self.parentViewController showLoginWindow];
//        UIStoryboard *sb = self.parentViewController.storyboard;
//        LoginViewController *loginWindow = (LoginViewController *)[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
//        
//        /*[self.parentViewController presentViewController:loginWindow animated:YES completion:nil]; */
//        
//        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:loginWindow];
//        
//        //popover.delegate = self.parentViewController;
//    
//        [popover presentPopoverFromRect:_loginButton.frame inView:self.parentViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}



- (void)tokenSaved:(NSNotification *)notification
{
    [self.loginButton setTitle:@"Sair" forState:UIControlStateNormal];
    
    
    [[InAppStore sharedInstance] fakeSubscriber];
    //|| _issue.freeValue
    
    //[self.logText setText:@"usuario logado."];
}

- (void)tokenExpiredProvidences:(NSNotification *)notification
{
    [self.loginButton setTitle:@"Entrar" forState:UIControlStateNormal];
    //[self.logText setText:@"aguardando login"];
}

- (NSString *)getValueForKeyFromJsonObject:(NSString *)key jsonObject:(id)jsonObject
{
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonObject options:0 error:nil];
    NSString *stringToReturn = [json objectForKey:key];
    
    return stringToReturn;
}


- (IBAction)clearToken:(id)sender {
    
    [self.credentialStore clearSavedCredentials];
}

#pragma mark - 
#pragma mark all stuff



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // login stuff
        self.credentialStore = [[CredentialStore alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenExpiredProvidences:) name:@"token-expired" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(tokenSaved:) name:@"token-changed" object:nil];
        
        //
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        UIImage *normalImage = [UIImage imageNamed:@"button"];
        normalImage = [normalImage stretchableImageWithLeftCapWidth:normalImage.size.width / 2.0 topCapHeight:normalImage.size.height / 2.0];
        
        UIImage *highlightedImage = [UIImage imageNamed:@"button_highlighted"];
        highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:normalImage.size.width / 2.0 topCapHeight:normalImage.size.height / 2.0];
                [button setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        
        [button setTitle:@"Restaurar compras" forState:UIControlStateNormal];
        
        button.frame = CGRectMake( CGRectGetWidth(self.frame) - 40 - 175, MARGEM_TOP, 175, 40);
        
        button.titleLabel.shadowOffset = CGSizeMake(0, 1);
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        

        
        button.titleLabel.highlightedTextColor = [UIColor whiteColor];
        UIColor *normalColor = [UIColor whiteColor];
        
        [button setTitleColor:normalColor forState:UIControlStateNormal];
        
        //[button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        
        [self addSubview:button];
        
        // **********************************
        // Login Button
        
        
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_loginButton addTarget:self action:@selector(getThere:) forControlEvents:UIControlEventTouchUpInside];
        normalImage = [UIImage imageNamed:@"button"];
        normalImage = [normalImage stretchableImageWithLeftCapWidth:normalImage.size.width / 2.0 topCapHeight:normalImage.size.height / 2.0];
        
        highlightedImage = [UIImage imageNamed:@"button_highlighted"];
        highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:normalImage.size.width / 2.0 topCapHeight:normalImage.size.height / 2.0];
        [_loginButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_loginButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
        
        _loginButton.frame = CGRectMake( button.frame.origin.x - 30 - 75, MARGEM_TOP, 75, 40);
        _loginButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
        _loginButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _loginButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
        normalColor = [UIColor whiteColor];
        
        [_loginButton setTitleColor:normalColor forState:UIControlStateNormal];
        //[_loginButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:_loginButton];
        
        if ([self.credentialStore isLoggedIn])
        {
            [_loginButton setTitle:@"Sair" forState:UIControlStateNormal];
            [_loginButton setEnabled:YES];
        }
        else
        {
            [_loginButton setTitle:@"Entrar" forState:UIControlStateNormal];
            [_loginButton setEnabled:YES];
        }
        
        // **********************************
        /////////////////////////////////////
        
        
        CGPoint origin = CGPointMake(0, -self.frame.size.height * 3);
        CGSize  size = CGSizeMake(self.frame.size.width, self.frame.size.height * 3);
        
        _topView = [[UIView alloc] initWithFrame:(CGRect){origin,size}];
        _topView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self addSubview:_topView];
        
        _backgroundImageView= [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_backgroundImageView];
        
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self bringSubviewToFront:button];
        
        self.restoreButton = button;
        
        [self bringSubviewToFront:_loginButton];
        
        

        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = @"Panorama da Aquicultura";
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:34];
        //[label sizeToFit];
        label.frame = CGRectMake(30, MARGEM_TOP, 500, 50);
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];;
        label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;

        self.subscribeButton = nil;
        if (FREE_APP) {
            button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            UIImage *normalImage = [UIImage imageNamed:@"button"];
            normalImage = [normalImage stretchableImageWithLeftCapWidth:normalImage.size.width / 2.0 topCapHeight:normalImage.size.height / 2.0];
            
            UIImage *highlightedImage = [UIImage imageNamed:@"button_highlighted"];
            highlightedImage = [highlightedImage stretchableImageWithLeftCapWidth:normalImage.size.width / 2.0 topCapHeight:normalImage.size.height / 2.0];
            [button setBackgroundImage:normalImage forState:UIControlStateNormal];
            [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
            
            if ([self subscribed])
                [button setTitle:@"Subscribe" forState:UIControlStateNormal];
            else
                [button setTitle:@"Unsubscribe" forState:UIControlStateNormal];
            
            button.frame = CGRectMake( CGRectGetWidth(self.frame) - 40 - 110, 20, 110, 40);
            
            button.titleLabel.shadowOffset = CGSizeMake(0, 1);
            button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            
            
            
            button.titleLabel.highlightedTextColor = [UIColor whiteColor];
            UIColor *normalColor = [UIColor colorWithHue:260.0 / 360.0
                                              saturation:4.0 / 100.0
                                              brightness:30.0/100.0
                                                   alpha:1.0];
            
            [button setTitleColor:normalColor forState:UIControlStateNormal];
            
            [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            
            [self addSubview:button];
            self.subscribeButton = button;
            self.restoreButton.frame = CGRectOffset(self.restoreButton.frame, -CGRectGetWidth(self.subscribeButton.frame) - 10, 0);

            [self.subscribeButton addTarget:self
                                     action:@selector(subscribeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];

        }
        
    }
    return self;
}

- (void)buttonPressed:(id)sender
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
	hud.labelText = NSLocalizedString(@"AGUARDANDO", nil);
	hud.removeFromSuperViewOnHide = YES;
    [[InAppStore sharedInstance] restorePurchasesWithCompletionBlock:^(){
        hud.labelText = NSLocalizedString(@"COMPRAS RESTAURADAS", nil);
        [hud hide:YES afterDelay:1];
    } failureBlock:^(NSError*error){
        hud.labelText = NSLocalizedString(@"FALHA AO RESTAURAR COMPRAS", nil);
        [hud hide:YES afterDelay:1];
    }];
    

}

- (void)subscribeButtonTouched:(id)sender
{
    [self setSubscribed:![self subscribed]];
    [self configureButtons];
}


- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    
    UIImage *backgroundImage;
    CGFloat width = CGRectGetWidth(layoutAttributes.frame);
    CGFloat height = CGRectGetHeight(layoutAttributes.frame);
    
    if (width == 768.0){
        backgroundImage = [UIImage imageNamed:@"header"];
        
    }
    else if (width == 1024){
        backgroundImage = [UIImage imageNamed:@"header_landscape"];
    }/*
    CGPoint origin = CGPointMake(0, -height * 3);
    CGSize  size = CGSizeMake(self.frame.size.width, height * 3);
    
    _topView.frame = (CGRect){origin,size};
    _topView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    */
    _backgroundImageView.image =  backgroundImage;
    
    // configure buttons
    
    [self configureButtons];
}

- (void)configureButtons
{
    if (FREE_APP) {
        if ([self hasPurchases]){
            self.restoreButton.hidden = NO;
        }
        else {
            self.restoreButton.hidden = YES;
        }
        
        if([self subscribed]){
            [self.subscribeButton setTitle:@"Unsubscribe" forState:UIControlStateNormal];
        }
        else {
            [self.subscribeButton setTitle:@"Subscribe" forState:UIControlStateNormal];
        }
    }
}
- (BOOL)hasPurchases
{
    NSArray *issues = [Issue MR_findAll];
    BOOL hasPurchases = NO;
    for (Issue *issue in issues) {
        if (!issue.freeValue) {
            hasPurchases = YES;
            break;
        }
    }
    return hasPurchases;
}

- (BOOL)subscribed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"freeSubscriptionEnabled"];
}

- (void)setSubscribed:(BOOL)subscribed
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:subscribed forKey:@"freeSubscriptionEnabled"];
    [defaults synchronize];
}

@end

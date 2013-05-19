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

@interface OptionsViewController ()

@end

@implementation OptionsViewController


- (void)viewDidLoad
{
    
   
    [super viewDidLoad];

}



- (void)viewDidAppear:(BOOL)animated
{
    self.scroller.contentSize = CGSizeMake(320, 1024);
    self.scroller.scrollEnabled = YES;

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
@end

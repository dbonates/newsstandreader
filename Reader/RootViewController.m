//
//  RootViewController.m
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "RootViewController.h"
#import "IssueManager.h"
#import "ReaderViewController.h"
#import "MBProgressHUD.h"
#include <PSPDFKit/PSPDFKit.h>
#import "Navbar+Shadow.h"
#import "UIBarButtonItem+BlocksKit.h"
#import "OptionsViewController.h"

// adicionado
#import "CredentialStore.h"
#import "LoginViewController.h"
#import "AuthAPIClient.h"
#import "SVProgressHUD.h"
#import "InAppStore.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"

#import "RevistaViewController.h"

#define OPTIONS_SIZE CGSizeMake(320,240)
#define LOGIN_WINSIZE CGSizeMake(340,280)
#define DEFAULT_TINT [UIColor colorWithRed:0.600 green:0.400 blue:0.200 alpha:0.550]
#define SECONDARY_TINT [UIColor colorWithRed:0.124 green:0.139 blue:0.198 alpha:1.000]

@interface RootViewController ()<ReaderViewControllerDelegate>
@property (nonatomic, strong) FPPopoverController *popover;
@property (nonatomic, strong) FPPopoverController *assinanteLoginPopover;
@property (nonatomic, strong) UIBarButtonItem *assinanteButton;
@end

@implementation RootViewController{
    UIImageView *_gradientImageView;
    UITapGestureRecognizer *tapGestureRecognizer;
    MBProgressHUD *hud;
}



#pragma mark -
#pragma mark all login stuff

- (IBAction)getThere:(id)sender {
    if ([self.credentialStore isLoggedIn])
    {
        
        if ([self.assinanteButton.title isEqualToString:@"Sair"]) {
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
        
        UIBarButtonItem *buttonItem = sender;
        UIView* btnView = [buttonItem valueForKey:@"view"];
        
        UIStoryboard *sb = self.parentViewController.storyboard;
        LoginViewController *loginWViewController = (LoginViewController *)[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
        
        
        self.assinanteLoginPopover = [[FPPopoverController alloc] initWithViewController:loginWViewController];
        //                                           self.popover.border = NO;
        self.assinanteLoginPopover.contentSize = LOGIN_WINSIZE;
        [self.assinanteLoginPopover setArrowDirection:FPPopoverArrowDirectionUp];
        [self.assinanteLoginPopover presentPopoverFromView:btnView];
        
    }
}



- (void)tokenSaved:(NSNotification *)notification
{
    
    [self.assinanteLoginPopover dismissPopoverAnimated:YES completion:^{
        
        //[self.assinanteButton setTitle:@"Sair"];
        
        self.navigationItem.leftBarButtonItem = nil;
        
        // Get the reference to the current toolbar buttons
        NSMutableArray *toolbarButtons = [self.toolbarItems mutableCopy];
        
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:14.0];
        label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithRed:0.508 green:0.250 blue:0.062 alpha:1.000]; // change this color
        self.navigationItem.titleView = label;
        label.text =@"Panorama da Aquicultura";
        [label sizeToFit];
        
        
        [toolbarButtons addObject:label];
        
        // This is how you remove the button from the toolbar and animate it
        [toolbarButtons removeObject:self.assinanteButton];
        
        
        [self setToolbarItems:toolbarButtons animated:YES];
        
        
        
        
        [[InAppStore sharedInstance] fakeSubscriber];
        //|| _issue.freeValue
        
        //[self.logText setText:@"usuario logado."];
        
    }];
     
     

}
    
    
- (void)tokenExpiredProvidences:(NSNotification *)notification
{
    [self.assinanteButton setTitle:@"Entrar"];
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




- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // login stuff
    self.credentialStore = [[CredentialStore alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenExpiredProvidences:) name:@"token-expired" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(tokenSaved:) name:@"token-changed" object:nil];
    
    // NSLog(@"view did load");
    
    
    /**************** START OF NAVBAR CONFIG **************/
    UINavigationBar *navBar = self.navigationController.navigationBar;
    UIImage *navBarBg;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	
	if (UIInterfaceOrientationIsLandscape(orientation)) {
        navBarBg = [UIImage imageNamed:@"NavBar-iPad-Landscape"];
    }
    else
    {
        navBarBg = [UIImage imageNamed:@"NavBar-iPad"];
    }
    
    
    [navBar setBackgroundImage:navBarBg forBarMetrics:UIBarMetricsDefault];
    
    //UINavigationBar *navBar = self.navigationController.navigationBar;

    // condicionais iPhone / iPad
    // UIImage *navBarBg = [UIImage imageNamed:@"NavBar-iPad"];
    //UIImage *navBarBgLandscape = [UIImage imageNamed:@"NavBar-iPad-Landscape"];
    
    
    
    //    [navBar setBackgroundImage:navBarBg forBarMetrics:UIBarMetricsDefault];
    //   [navBar setBackgroundImage:navBarBgLandscape forBarMetrics:UIBarMetricsLandscapePhone];
    
    self.navigationController.navigationBar.tintColor = DEFAULT_TINT;
    
    
    /*
    UIImage* buttonImage =[UIImage imageNamed:@"TSA_GearIcon"];
    
    
    [[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]
                                       initWithImage:buttonImage style:UIBarButtonItemStylePlain handler:^(id sender) {
                                           UIBarButtonItem *buttonItem = sender;
                                           UIView* btnView = [buttonItem valueForKey:@"view"];
                                           //On these cases is better to specify the arrow direction
                                           

                                           UIStoryboard *sb = self.storyboard;
                                           
                                           OptionsViewController *optionsViewController = (OptionsViewController *)[sb instantiateViewControllerWithIdentifier:@"Options"];
                                           
                                           self.popover = [[FPPopoverController alloc] initWithViewController:optionsViewController];
//                                           self.popover.border = NO;
                                           self.popover.contentSize = OPTIONS_SIZE;
                                           [self.popover setArrowDirection:FPPopoverArrowDirectionUp];
                                           [self.popover presentPopoverFromView:btnView];
                                       }];
    
    self.navigationItem.rightBarButtonItem = settingsButton;
    */
    //[[UIBarButtonItem appearance] setBackgroundImage:[[UIImage alloc] init] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    /*
    UIBarButtonItem *restoreButton = [[UIBarButtonItem alloc] initWithTitle:@"Restaurar compras" style:UIBarButtonItemStylePlain handler:^(id sender) {
        MBProgressHUD *temp_hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
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
    }];
    
     if (![self.credentialStore isLoggedIn]) {
        
        self.assinanteButton = [[UIBarButtonItem alloc] initWithTitle:@"Assinante da edição impressa?" style:UIBarButtonItemStylePlain handler:^(id sender) {
            [self getThere:sender];
        }];
        
        
        
   
       // self.navigationItem.leftBarButtonItem = self.assinanteButton;
    }
    
   
    
    self.navigationItem.rightBarButtonItem = restoreButton;
 */
    [self setupLeftMenuButton];
    /*
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.508 green:0.250 blue:0.062 alpha:1.000]; // change this color
    self.navigationItem.titleView = label;
    label.text =@"Panorama da Aquicultura";
    [label sizeToFit];
    */
    
    /**************** END OF NAVBAR CONFIG **************/
    
    
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(finishedDownloadingAllOnFirstLaunch:)
                   name:IssueManagerFirstStartDownloadedAllNotification
                 object:nil];
    
   	// Do any additional setup after loading the view.
}

-(void)setupLeftMenuButton{
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
//    [leftDrawerButton setMenuButtonColor:DEFAULT_TINT forState:UIControlStateNormal];
//    [leftDrawerButton setMenuButtonColor:DEFAULT_TINT forState:UIControlStateHighlighted];
//    [leftDrawerButton setShadowColor:SECONDARY_TINT forState:UIControlStateNormal];

    [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
}

- (void)leftDrawerButtonPress:(id)sender
{
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UIImage *navBarBg; // = [UIImage imageNamed:@"NavBar-iPad"];
    //UIImage *navBarBgLandscape = [UIImage imageNamed:@"NavBar-iPad-Landscape"];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;   
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        navBarBg = [UIImage imageNamed:@"NavBar-iPad-Landscape"];
    }
    else
    {
        navBarBg = [UIImage imageNamed:@"NavBar-iPad"];
    }
    [navBar setBackgroundImage:navBarBg forBarMetrics:UIBarMetricsDefault];
}

- (void)finishedDownloadingAllOnFirstLaunch:(NSNotification*)notif
{
    [hud hide:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"firstLaunch"]) {
        hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.dimBackground = YES;
        hud.labelText = NSLocalizedString(@"BUSCANDO REVISTAS", nil);
        hud.removeFromSuperViewOnHide = YES;
        
    }

    

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"EmbedMagazineRack"]){
        self.magazineRackViewController = [segue destinationViewController];
    }
}


- (void)show:(Issue*)issue
{
    if (issue.downloadingValue)
        return;
    if (issue.stateValue == IssueStateReadyForDisplayInShelf) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];

        self.magazineDetailViewController = [storyboard instantiateViewControllerWithIdentifier:@"MagazineDetailViewController"];
        self.magazineDetailViewController.issue = issue;
        [self addChildViewController:self.magazineDetailViewController];
//        NSLog(@"%@", self.magazineDetailViewController);
        
        _gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_gradient"]];
        [self.view addSubview:_gradientImageView];
        _gradientImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _gradientImageView.frame = self.view.bounds;
        
        self.magazineDetailViewController.view.frame = CGRectMake(0, 0, 640, 640);
        self.magazineDetailViewController.view.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
        
        self.magazineDetailViewController.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:self.magazineDetailViewController.view];
        
        _gradientImageView.alpha = 0.0;
        _gradientImageView.userInteractionEnabled = YES;
        [_gradientImageView addGestureRecognizer:tapGestureRecognizer];
        self.magazineDetailViewController.view.alpha = 0.0;
        self.magazineDetailViewController.view.transform = CGAffineTransformMakeScale(1.25, 1.25);
        [UIView animateWithDuration:0.3 animations:^(){
            
            _gradientImageView.alpha = 1.0;
            self.magazineDetailViewController.view.alpha = 1.0;
            self.magazineDetailViewController.view.transform = CGAffineTransformMakeScale(0.95, 0.95);
        } completion:^(BOOL finished){
            [UIView animateWithDuration:0.1 animations:^(){
            self.magazineDetailViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }
    else if (issue.stateValue == IssueStateReadyForReading) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"issue == %@ AND type == %@", issue, AssetTypeDocument];
        Asset *documentAsset = [Asset MR_findFirstWithPredicate:predicate];
        
        NSString *filePath = documentAsset.filePath;
        
        // Create the PSPDFDocument. (container for one or multiple pdfs)
        NSURL *documentURL = [NSURL fileURLWithPath:filePath];
        
        PSPDFDocument *document = [PSPDFDocument PDFDocumentWithURL:documentURL];
        document.title = @"Panorama da aquicultura";
        
        
        document.editableAnnotationTypes = [NSOrderedSet orderedSetWithArray:@[
                                            PSPDFAnnotationTypeStringLink,
                                            PSPDFAnnotationTypeStringHighlight,
                                            PSPDFAnnotationTypeStringUnderline,
                                            PSPDFAnnotationTypeStringStrikeout,
                                            PSPDFAnnotationTypeStringNote,
                                            PSPDFAnnotationTypeStringLine
                                            ]];
        
         /*
       
         Anotações  possíveis
         
         PSPDFAnnotationTypeStringLink;
         PSPDFAnnotationTypeStringHighlight;
         PSPDFAnnotationTypeStringUnderline;
         PSPDFAnnotationTypeStringStrikeout;
         PSPDFAnnotationTypeStringNote;
         PSPDFAnnotationTypeStringFreeText;
         PSPDFAnnotationTypeStringInk;
         PSPDFAnnotationTypeStringSquare;
         PSPDFAnnotationTypeStringCircle;
         PSPDFAnnotationTypeStringLine;
         PSPDFAnnotationTypeStringSignature;
         
         */
        
        
        // Open view controller. Embed into an UINavigationController to enable the toolbar.
        RevistaViewController *pdfController = [[RevistaViewController alloc] initWithDocument:document];
        
        ///// CONFIGURACOES
        
//        pdfController.pageTransition = PSPDFPageCurlTransition;
        pdfController.pageMode = PSPDFPageModeAutomatic;
        pdfController.statusBarStyleSetting = PSPDFStatusBarSmartBlackHideOnIpad;
        pdfController.tintColor = SECONDARY_TINT;
        pdfController.shouldTintAlertView = YES;
        pdfController.shouldTintPopovers = YES;
        pdfController.rightBarButtonItems = @[pdfController.brightnessButtonItem, pdfController.searchButtonItem, pdfController.outlineButtonItem, pdfController.viewModeButtonItem];
        
        // don't use thumbnails if the PDF is not rendered.
        // FullPageBlocking feels good when combined with pageCurl, less great with other scroll modes, especially PSPDFPageScrollContinuousTransition.
        pdfController.renderingMode = PSPDFPageRenderingModeFullPageBlocking;
        
        ////////
        
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:pdfController];
        [self presentViewController:navController animated:YES completion:nil];
       
        
        /*
        
        ReaderDocument *document = [ReaderDocument withDocumentFilePath:filePath password:nil];
        NSLog(@"document %@", document);
        if (document != nil) // Must have a valid ReaderDocument object in order to proceed with things
        {
            ReaderViewController *readerViewController = [[ReaderViewController alloc] initWithReaderDocument:document];
            
            readerViewController.delegate = self; // Set the ReaderViewController delegate to self
            
            
            readerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            readerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self presentViewController:readerViewController animated:YES completion:^(){NSLog(@"completion");}];
        }
         
         */
   
    }
}

- (void)handleTapGesture:(UITapGestureRecognizer*)gestureRecognizer
{
    NSLog(@"tap called");
    [UIView animateWithDuration:0.3 animations:^(){
        
        _gradientImageView.alpha = 0.0;
        self.magazineDetailViewController.view.alpha = 0.0;
        self.magazineDetailViewController.view.transform = CGAffineTransformMakeScale(0.0, 0.0);
    }
                     completion:^(BOOL finished){
    
                         [_gradientImageView removeFromSuperview];
                         _gradientImageView = nil;
                         [self.magazineDetailViewController.view removeFromSuperview];
                         self.magazineDetailViewController = nil;
                         [self.magazineDetailViewController removeFromParentViewController];
    }];
}

- (void)dismissReaderViewController:(ReaderViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^(){NSLog(@"dismissed");}];
}

@end

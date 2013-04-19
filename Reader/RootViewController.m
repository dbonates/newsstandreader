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

@interface RootViewController ()<ReaderViewControllerDelegate>


@end

@implementation RootViewController{
    UIImageView *_gradientImageView;
    UITapGestureRecognizer *tapGestureRecognizer;
    MBProgressHUD *hud;
}

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
//    NSLog(@"view did load");
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self
               selector:@selector(finishedDownloadingAllOnFirstLaunch:)
                   name:IssueManagerFirstStartDownloadedAllNotification
                 object:nil];
    
   	// Do any additional setup after loading the view.
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
        PSPDFViewController *pdfController = [[PSPDFViewController alloc] initWithDocument:document];
        
        ///// CONFIGURACOES
        
        pdfController.pageTransition = PSPDFPageCurlTransition;
        pdfController.pageMode = PSPDFPageModeAutomatic;
        pdfController.statusBarStyleSetting = PSPDFStatusBarSmartBlackHideOnIpad;
        
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

//
//  MagazineDetailViewController.m
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineDetailViewController.h"
#import "MagazineRackRenderer.h"
#import "JSONKit.h"
#import "MBProgressHUD.h"
#import "InAppStore.h"
#import "CoreData+MagicalRecord.h"
@interface MagazineDetailViewController ()
@property (strong, nonatomic) NSArray *tocArray;
@end

@implementation MagazineDetailViewController

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
    
    
    
    UIImage *roundRectButtonImage = [UIImage imageNamed:@"detail_sheet_button"];
    roundRectButtonImage = [roundRectButtonImage stretchableImageWithLeftCapWidth:roundRectButtonImage.size.width / 2.0
                                                                     topCapHeight:roundRectButtonImage.size.height / 2.0];
    
    UIImage *roundRectButtonHighligtedImage = [UIImage imageNamed:@"detail_sheet_button_highlighted"];
    roundRectButtonHighligtedImage = [roundRectButtonHighligtedImage stretchableImageWithLeftCapWidth:roundRectButtonHighligtedImage.size.width / 2.0
                                                                     topCapHeight:roundRectButtonHighligtedImage.size.height / 2.0];
    
    UIImage *shadowButtonImage = [UIImage imageNamed:@"detail_sheet_shadow_button"];
    shadowButtonImage = [shadowButtonImage stretchableImageWithLeftCapWidth:shadowButtonImage.size.width / 2.0
                                                                     topCapHeight:shadowButtonImage.size.height / 2.0];
    
    [self.buyButton setBackgroundImage:roundRectButtonImage forState:UIControlStateNormal];
    [self.subscribeButton setBackgroundImage:roundRectButtonImage forState:UIControlStateNormal];
    [self.downloadButton setBackgroundImage:roundRectButtonImage forState:UIControlStateNormal];
    
    [self.buyButton setBackgroundImage:roundRectButtonHighligtedImage forState:UIControlStateHighlighted];
    [self.subscribeButton setBackgroundImage:roundRectButtonHighligtedImage forState:UIControlStateHighlighted];
    [self.downloadButton setBackgroundImage:roundRectButtonImage forState:UIControlStateNormal];
    
    [self.previewButton setBackgroundImage:shadowButtonImage forState:UIControlStateNormal];
//    [self.tableButton setBackgroundImage:shadowButtonImage forState:UIControlStateNormal];
    
    UIColor *normalColor = [UIColor colorWithHue:260.0 / 360.0
                                      saturation:4.0 / 100.0
                                      brightness:30.0/100.0
                                           alpha:1.0];
    self.buyButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.downloadButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.subscribeButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.previewButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
    self.tableButton.titleLabel.highlightedTextColor = [UIColor whiteColor];
    
    [self.buyButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.downloadButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.subscribeButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.previewButton setTitleColor:normalColor forState:UIControlStateNormal];
    [self.tableButton setTitleColor:normalColor forState:UIControlStateNormal];
    
    [self.buyButton setTitleColor:normalColor forState:UIControlStateHighlighted];
    [self.downloadButton setTitleColor:normalColor forState:UIControlStateHighlighted];
    [self.subscribeButton setTitleColor:normalColor forState:UIControlStateHighlighted];
    [self.previewButton setTitleColor:normalColor forState:UIControlStateHighlighted];
    [self.tableButton setTitleColor:normalColor forState:UIControlStateHighlighted];
    
    [self.buyButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.downloadButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.subscribeButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.previewButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.tableButton setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    

    self.buyButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.downloadButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.subscribeButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.previewButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    self.tableButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
    
    

    UIImage *shadowImage = [UIImage imageNamed:@"detail_sheet_shadow"];
    UIImageView *shadowImageView = [[UIImageView alloc] initWithImage:shadowImage];
    [self.view addSubview:shadowImageView];
    [self.view sendSubviewToBack:shadowImageView];
    shadowImageView.center = CGPointMake(320, 320);
    
    MagazineRackRenderer *renderer = [[MagazineRackRenderer alloc] init];
    renderer.shadowOffset = CGSizeMake(0, -5);
    renderer.shadowRadius = 10;
    renderer.pageWidth = 1.0;
    renderer.numberOfPages = 4;
    renderer.scale = [[UIScreen mainScreen] scale];
    
    Asset *coverAsset = self.issue.coverImage[0];
    NSString *coverImagePath = coverAsset.filePath;
    UIImage *coverImage = [[UIImage alloc] initWithContentsOfFile:coverImagePath];

    MagazineRackRendererResult *result = [renderer renderImage:coverImage constrainedToHeight:self.coverImageView.frame.size.height - 20.0];
    self.coverImageView.image = result.image;
    
    NSLog(@"%@", NSStringFromCGRect(self.coverImageView.frame));
    NSLog(@"%@", NSStringFromCGSize(result.image.size));
    self.tableView.hidden = YES;
    
    
    self.tocArray = [self.issue.toc objectFromJSONString];
    
    [self updateUI];
    [[InAppStore sharedInstance] addObserver:self
                                       forKeyPath:@"storeCacheState"
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];
    [[InAppStore sharedInstance] addObserver:self
                                  forKeyPath:@"subscriptionState"
                                     options:NSKeyValueObservingOptionNew
                                     context:nil];
	// Do any additional setup after loading the view.
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
        Issue *localIssue = (Issue*)[localContext objectWithID:self.issue.objectID];
        localIssue.newValue = NO;
        self.issue.newValue = NO;

    }];
    
    self.detailTextView.text = self.issue.issueDescription;
    self.nameLabel.text = self.issue.name;
    
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnPreviewTouched:(id)sender
{
    if(_mode == MagazineDetailTableMode){
        CGFloat midX = CGRectGetMidX(self.previewButton.frame);
        self.shadowNippleImageView.center = CGPointMake(midX, self.shadowNippleImageView.center.y);
        self.shadowLeftImageView.frame = CGRectMake(0,
                                                    CGRectGetMinY(self.shadowLeftImageView.frame),
                                                    CGRectGetMinX(self.shadowNippleImageView.frame),
                                                    CGRectGetHeight(self.shadowLeftImageView.frame));
        
        self.shadowRightImageView.frame = CGRectMake(CGRectGetMaxX(self.shadowNippleImageView.frame),
                                                     CGRectGetMinY(self.shadowRightImageView.frame),
                                                     CGRectGetMaxX(self.shadowRightImageView.frame) - CGRectGetMaxX(self.shadowNippleImageView.frame),
                                                     CGRectGetHeight(self.shadowRightImageView.frame));
        
        _mode = MagazineDetailPreviewMode;
        
        
        UIImage *shadowButtonImage = [UIImage imageNamed:@"detail_sheet_shadow_button"];
        shadowButtonImage = [shadowButtonImage stretchableImageWithLeftCapWidth:shadowButtonImage.size.width / 2.0
                                                                   topCapHeight:shadowButtonImage.size.height / 2.0];
        
        
        [self.previewButton setBackgroundImage:shadowButtonImage forState:UIControlStateNormal];
        [self.tableButton setBackgroundImage:nil forState:UIControlStateNormal];
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
        
        
    }
}

- (IBAction)btnTableTouched:(id)sender
{
    if(_mode == MagazineDetailPreviewMode){
        CGFloat midX = CGRectGetMidX(self.tableButton.frame);
        self.shadowNippleImageView.center = CGPointMake(midX, self.shadowNippleImageView.center.y);
        self.shadowLeftImageView.frame = CGRectMake(0,
                                                    CGRectGetMinY(self.shadowLeftImageView.frame),
                                                    CGRectGetMinX(self.shadowNippleImageView.frame),
                                                    CGRectGetHeight(self.shadowLeftImageView.frame));
        
        self.shadowRightImageView.frame = CGRectMake(CGRectGetMaxX(self.shadowNippleImageView.frame),
                                                     CGRectGetMinY(self.shadowRightImageView.frame),
                                                     CGRectGetMaxX(self.shadowRightImageView.frame) - CGRectGetMaxX(self.shadowNippleImageView.frame),
                                                     CGRectGetHeight(self.shadowRightImageView.frame));
        
        _mode = MagazineDetailTableMode;
        
        
        UIImage *shadowButtonImage = [UIImage imageNamed:@"detail_sheet_shadow_button"];
        shadowButtonImage = [shadowButtonImage stretchableImageWithLeftCapWidth:shadowButtonImage.size.width / 2.0
                                                                   topCapHeight:shadowButtonImage.size.height / 2.0];
        
        
        [self.previewButton setBackgroundImage:nil forState:UIControlStateNormal];
        [self.tableButton setBackgroundImage:shadowButtonImage forState:UIControlStateNormal];
        
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
    }
}

- (IBAction)btnSubscribeTouched:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe"
                                                        message:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi id lectus arcu, nec placerat purus. Cras bibendum mollis commodo."
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:nil];
    
    NSArray *subscriptionOptions = [[InAppStore sharedInstance] subscriptionProducts];
    for (SKProduct *product in subscriptionOptions) {
        alertView.message = product.localizedDescription;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.product_identifier == %@", product.productIdentifier];
        NSArray *objects = [[[IssueManager sharedInstance] subscriptionOptions] filteredArrayUsingPredicate:predicate];
        NSLog(@"wtf %@", [[IssueManager sharedInstance] subscriptionOptions]);
        NSString *description = @"";
        if(objects.count)
            description = objects[0][@"name"];
        NSNumber *price = product.price;
        NSString *buttonText = [NSString stringWithFormat:@"%@ %@", description, price];
        [alertView addButtonWithTitle:buttonText];
    }
    
    [alertView show];
}

- (IBAction)btnBuyTouched:(id)sender
{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
	
	// Configure for text only and offset down
	hud.mode = MBProgressHUDModeText;
    hud.dimBackground = YES;
	hud.labelText = NSLocalizedString(@"BUSCANDO", nil);
	hud.removeFromSuperViewOnHide = YES;
	

    [[InAppStore sharedInstance] purchaseProduct:[[InAppStore sharedInstance] productWithProductIdentifier:self.issue.productIdentifier]
                                 completionBlock:^(){
                                     [self updateUI];
                                     hud.labelText = NSLocalizedString(@"DONE", nil);
                                     [hud hide:YES afterDelay:1];
                                     
                                 } failureBlock:^(NSError*error){
                                     NSLog(@"failed with error %@", error);
                                     hud.labelText = NSLocalizedString(@"PURCHASE FAILED", nil);
                                     [hud hide:YES afterDelay:1];
                                 }];

}

- (IBAction)btnDownloadTouched:(id)sender
{
    
    [[IssueManager sharedInstance] downloadDocumentForIssue:self.issue];
    [self.parentViewController performSelector:@selector(handleTapGesture:) withObject:nil];
}


- (void)updateUI
{
    if (!self.issue.freeValue){
        InAppStore *store = [InAppStore sharedInstance];
     //   NSLog(@"issue:%@ purchased :%d", self.issue.productIdentifier, self.issue.productIdentifier);

//        NSLog(@"Revista comprada???");
//        
//        NSLog(@"store.storeCacheState != StoreCacheStateOK");
//        NSLog(@"%d == %d", store.storeCacheState, StoreCacheStateOK);
//        NSLog(@"&&");
//        NSLog(@"(");
//        NSLog(@"store.subscriptionState: %d", store.subscriptionState);
//        NSLog(@"SubscriptionStateSubscribed: %d", SubscriptionStateSubscribed);
//        NSLog(@"||");
//        NSLog(@"self.issue.purchased: %d", [self.issue.purchased intValue]);
//        NSLog(@"(");
//        
        /*
         
         StoreCacheState:
         
         StoreCacheStateDirty       - 0
         StoreCacheStateOK          - 1
         StoreCacheStateUpdating    - 2
         
         
         SubscriptionState:
         
         SubscriptionStateUnknown           0
         SubscriptionStateSubscribed        1
         SubscriptionStateNotSubscribed     2
         */


        if (store.storeCacheState != StoreCacheStateOK
            &&
            !(store.subscriptionState == SubscriptionStateSubscribed || self.issue.purchased))
        {
            //NSLog(@"A comprar revista!");
            self.buyButton.hidden = YES;
            self.subscribeButton.hidden = YES;
            self.downloadButton.hidden = YES;
            self.activityIndicator.hidden = NO;
            [self.activityIndicator startAnimating];
        }
        else{
            self.activityIndicator.hidden = YES;
            if (store.subscriptionState == SubscriptionStateSubscribed || self.issue.purchased){
                self.downloadButton.hidden = NO;
                self.buyButton.hidden = YES;
                self.subscribeButton.hidden = YES;
            }
            else {
                self.downloadButton.hidden = YES;
                self.buyButton.hidden = NO;
                self.subscribeButton.hidden = FREE_APP;
                if (FREE_APP) {
                    self.buyButton.center = CGPointMake(self.buyButton.center.x, self.subscribeButton.center.y);
                }
            }

        }
    }
    else {
        self.buyButton.hidden = YES;
        self.subscribeButton.hidden = YES;
        self.downloadButton.hidden = NO;
        self.activityIndicator.hidden = YES;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"storeCacheState"])
        [self updateUI];
    if([keyPath isEqualToString:@"subscriptionState"])
        [self updateUI];
       
}
#pragma mark UICollectionViewDelegate & UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.issue.previews.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MagazinePreviewCell"
                                                                           forIndexPath:indexPath];
    
    Asset *previewAsset = self.issue.previews[indexPath.row];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:314];
    
    UIImage *image = [UIImage imageWithContentsOfFile:previewAsset.filePath];
    
    MagazineRackRenderer *renderer = [[MagazineRackRenderer alloc] init];
    renderer.shadowOffset = CGSizeMake(0, -5);
    renderer.shadowRadius = 10;
    renderer.pageWidth = 1.0;
    renderer.numberOfPages = 0;
    renderer.scale = [[UIScreen mainScreen] scale];
    
    MagazineRackRendererResult *result = [renderer renderImage:image constrainedToHeight:imageView.frame.size.height];
    imageView.image = result.image;


    self.nameLabel.text = self.issue.name;
    

    
    return cell;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tocArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"TocCell"
                                                                 forIndexPath:indexPath];

    
    UILabel *leftLabel = (UILabel*)[cell viewWithTag:31];
    UILabel *rightLabel = (UILabel*)[cell viewWithTag:314];
    
    NSDictionary *tocDictionary = self.tocArray[indexPath.row];
    
    rightLabel.text = tocDictionary[@"pages"];
    leftLabel.text = tocDictionary[@"text"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)dealloc
{
    [[InAppStore sharedInstance] removeObserver:self forKeyPath:@"storeCacheState"];
    [[InAppStore sharedInstance] removeObserver:self forKeyPath:@"subscriptionState"];

}

#pragma mark - UIAlertViewDelegate

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        NSArray *options = [[IssueManager sharedInstance] subscriptionOptions];
        NSDictionary *optionDictionary = options[buttonIndex -1];
        NSLog(@"should subscribe to : %@", optionDictionary);
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeText;
        hud.dimBackground = YES;
        hud.labelText = NSLocalizedString(@"BUSCANDO", nil);
        hud.removeFromSuperViewOnHide = YES;
        
        SKProduct *product = [InAppStore sharedInstance].subscriptionProducts[buttonIndex-1];
        [[InAppStore sharedInstance] purchaseProduct:product
                                     completionBlock:^(){
                                         [self observeValueForKeyPath:nil ofObject:nil change:nil context:nil];
                                         hud.labelText = NSLocalizedString(@"DONE", nil);
                                         [hud hide:YES afterDelay:1];
                                         
                                     } failureBlock:^(NSError*error){
                                         NSLog(@"failed with error %@", error);
                                         hud.labelText = NSLocalizedString(@"PURCHASE FAILED", nil);
                                         [hud hide:YES afterDelay:1];
                                     }];

    }
    
}
@end

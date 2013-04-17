//
//  MagazineDetailViewController.h
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IssueManager.h"
typedef enum{
    MagazineDetailPreviewMode,
    MagazineDetailTableMode
} MagazineDetailMode;

@interface MagazineDetailViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDataSource, UITableViewDelegate>
{
    MagazineDetailMode _mode;
}

@property (weak, nonatomic) IBOutlet UITextView *detailTextView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *buyButton;
@property (weak, nonatomic) IBOutlet UIButton *subscribeButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
@property (weak, nonatomic) IBOutlet UIButton *tableButton;
@property (weak, nonatomic) IBOutlet UIImageView *shadowLeftImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowNippleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *shadowRightImageView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) Issue *issue;
@property (weak, nonatomic) IBOutlet UIButton *downloadButton;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)btnPreviewTouched:(id)sender;
- (IBAction)btnTableTouched:(id)sender;
- (IBAction)btnSubscribeTouched:(id)sender;
- (IBAction)btnBuyTouched:(id)sender;
- (IBAction)btnDownloadTouched:(id)sender;
@end

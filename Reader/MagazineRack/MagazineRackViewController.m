//
//  MagazineRackViewController.m
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineRackViewController.h"
#import "MagazineRackLayout.h"
#import "MagazineRackCell.h"
#import "MagazineRackHeaderView.h"
#import "MagazineRackShelfDecorationView.h"
#import "IssueManager.h"
#import "LoginViewController.h"



@interface MagazineRackViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MagazineRackViewController

static NSString *MagazineRackHeaderViewReuseIdentifier = @"MagazineRackHeaderView";
static NSString *MagazineRackCellReuseIdentifier = @"MagazineRackCell";


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self.collectionView registerClass:[MagazineRackHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:MagazineRackHeaderViewReuseIdentifier];
    
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        [self configureLayoutForPortrait];
    }
    else{
        [self configureLayoutForLandscape];
    }
    [layout registerClass:[MagazineRackShelfDecorationView class]
  forDecorationViewOfKind:MagazineRackLayoutShelfDecorationViewKind];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"state == %@ OR state == %@", @(IssueStateReadyForDisplayInShelf), @(IssueStateReadyForReading)];
    self.fetchedResultsController = [Issue MR_fetchAllSortedBy:@"date"
                                                     ascending:NO
                                                 withPredicate:predicate
                                                       groupBy:nil
                                                      delegate:self];
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)configureLayoutForPortrait
{
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
    layout.headerReferenceSize = CGSizeMake(768, 229);
    layout.minimumLineSpacing = 250.0 - 186.0;
    layout.minimumInteritemSpacing = 35.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 60, 250-186, 60);
    layout.headerReferenceSize = CGSizeMake(768, 129);
}

- (void)configureLayoutForLandscape
{
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
    layout.headerReferenceSize = CGSizeMake(1024, 206);
    layout.minimumLineSpacing = 250.0 - 186.0;
    layout.minimumInteritemSpacing = 55.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 60, 250-186, 60);
    layout.headerReferenceSize = CGSizeMake(768, 229);
    
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)){
        [self configureLayoutForPortrait];
    }
    else{
        [self configureLayoutForLandscape];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource & UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = [UIImage imageNamed:@"7"];
    
    CGSize size = [MagazineRackCell sizeWithImage:image constrainedToHeight:186];
    
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{

    UIImage *image = [UIImage imageNamed:@"7"];
    
    CGSize size =  [MagazineRackCell sizeWithImage:image constrainedToHeight:186];

    return 250 - size.height;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    NSLog(@"count %d", count);
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Issue *issue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    MagazineRackCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:MagazineRackCellReuseIdentifier forIndexPath:indexPath];
    cell.issue = issue;
    return cell;
}



// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    MagazineRackHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                                 withReuseIdentifier:MagazineRackHeaderViewReuseIdentifier
                                                                                        forIndexPath:indexPath];

    headerView.parentViewController = self;
    return headerView;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Asset *asset = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.parentViewController performSelector:@selector(show:) withObject:asset];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
}
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView reloadData];
}

- (void)showLoginWindow {
    NSLog(@"showLoginWindow");
    
    UIStoryboard *sb = self.storyboard;
    LoginViewController *loginWindow = (LoginViewController *)[sb instantiateViewControllerWithIdentifier:@"LoginViewController"];
    
    [self.parentViewController presentViewController:loginWindow animated:YES completion:nil];
    
//    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:loginWindow];
//    popover.delegate = (id)self.parentViewController;
//    CGRect frame = CGRectMake(10, 10, 800, 800);
//    [popover presentPopoverFromRect:frame inView:self.parentViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}

@end

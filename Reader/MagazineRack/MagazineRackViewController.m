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
//#import "MagazineRackHeaderView.h"
#import "MagazineRackShelfDecorationView.h"
#import "IssueManager.h"
#import "LoginViewController.h"

#define MINIMUM_LINE_SPACING 47

@interface MagazineRackViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MagazineRackViewController

//static NSString *MagazineRackHeaderViewReuseIdentifier = @"MagazineRackHeaderView";
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
    
//    [self.collectionView registerClass:[MagazineRackHeaderView class]
//            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                   withReuseIdentifier:MagazineRackHeaderViewReuseIdentifier];
    
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)){
        [self configureLayoutForPortrait];
    }
    else{
        [self configureLayoutForLandscape];
    }
    [layout registerClass:[MagazineRackShelfDecorationView class]
  forDecorationViewOfKind:@"MagazineRackLayoutShelfDecorationView"];
    
    
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
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundChoosed:) name:@"panorama.backgroundChanged" object:nil];
    
    NSString *patternBkSaved = [[NSUserDefaults standardUserDefaults] objectForKey:@"patternBk"];

    if (patternBkSaved) {
        self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternBkSaved]];
    }
    else
    {
        self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Wood Tile"]];
    }
}

- (void)backgroundChoosed:(NSNotification *)notification
{
    //wLOG(@"%@", [notification userInfo]);
    NSString *patternName = [[notification userInfo] objectForKey:@"patternBk"];
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:patternName]];
    
    [[NSUserDefaults standardUserDefaults] setObject:patternName forKey:@"patternBk"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}




- (void)configureLayoutForPortrait
{
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
//    layout.headerReferenceSize = CGSizeMake(768, HEADER_HEIGHT);
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = -15.0;
    layout.sectionInset = UIEdgeInsetsMake(0, MARGEM_ESQUERDA, MARGEM_TOP, MARGEM_DIREITA); // laterais
//    layout.headerReferenceSize = CGSizeMake(768, 150);
}

- (void)configureLayoutForLandscape
{
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
//    layout.headerReferenceSize = CGSizeMake(1024, HEADER_HEIGHT);
    layout.minimumLineSpacing = 50;
    layout.minimumInteritemSpacing = -15.0;
    layout.sectionInset = UIEdgeInsetsMake(0, MARGEM_ESQUERDA, SHELF_HEIGHT-COVER_HEIGHT_CONSTRAIN, MARGEM_DIREITA); // laterais
//    layout.headerReferenceSize = CGSizeMake(768, 100);
    
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
    UIImage *image = [UIImage imageNamed:@"magazine_mockup_base"];
    
    CGSize size = [MagazineRackCell sizeWithImage:image constrainedToHeight:COVER_HEIGHT_CONSTRAIN];
    //dLOG(@"%@", NSStringFromCGSize(size));
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{

 //   UIImage *image = [UIImage imageNamed:@"7"];
    
//    CGSize size =  [MagazineRackCell sizeWithImage:image constrainedToHeight:COVER_HEIGHT_CONSTRAIN];
    return MINIMUM_LINE_SPACING;
//    return SHELF_HEIGHT - size.height;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
//    NSLog(@"count %d", count);
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
//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    MagazineRackHeaderView *headerView = [self.collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                                                                                 withReuseIdentifier:MagazineRackHeaderViewReuseIdentifier
//                                                                                        forIndexPath:indexPath];
//
//    headerView.parentViewController = self;
//    return headerView;
//}

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

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
#import "MagazineRackShelfDecorationView.h"
#import "IssueManager.h"
#import "LoginViewController.h"
#import "SimpleCell.h"

#define MINIMUM_LINE_SPACING 47

@interface MagazineRackViewController ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end

@implementation MagazineRackViewController

//NSString * IssueManagerFirstStartDownloadedAllNotification = @"com.reader.issueManger.postFirstStartNotification";

BOOL debugOn = YES;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
   
     
    MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
     
   [layout
     setupWithItemSize:CGSizeMake(150, 200)
     minimunGapBetweenItems:30
     uiCollectionReusableViewClassName:@"MagazineRackShelfDecorationView"
    ];
    [layout registerClass:NSClassFromString(@"MagazineRackShelfDecorationView") forDecorationViewOfKind:@"MagazineRackShelfDecorationView"];
   
    [layout registerClass:[MagazineRackShelfDecorationView class]forDecorationViewOfKind:@"MagazineRackLayoutShelfDecorationView"];

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
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(issuesListUpdated:) name:@"com.reader.issueManger.postFirstStartNotification" object:nil];
}
- (void)issuesListUpdated:(NSNotification *)notification
{
    wLOG(@"issuesListUpdated");
    //NSInteger count = self.fetchedResultsController.fetchedObjects.count;
    //MagazineRackLayout *layout = (MagazineRackLayout*)self.collectionView.collectionViewLayout;
    
    
    
    // [layout registerClass:[MagazineRackShelfDecorationView class]
    //forDecorationViewOfKind:@"MagazineRackLayoutShelfDecorationView"];
    
    
    
    
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource & UICollectionViewFlowLayoutDelegate



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (debugOn) {
        return 40;
    }
    NSInteger count = self.fetchedResultsController.fetchedObjects.count;
//    NSLog(@"count %d", count);
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    Issue *issue;
    if (debugOn) {
        NSIndexPath *ip = [NSIndexPath indexPathForItem:indexPath.row%[[self.fetchedResultsController fetchedObjects] count] inSection:0];
        issue = [self.fetchedResultsController objectAtIndexPath:ip];
    }
    else
    {
        issue = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    MagazineRackCell *cell = (MagazineRackCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"MagazineRackCell" forIndexPath:indexPath];
    cell.issue = issue;

    return cell;
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

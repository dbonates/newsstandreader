//
//  MagazineRackViewController.h
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreData+MagicalRecord.h"

@interface MagazineRackViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout,NSFetchedResultsControllerDelegate>



- (void)showLoginWindow;

@end

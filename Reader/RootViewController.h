//
//  RootViewController.h
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagazineRackViewController.h"
#import "MagazineDetailViewController.h"

@interface RootViewController : UIViewController
@property (strong, nonatomic) MagazineRackViewController *magazineRackViewController;
@property (strong, nonatomic) MagazineDetailViewController *magazineDetailViewController;

@end

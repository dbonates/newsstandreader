//
//  MagazineRackCell.h
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Issue.h"
#import "Asset.h"

@interface MagazineRackCell : UICollectionViewCell
@property (strong, nonatomic) Issue *issue;
/*
+ sizeWithImage:constrainedToHeight: convenience method to find out how big the cell is going to be when displaying a specific image.
 */
+ (CGSize)sizeWithImage:(UIImage*)image constrainedToHeight:(CGFloat)height;

@end

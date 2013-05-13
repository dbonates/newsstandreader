//
//  MagazineRackLayout.h
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface MagazineRackLayout : UICollectionViewFlowLayout
- (void)setupWithItemSize:(CGSize)itemSize minimunGapBetweenItems:(NSInteger)minimunGapBetweenItems uiCollectionReusableViewClassName:(NSString *)uiCollectionReusableViewClassName;
@end

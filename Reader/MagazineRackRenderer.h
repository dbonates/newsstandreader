//
//  MagazineRackRenderer.h
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MagazineRackRendererResult : NSObject
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) CGRect contentRect;
@end
@interface MagazineRackRenderer : NSObject


@property (nonatomic) CGFloat shadowRadius;
@property (nonatomic) CGSize shadowOffset;

@property (nonatomic) NSUInteger numberOfPages;
@property (nonatomic) CGFloat pageWidth;

@property (nonatomic) CGFloat scale;

/*
- renderImage:constrainedToHeight: renders an image with the specified effects - shadow, pages - so that it keeps
 the proportions of the image but doesn't exceed the height (including the shadow & pages)
*/
 
- (MagazineRackRendererResult*)renderImage:(UIImage*)image constrainedToHeight:(CGFloat)constraintHeight;
@end

//
//  MagazineRackLayout.m
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineRackLayout.h"


@implementation MagazineRackLayout

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self){
        
    }
    
    return self;
}


- (void)prepareLayout
{
    [super prepareLayout];
}


- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    
    NSArray *superAttributes = [super layoutAttributesForElementsInRect:rect];
    
    NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:0];
    
    for (UICollectionViewLayoutAttributes *attribute in superAttributes) {
        if (attribute.frame.origin.x + attribute.frame.size.width <= self.collectionViewContentSize.width) {
            [attributes addObject:attribute];
            
            if(attribute.representedElementCategory != UICollectionElementCategoryCell &&[attribute.representedElementKind isEqualToString:UICollectionElementKindSectionHeader])
                attribute.zIndex = -1;
        }
    }
    CGFloat yOffset = CGRectGetMinY(rect);
    CGFloat curOffset = yOffset;
    
    if (curOffset >=0){
        while(curOffset <= CGRectGetMaxY(rect)){
            NSUInteger intY = curOffset;
            intY -= self.headerReferenceSize.height;
            
            NSUInteger row = intY / SHELF_HEIGHT;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            
            UICollectionViewLayoutAttributes *decorationAttributes = [self layoutAttributesForDecorationViewOfKind:MagazineRackLayoutShelfDecorationViewKind
                                                                                             atIndexPath:indexPath];
            
            [attributes addObject:decorationAttributes];
            
            curOffset += SHELF_HEIGHT;
        }
    }
    
    if (curOffset >=self.collectionView.contentSize.height){
        for(NSUInteger index = 0; index < 4; index ++){
        
            NSUInteger intY = curOffset;
            intY -= self.headerReferenceSize.height;
            
            NSUInteger row = intY / SHELF_HEIGHT;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            
            UICollectionViewLayoutAttributes *decorationAttributes = [self layoutAttributesForDecorationViewOfKind:MagazineRackLayoutShelfDecorationViewKind
                                                                                                       atIndexPath:indexPath];
            
            [attributes addObject:decorationAttributes];
            
            curOffset += SHELF_HEIGHT;
        }
    }
    return attributes;
    
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *superAttributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    return superAttributes;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *superAttributes = [super layoutAttributesForSupplementaryViewOfKind:kind
                                                                                              atIndexPath:indexPath];
    
    return superAttributes;
}
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:decorationViewKind
                                                                                                               withIndexPath:indexPath];
    
    if ([decorationViewKind isEqualToString:MagazineRackLayoutShelfDecorationViewKind])
    {
        CGFloat yOffset = self.headerReferenceSize.height + indexPath.row * SHELF_HEIGHT - MAGAZINE_PAD_TOP;
        
        attributes.frame = CGRectMake(0, yOffset, CGRectGetWidth(self.collectionView.frame), SHELF_HEIGHT);
        attributes.zIndex = -1;
    }
    
    return attributes;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    BOOL superShouldInvalidate = [super shouldInvalidateLayoutForBoundsChange:newBounds];
    
    return superShouldInvalidate;
}
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGPoint superTargetContentOffset = [super targetContentOffsetForProposedContentOffset:proposedContentOffset
                                                                    withScrollingVelocity:velocity];
    
    return superTargetContentOffset;
}

- (CGSize)collectionViewContentSize
{
    CGSize superSize = [super collectionViewContentSize];
    if (superSize.height < CGRectGetHeight(self.collectionView.bounds))
    {
        superSize = self.collectionView.bounds.size;
        superSize.height += 1.0;
    }
    return superSize;
}


@end

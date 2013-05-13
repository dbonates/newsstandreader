//
//  RevistasLayout.m
//  Teste
//
//  Created by Daniel Bonates on 5/3/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "MagazineRackLayout.h"
#import "MagazineRackShelfDecorationView.h"
//#import "SimpleShelf.h"
#import "MagazineRackViewController.h"
// [layout registerClass:NSClassFromString(self.uiCollectionReusableViewClassName) forDecorationViewOfKind:@"SimpleShelf"];

#define MARGIN_TOP 30
#define MARGIN_BOTTOM 30
#define LINE_SPACING 65
#define SHELF_Y 145.0
#define SHELF_HEIGHT 157.0
#define MARGIN_LATERAL 80


@interface MagazineRackLayout()

@property (nonatomic) CGSize itemSize;
@property (nonatomic) NSInteger minimunGapBetweenItems;
@property (nonatomic) NSInteger itemsCount;
@property (nonatomic) NSString *uiCollectionReusableViewClassName;
@property (nonatomic, strong) MagazineRackViewController *selfCollectionView;
@property (nonatomic, strong) NSDictionary *shelfRects;
@end

@implementation MagazineRackLayout

- (id)init
{
    self = [super init];
    if (self) {
        [self registerClass:NSClassFromString(@"MagazineRackShelfDecorationView") forDecorationViewOfKind:@"MagazineRackShelfDecorationView"];
       // [self registerClass:[MagazineRackShelfDecorationView class]
         //forDecorationViewOfKind:@"MagazineRackLayoutShelfDecorationView"];
    }
    
    return self;
}


- (void)setupWithItemSize:(CGSize)itemSize minimunGapBetweenItems:(NSInteger)minimunGapBetweenItems uiCollectionReusableViewClassName:(NSString *)uiCollectionReusableViewClassName
{
    /*
     
     Editar se for inserir uma header!
     
     */
    self.headerReferenceSize = CGSizeMake(0, 0); //[[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad? (CGSize){50, 50} : (CGSize){43, 43}; // 100

    self.itemSize = itemSize;
    self.minimunGapBetweenItems = minimunGapBetweenItems;
    self.uiCollectionReusableViewClassName = @"SimpleShelf";
    self.itemsCount = 4; // ignorable in for it will be overwritted by prepareForLayout
    
}

- (void)prepareLayout
{
    // call super so flow layout can do all the math for cells, headers, and footers
    [super prepareLayout];
    
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern5"]];
    _selfCollectionView = (MagazineRackViewController *)self.collectionView;

    self.itemSize = CGSizeMake(self.itemSize.width, self.itemSize.height);
    
//    float windowWidth = self.collectionView.bounds.size.width;
   
//    NSInteger itensOnColumn = windowWidth/self.itemSize.width;
//    wLOG(@"itensOnColumn: %d", itensOnColumn);
//    wLOG(@"self.itemsCount: %d", self.itemsCount);

    float lateralMarginInsect = MARGIN_LATERAL;
    float spaceBetweenItems = self.minimunGapBetweenItems;
    
    self.sectionInset = UIEdgeInsetsMake(MARGIN_TOP, lateralMarginInsect, MARGIN_BOTTOM, lateralMarginInsect);
    self.minimumLineSpacing = LINE_SPACING;
    self.minimumInteritemSpacing = spaceBetweenItems;
    
//    return;
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical)
    {
        // Calculate where shelves go in a vertical layout
        int sectionCount = [self.collectionView numberOfSections];
        
        CGFloat y = 0;
        CGFloat availableWidth = self.collectionViewContentSize.width - (self.sectionInset.left + self.sectionInset.right);
        int itemsAcross = floorf((availableWidth + self.minimumInteritemSpacing) / (self.itemSize.width + self.minimumInteritemSpacing));
        
        for (int section = 0; section < sectionCount; section++)
        {
            y += self.headerReferenceSize.height;
            y += self.sectionInset.top+24;
            
            int itemCount = [self.collectionView numberOfItemsInSection:section];
            iLOG(@"self.headerReferenceSize.height: %f", self.headerReferenceSize.height);
            int rows = ceilf(itemCount/(float)itemsAcross);
            for (int row = 0; row < rows; row++)
            {
                y += self.itemSize.height;
                dictionary[[NSIndexPath indexPathForItem:row inSection:section]] = [NSValue valueWithCGRect:CGRectMake(0, y-110, self.collectionViewContentSize.width, SHELF_HEIGHT)];
                
                if (row < rows - 1)
                    y += self.minimumLineSpacing;
            }
            
            y += self.sectionInset.bottom;
            y += self.footerReferenceSize.height;
        }
    }
    else
    {
        // Calculate where shelves go in a horizontal layout
        CGFloat y = self.sectionInset.top;
        CGFloat availableHeight = self.collectionViewContentSize.height - (self.sectionInset.top + self.sectionInset.bottom);
        int itemsAcross = floorf((availableHeight + self.minimumInteritemSpacing) / (self.itemSize.height + self.minimumInteritemSpacing));
        CGFloat interval = ((availableHeight - self.itemSize.height) / (itemsAcross <= 1? 1 : itemsAcross - 1)) - self.itemSize.height;
        for (int row = 0; row < itemsAcross; row++)
        {

            y += self.itemSize.height;
            dictionary[[NSIndexPath indexPathForItem:row inSection:0]] = [NSValue valueWithCGRect:CGRectMake(0, y-110, self.collectionViewContentSize.width, SHELF_HEIGHT)];
            
            y += interval;
        }
    }
    
    self.shelfRects = [NSDictionary dictionaryWithDictionary:dictionary];
    
    
}

// Return attributes of all items (cells, supplementary views, decoration views) that appear within this rect
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    // call super so flow layout can return default attributes for all cells, headers, and footers
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // Add our decoration views (shelves)
    NSMutableArray *newArray = [array mutableCopy];
    
    [self.shelfRects enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (CGRectIntersectsRect([obj CGRectValue], rect))
        {
            UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"MagazineRackShelfDecorationView" withIndexPath:key];
            attributes.frame = [obj CGRectValue];
            attributes.zIndex = -1;
            //attributes.alpha = 0.5; // screenshots
            [newArray addObject:attributes];
        }
    }];
    
    array = [NSArray arrayWithArray:newArray];
    
    return array;
}

// layout attributes for a specific decoration view
- (UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString *)decorationViewKind atIndexPath:(NSIndexPath *)indexPath
{
    id shelfRect = self.shelfRects[indexPath];
    if (!shelfRect)
        return nil; // no shelf at this index (this is probably an error)
    
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:@"MagazineRackShelfDecorationView" withIndexPath:indexPath];
    attributes.frame = [shelfRect CGRectValue];
    attributes.zIndex = 0; // shelves go behind other views
    
    return attributes;
}





@end
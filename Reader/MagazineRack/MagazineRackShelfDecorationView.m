//
//  MagazineRackShelfDecorationView.m
//  Reader
//
//  Created by  Basispress on 12/19/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineRackShelfDecorationView.h"

@implementation MagazineRackShelfDecorationView
{
    UIImageView *_shelfImageView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _shelfImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_shelfImageView];
        
        _shelfImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){

    }
    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    

    
    if (_shelfImageView.image.size.width == CGRectGetWidth(layoutAttributes.frame))
        return;
    
    UIImage *shelfImage;
    if (CGRectGetWidth(layoutAttributes.frame) == 768.0){
        shelfImage = [UIImage imageNamed:@"shelf"];
    }
    else if (CGRectGetWidth(layoutAttributes.frame) == 1024.0){
        shelfImage = [UIImage imageNamed:@"shelf_landscape"];
    }
    
    _shelfImageView.image = shelfImage;
}


@end

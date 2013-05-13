//
//  SimpleShelf.m
//  Teste
//
//  Created by Daniel Bonates on 5/3/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "SimpleShelf.h"

@interface SimpleShelf()
@property (nonatomic, strong) UIImageView *shelfImageView;
@property (nonatomic, strong) NSString *shelfImageString;
@end

@implementation SimpleShelf


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
//    self.backgroundColor = [UIColor colorWithRed:0.457 green:1.000 blue:0.369 alpha:1.000];
    self.shelfImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.shelfImageView.autoresizesSubviews = YES;
    self.shelfImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    wLOG(@"%@", NSStringFromCGRect(statusBarFrame));
    if (isPad) {
        
        switch (orientation) {
            case UIInterfaceOrientationPortraitUpsideDown:
                self.shelfImageView.image = [UIImage imageNamed:@"Shelf-iPad"];
                iLOG(@"Shelf-iPad");
                break;
            case UIInterfaceOrientationLandscapeLeft:
                self.shelfImageView.image = [UIImage imageNamed:@"Shelf-iPad-Landscape"];
                iLOG(@"Shelf-iPad-Landscape");
                break;
            case UIInterfaceOrientationLandscapeRight:
                self.shelfImageView.image = [UIImage imageNamed:@"Shelf-iPad-Landscape"];
                iLOG(@"Shelf-iPad-Landscape");
                break;
            default: // as UIInterfaceOrientationPortrait
                self.shelfImageView.image = [UIImage imageNamed:@"Shelf-iPad"];
                iLOG(@"Shelf-iPad (dafault)");
                break;
        }
        
    }
    else
    {
        self.shelfImageView.image = [UIImage imageNamed:@"Shelf-iPhone"];
    }
    [self addSubview:self.shelfImageView];
}

//- (BOOL)isPad
//{
//    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
//}


@end

//
//  MagazineRackCell.m
//  Reader
//
//  Created by  Basispress on 12/18/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineRackCell.h"
#import <QuartzCore/QuartzCore.h>
#import "IssueManager.h"
#import "InAppStore.h"
#import "UIImage+UIImage_DBImageBlender.h"
#import "YLProgressBar.h"

#define kMagazineRackCellShadowRadius               5.0
#define kMagazineRackCellShadowOffset               CGSizeMake(0,0)
#define kMagazineRackCellPageEffectNumberOfPages    4
#define KMagazineRackCellPageEffectPageWidth        1



#pragma mark - MagazineRackCellContentView
@interface MagazineRackCellContentView : UIView
@property (strong, nonatomic) UIImage *coverImage;
@property (strong, nonatomic) YLProgressBar *progressView;
@end

@implementation MagazineRackCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.progressView = [[YLProgressBar alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progressView.progressTintColor = [UIColor colorWithRed:0.000 green:0.528 blue:1.000 alpha:1.000];
        CGSize sizeForProgressBar = self.frame.size;
        sizeForProgressBar.width = sizeForProgressBar.width-30;
        [self.progressView sizeThatFits:sizeForProgressBar];
        self.progressView.center = CGPointMake(self.center.x-3, CGRectGetHeight(self.frame));
        [self addSubview:self.progressView];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize sizeForProgressBar = self.frame.size;
    sizeForProgressBar.width = sizeForProgressBar.width-30;
    [self.progressView sizeThatFits:sizeForProgressBar];
    
    [self.progressView sizeThatFits:sizeForProgressBar];
    self.progressView.frame = CGRectInset(self.progressView.frame, 15, 0);
    self.progressView.center = CGPointMake(self.center.x-3, CGRectGetHeight(self.frame) - CGRectGetHeight(self.progressView.frame) - 15);

}
- (void)drawRect:(CGRect)rect
{
    

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGSize shadowOffset = kMagazineRackCellShadowOffset;
    CGFloat shadowRadius = kMagazineRackCellShadowRadius;
    UIColor *shadowColor = [UIColor blackColor];
    UIImage *image = self.coverImage;
    CGContextSetShadowWithColor(ctx, shadowOffset, shadowRadius, shadowColor.CGColor);
    
    CGFloat top, bottom, left, right;
    top = bottom = left = right = 0;
    
    top = shadowOffset.height - shadowRadius;
    top = fabsf(top);
    left = shadowOffset.width - shadowRadius;
    left = fabsf(left);
    bottom = shadowOffset.height + shadowRadius;
    right = shadowOffset.width + shadowRadius;
    
    CGFloat x,y, width, height;
    
    x = CGRectGetMinX(rect) + top;
    x = ceilf(x);
    y = CGRectGetMinY(rect) + top;
    y = ceilf(y);
    width = CGRectGetWidth(rect) - left - right;
    width -= KMagazineRackCellPageEffectPageWidth * kMagazineRackCellPageEffectNumberOfPages;
    width = ceilf(width);
    height = CGRectGetHeight(rect) - top - bottom;
    height = ceilf(height);
    
    CGRect imageDrawRect = CGRectMake(x, y, width, height);
    
    [image drawInRect:imageDrawRect];
    /*
    for(NSUInteger effectIndex = 0; effectIndex < kMagazineRackCellPageEffectNumberOfPages; effectIndex++){
        CGRect fillRect = CGRectMake(CGRectGetMaxX(imageDrawRect) + effectIndex * KMagazineRackCellPageEffectPageWidth,
                                     CGRectGetMinY(imageDrawRect),
                                     KMagazineRackCellPageEffectPageWidth,
                                     CGRectGetHeight(imageDrawRect));
        if(effectIndex %2 == 0){
            [[UIColor whiteColor] setFill];
        }
        else{
            [[UIColor blackColor] setFill];
        }
        CGContextFillRect(ctx, fillRect);
    }*/
}
@end

#pragma mark - MagazineRackCell
@implementation MagazineRackCell
{
    MagazineRackCellContentView *_contentView;
    Issue *_issue;
    UIImageView *_imageView;
}

+ (CGSize)sizeWithImage:(UIImage*)image constrainedToHeight:(CGFloat)constraintHeight
{
    CGFloat width, height, ratio;
    CGSize drawSize;
    
    ratio = constraintHeight / image.size.height;
    
    height = image.size.height * ratio;
    height = roundf(height);
    
    width = image.size.width * ratio;
    width = roundf(width);
    
    width += KMagazineRackCellPageEffectPageWidth * kMagazineRackCellPageEffectNumberOfPages;
    
    drawSize = CGSizeMake(width, height);
    
    CGFloat minX, maxX, minY, maxY;
    minX = maxX = minY = maxY = 0;
    
    CGSize shadowOffset = kMagazineRackCellShadowOffset;
    CGFloat shadowRadius = kMagazineRackCellShadowRadius;
    
    minX = shadowOffset.width - shadowRadius;
    minX = minX < 0 ? minX : 0;
    
    minY = shadowOffset.height - shadowRadius;
    minY = minY < 0 ? minY : 0;
    
    maxX = drawSize.width + shadowOffset.width + shadowRadius;
    maxY = drawSize.height + shadowOffset.height + shadowRadius;
    
    width = maxX - minX;
    
    height = maxY - minY;
    return CGSizeMake(width, height);
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        _contentView = [[MagazineRackCellContentView alloc] initWithFrame:self.contentView.bounds];
        _contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _contentView.opaque = NO;
        _contentView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_contentView];
        
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserver:self
                   selector:@selector(progressChanged:)
                       name:IssueManagerProgressNotification
                     object:nil];

        _imageView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ribbon_download"]];
        [self addSubview:_imageView];
        
        [[InAppStore sharedInstance] addObserver:self
                                      forKeyPath:@"subscriptionState"
                                         options:NSKeyValueObservingOptionNew
                                         context:nil];
    }

    return self;
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    [_contentView setNeedsDisplay];
    _imageView.frame = CGRectOffset(_imageView.bounds, CGRectGetWidth(_contentView.frame) - CGRectGetWidth(_imageView.frame) - 40, 2);
    
}

- (void)setIssue:(Issue *)issue
{
    if (_issue != issue) {
        [_issue removeObserver:self forKeyPath:@"downloadingValue"];
        [_issue removeObserver:self forKeyPath:@"newValue"];
        [_issue removeObserver:self forKeyPath:@"purchasedValue"];
        [self willChangeValueForKey:@"issue"];
        _issue = issue;
        Asset *coverImageAsset = _issue.coverImage[0];
        NSString *coverImagePath = coverImageAsset.filePath;
        UIImage *coverImage = [[UIImage alloc] initWithContentsOfFile:coverImagePath];
        UIImage *beatifullOne = [UIImage
                                 blendOverlay:coverImage
                                 withBaseImage:[UIImage imageNamed:@"magazine_mockup_base"]
                                 highlightImage:[UIImage imageNamed:@"magazine_mockup_reflexo"]
                                 highlightMode:kCGBlendModeLighten
                                 usehighlight:YES
                                 currentCoverXoffset:75
                                 currentCoverYoffset:2
                                 currentHighlightXoffset:75
                                 currentHighlightYoffset:2
                                 ];
        _contentView.coverImage = beatifullOne;
        _contentView.progressView.hidden  = !issue.downloadingValue;
        
        [_issue addObserver:self
                 forKeyPath:@"downloadingValue"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        [_issue addObserver:self
                 forKeyPath:@"newValue"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        [_issue addObserver:self
                 forKeyPath:@"purchasedValue"
                    options:NSKeyValueObservingOptionNew
                    context:nil];
        
        [_contentView setNeedsDisplay];
        [self updateUI];
        [self didChangeValueForKey:@"issue"];
        

    }
}

- (void)updateUI
{
    if (!_issue.purchasedValue && [InAppStore sharedInstance].subscriptionState != SubscriptionStateSubscribed && !_issue.freeValue){
        [_imageView setImage:[UIImage imageNamed:@"ribbon_buy"]];
        _imageView.hidden = NO;
    }
    
    if ([InAppStore sharedInstance].subscriptionState == SubscriptionStateSubscribed || _issue.freeValue)
    {
        _imageView.hidden = NO;
        [_imageView setImage:[UIImage imageNamed:@"ribbon_download"]];
    }
    
    if (_issue.stateValue == IssueStateReadyForReading || _issue.downloadingValue == YES) {
        [_imageView setImage:nil];
        _imageView.hidden = YES;
    }
    
    if (_issue.newValue) {
        _imageView.hidden = NO;
        [_imageView setImage:[UIImage imageNamed:@"ribbon_new"]];
    }

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"downloadingValue"]) {
        _contentView.progressView.hidden = !self.issue.downloadingValue;
        _contentView.progressView.progress = 0.0;
    }
    [self updateUI];
}

- (void)progressChanged:(NSNotification*)aNotification
{
    Asset *asset = aNotification.userInfo[@"asset"];
    if ([asset.issue isEqual:self.issue]) {
        float progress = [aNotification.userInfo[@"progress"] floatValue];
        [_contentView.progressView setProgress:progress];
    }
    else {
        [_contentView.progressView setProgress:0];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
}
@end

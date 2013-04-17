//
//  MagazineRackRenderer.m
//  Reader
//
//  Created by  Basispress on 12/20/12.
//  Copyright (c) 2012 Basispress. All rights reserved.
//

#import "MagazineRackRenderer.h"
@interface MagazineRackRendererResult()
{
    UIImage *_image;
    CGRect _contentRect;
}
- (id)initWithImage:(UIImage*)image contentRect:(CGRect)contentRect;
@end

@implementation MagazineRackRendererResult
@synthesize image = _image;
@synthesize contentRect = _contentRect;

- (id)initWithImage:(UIImage *)image contentRect:(CGRect)contentRect
{
    self = [super init];
    if (self){
        _image = image;
        _contentRect = contentRect;
    }
    return self;
}
@end
@implementation MagazineRackRenderer


- (MagazineRackRendererResult*)renderImage:(UIImage*)image constrainedToHeight:(CGFloat)constraintHeight
{
    CGFloat imageWidth, imageHeight, imageScale;
    
    imageScale = constraintHeight / image.size.height;
    
    imageWidth = image.size.width * imageScale;
    imageWidth = roundf(imageWidth);
    
    imageHeight = image.size.height * imageScale;
    imageHeight = roundf(imageHeight);
    
    
    CGFloat drawWidth, drawHeight;
    
    drawWidth = imageWidth + self.pageWidth * self.numberOfPages;
    drawHeight = imageHeight;
    

    CGFloat shadowMinX, shadowMinY, shadowMaxX, shadowMaxY;
    
    shadowMinX = self.shadowOffset.width - self.shadowRadius;
    shadowMinY = self.shadowOffset.height - self.shadowRadius;
    shadowMaxX = drawWidth + self.shadowOffset.width + self.shadowRadius;
    shadowMaxY = drawHeight + self.shadowOffset.height + self.shadowRadius;
    
    
    CGFloat resultMinX, resultMinY, resultMaxX, resultMaxY;
    
    resultMinX = shadowMinX < 0.0 ? shadowMinX : 0.0;
    resultMinY = shadowMinY < 0.0 ? shadowMinY : 0.0;
    resultMaxX = shadowMaxX > drawWidth ? shadowMaxX : drawWidth;
    resultMaxY = shadowMaxY > drawHeight ? shadowMaxY : drawHeight;
    
    CGFloat resultWidth, resultHeight;

    resultWidth = resultMaxX - resultMinX;
    resultHeight = resultMaxY - resultMinY;
    
    resultWidth *= self.scale;
    resultHeight *= self.scale;
    
    CGContextRef ctx;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    ctx = CGBitmapContextCreate(NULL,
                                resultWidth,
                                resultHeight,
                                8,
                                0,
                                colorSpace,
                                kCGImageAlphaPremultipliedLast);
    
    
    CGContextScaleCTM(ctx, self.scale, self.scale);
    
    CGFloat xOffset, yOffset;
    
    xOffset = fabsf(resultMinX);
    yOffset = fabsf(resultMinY);
    
    CGContextSetShadow(ctx, self.shadowOffset, self.shadowRadius);
    
    CGRect imageDrawRect = CGRectMake(xOffset, yOffset, imageWidth, imageHeight);
    
    CGContextDrawImage(ctx, imageDrawRect, image.CGImage);

    for(NSUInteger effectIndex = 0; effectIndex < self.numberOfPages; effectIndex++){
        
        CGRect fillRect = CGRectMake(CGRectGetMaxX(imageDrawRect) + effectIndex * self.pageWidth,
                                     CGRectGetMinY(imageDrawRect),
                                     self.pageWidth,
                                     CGRectGetHeight(imageDrawRect));
        if(effectIndex %2 == 0){
            CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        }
        else{
            CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
        }
        CGContextFillRect(ctx, fillRect);
    }

    CGImageRef resultCGImage = CGBitmapContextCreateImage(ctx);
    
    UIImage *resultImage = [UIImage imageWithCGImage:resultCGImage scale:self.scale orientation:UIImageOrientationUp];
    
    CGContextRelease(ctx);
    CGImageRelease(resultCGImage);
    CGColorSpaceRelease(colorSpace);
    
    
    
    return [[MagazineRackRendererResult alloc] initWithImage:resultImage contentRect:imageDrawRect];
}
@end

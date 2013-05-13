//
//  SimpleCell.m
//  Teste
//
//  Created by Daniel Bonates on 5/3/13.
//  Copyright (c) 2013 Daniel Bonates. All rights reserved.
//

#import "SimpleCell.h"

@interface SimpleCell ()
@property (nonatomic, strong) UIImageView *coverImageView;
@end

@implementation SimpleCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        wLOG(@"hflkjsadhfklasdjfhasdlkjfh");
        self.coverImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.coverImageView.autoresizesSubviews = YES;
        self.coverImageView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
        [self addSubview:self.coverImageView];

        
    }
    return self;
}

- (void)defaultSetup
{
    [self.coverImageView setImage:[UIImage imageNamed:@"cover-placeholder"]];
}

@end

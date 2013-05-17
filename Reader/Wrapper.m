//
//  Wrapper.m
//  Reader
//
//  Created by Daniel Bonates on 5/14/13.
//  Copyright (c) 2013 Bonates. All rights reserved.
//

#import "Wrapper.h"

@implementation Wrapper

+ (Wrapper *)sharedInstance
{
    static dispatch_once_t onceToken;
    static Wrapper  *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

@end

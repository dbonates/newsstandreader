//
//  NSManagedObjectContext+MagicalThreading.h
//  Magical Record
//
//  Created by Basispress on 3/9/12.
//  Copyright (c) 2012 Magical Panda Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (MagicalThreading)

+ (NSManagedObjectContext *) MR_contextForCurrentThread;
+ (void) MR_resetContextForCurrentThread;

@end

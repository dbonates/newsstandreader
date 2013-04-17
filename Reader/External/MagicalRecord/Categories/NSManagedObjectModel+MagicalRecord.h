//
//  NSManagedObjectModel+MagicalRecord.h
//
//  Created by Basispress on 3/11/10.
//  Copyright Basispress All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MagicalRecord.h"


@interface NSManagedObjectModel (MagicalRecord)

+ (NSManagedObjectModel *) MR_defaultManagedObjectModel;

+ (void) MR_setDefaultManagedObjectModel:(NSManagedObjectModel *)newDefaultModel;

+ (NSManagedObjectModel *) MR_mergedObjectModelFromMainBundle;
+ (NSManagedObjectModel *) MR_newManagedObjectModelNamed:(NSString *)modelFileName NS_RETURNS_RETAINED;
+ (NSManagedObjectModel *) MR_managedObjectModelNamed:(NSString *)modelFileName;
+ (NSManagedObjectModel *) MR_newModelNamed:(NSString *) modelName inBundleNamed:(NSString *) bundleName NS_RETURNS_RETAINED;

@end

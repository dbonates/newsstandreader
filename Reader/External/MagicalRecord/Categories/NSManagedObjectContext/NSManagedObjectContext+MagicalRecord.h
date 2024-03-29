//
//  NSManagedObjectContext+MagicalRecord.h
//
//  Created by Basispress on 11/23/09.
//  Copyright Basispress All rights reserved.
//

#import "MagicalRecord.h"

extern NSString * const kMagicalRecordDidMergeChangesFromiCloudNotification;

@interface NSManagedObjectContext (MagicalRecord)

+ (void) MR_initializeDefaultContextWithCoordinator:(NSPersistentStoreCoordinator *)coordinator;

+ (NSManagedObjectContext *) MR_context NS_RETURNS_RETAINED;
+ (NSManagedObjectContext *) MR_contextWithParent:(NSManagedObjectContext *)parentContext NS_RETURNS_RETAINED;
+ (NSManagedObjectContext *) MR_newMainQueueContext NS_RETURNS_RETAINED;
+ (NSManagedObjectContext *) MR_contextWithStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator NS_RETURNS_RETAINED;

+ (void) MR_resetDefaultContext;
+ (NSManagedObjectContext *) MR_rootSavingContext;
+ (NSManagedObjectContext *) MR_defaultContext;

- (NSString *) MR_description;
- (NSString *) MR_parentChain;

@property (nonatomic, copy, setter = MR_setWorkingName:) NSString *MR_workingName;

@end

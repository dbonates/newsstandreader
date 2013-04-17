// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Asset.m instead.

#import "_Asset.h"

const struct AssetAttributes AssetAttributes = {
	.downloaded = @"downloaded",
	.filePath = @"filePath",
	.orderIndex = @"orderIndex",
	.type = @"type",
	.url = @"url",
};

const struct AssetRelationships AssetRelationships = {
	.issue = @"issue",
};

const struct AssetFetchedProperties AssetFetchedProperties = {
};

@implementation AssetID
@end

@implementation _Asset

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Asset" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Asset";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Asset" inManagedObjectContext:moc_];
}

- (AssetID*)objectID {
	return (AssetID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"downloadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"orderIndexValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"orderIndex"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic downloaded;



- (BOOL)downloadedValue {
	NSNumber *result = [self downloaded];
	return [result boolValue];
}

- (void)setDownloadedValue:(BOOL)value_ {
	[self setDownloaded:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDownloadedValue {
	NSNumber *result = [self primitiveDownloaded];
	return [result boolValue];
}

- (void)setPrimitiveDownloadedValue:(BOOL)value_ {
	[self setPrimitiveDownloaded:[NSNumber numberWithBool:value_]];
}





@dynamic filePath;






@dynamic orderIndex;



- (int16_t)orderIndexValue {
	NSNumber *result = [self orderIndex];
	return [result shortValue];
}

- (void)setOrderIndexValue:(int16_t)value_ {
	[self setOrderIndex:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveOrderIndexValue {
	NSNumber *result = [self primitiveOrderIndex];
	return [result shortValue];
}

- (void)setPrimitiveOrderIndexValue:(int16_t)value_ {
	[self setPrimitiveOrderIndex:[NSNumber numberWithShort:value_]];
}





@dynamic type;






@dynamic url;






@dynamic issue;

	






@end

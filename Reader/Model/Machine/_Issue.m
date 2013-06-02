// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Issue.m instead.

#import "_Issue.h"

const struct IssueAttributes IssueAttributes = {
	.date = @"date",
	.downloaded = @"downloaded",
	.downloading = @"downloading",
	.free = @"free",
    .position = @"position",
	.issueDescription = @"issueDescription",
	.name = @"name",
	.new = @"new",
	.productIdentifier = @"productIdentifier",
	.purchased = @"purchased",
	.receiptData = @"receiptData",
	.state = @"state",
	.toc = @"toc",
};

const struct IssueRelationships IssueRelationships = {
	.assets = @"assets",
};

const struct IssueFetchedProperties IssueFetchedProperties = {
	.coverImage = @"coverImage",
	.previews = @"previews",
};

@implementation IssueID
@end

@implementation _Issue

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Issue" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Issue";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Issue" inManagedObjectContext:moc_];
}

- (IssueID*)objectID {
	return (IssueID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"downloadedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloaded"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"downloadingValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"downloading"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"freeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"free"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
    if ([key isEqualToString:@"positionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"position"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"newValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"new"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"purchasedValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"purchased"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"stateValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"state"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic date;






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





@dynamic downloading;



- (BOOL)downloadingValue {
	NSNumber *result = [self downloading];
	return [result boolValue];
}

- (void)setDownloadingValue:(BOOL)value_ {
	[self setDownloading:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDownloadingValue {
	NSNumber *result = [self primitiveDownloading];
	return [result boolValue];
}

- (void)setPrimitiveDownloadingValue:(BOOL)value_ {
	[self setPrimitiveDownloading:[NSNumber numberWithBool:value_]];
}





@dynamic free;



- (BOOL)freeValue {
	NSNumber *result = [self free];
	return [result boolValue];
}

- (void)setFreeValue:(BOOL)value_ {
	[self setFree:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveFreeValue {
	NSNumber *result = [self primitiveFree];
	return [result boolValue];
}

- (void)setPrimitiveFreeValue:(BOOL)value_ {
	[self setPrimitiveFree:[NSNumber numberWithBool:value_]];
}





@dynamic position;



- (int32_t)positionValue {
	NSNumber *result = [self position];
	return [result intValue];
}

- (void)setPositionValue:(int32_t)value_ {
	[self setPosition:[NSNumber numberWithInt:value_]];
}

- (int32_t)primitivePositionValue {
	NSNumber *result = [self primitivePosition];
	return [result intValue];
}

- (void)setPrimitivePositionValue:(int32_t)value_ {
	[self setPrimitivePositionValue:[NSNumber numberWithInt:value_]];
}
/*
 - (int16_t)stateValue {
 NSNumber *result = [self state];
 return [result shortValue];
 }
 
 - (void)setStateValue:(int16_t)value_ {
 [self setState:[NSNumber numberWithShort:value_]];
 }
 
 - (int16_t)primitiveStateValue {
 NSNumber *result = [self primitiveState];
 return [result shortValue];
 }
 
 - (void)setPrimitiveStateValue:(int16_t)value_ {
 [self setPrimitiveState:[NSNumber numberWithShort:value_]];
 }
 */




@dynamic issueDescription;






@dynamic name;






@dynamic new;



- (BOOL)newValue {
	NSNumber *result = [self new];
	return [result boolValue];
}

- (void)setNewValue:(BOOL)value_ {
	[self setNew:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveNewValue {
	NSNumber *result = [self primitiveNew];
	return [result boolValue];
}

- (void)setPrimitiveNewValue:(BOOL)value_ {
	[self setPrimitiveNew:[NSNumber numberWithBool:value_]];
}





@dynamic productIdentifier;






@dynamic purchased;



- (BOOL)purchasedValue {
	NSNumber *result = [self purchased];
	return [result boolValue];
}

- (void)setPurchasedValue:(BOOL)value_ {
	[self setPurchased:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitivePurchasedValue {
	NSNumber *result = [self primitivePurchased];
	return [result boolValue];
}

- (void)setPrimitivePurchasedValue:(BOOL)value_ {
	[self setPrimitivePurchased:[NSNumber numberWithBool:value_]];
}





@dynamic receiptData;






@dynamic state;



- (int16_t)stateValue {
	NSNumber *result = [self state];
	return [result shortValue];
}

- (void)setStateValue:(int16_t)value_ {
	[self setState:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveStateValue {
	NSNumber *result = [self primitiveState];
	return [result shortValue];
}

- (void)setPrimitiveStateValue:(int16_t)value_ {
	[self setPrimitiveState:[NSNumber numberWithShort:value_]];
}





@dynamic toc;






@dynamic assets;

	
- (NSMutableSet*)assetsSet {
	[self willAccessValueForKey:@"assets"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"assets"];
  
	[self didAccessValueForKey:@"assets"];
	return result;
}
	



@dynamic coverImage;

@dynamic previews;




@end

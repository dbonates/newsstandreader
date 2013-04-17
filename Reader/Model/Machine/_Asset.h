// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Asset.h instead.

#import <CoreData/CoreData.h>


extern const struct AssetAttributes {
	__unsafe_unretained NSString *downloaded;
	__unsafe_unretained NSString *filePath;
	__unsafe_unretained NSString *orderIndex;
	__unsafe_unretained NSString *type;
	__unsafe_unretained NSString *url;
} AssetAttributes;

extern const struct AssetRelationships {
	__unsafe_unretained NSString *issue;
} AssetRelationships;

extern const struct AssetFetchedProperties {
} AssetFetchedProperties;

@class Issue;







@interface AssetID : NSManagedObjectID {}
@end

@interface _Asset : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (AssetID*)objectID;




@property (nonatomic, strong) NSNumber* downloaded;


@property BOOL downloadedValue;
- (BOOL)downloadedValue;
- (void)setDownloadedValue:(BOOL)value_;

//- (BOOL)validateDownloaded:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* filePath;


//- (BOOL)validateFilePath:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* orderIndex;


@property int16_t orderIndexValue;
- (int16_t)orderIndexValue;
- (void)setOrderIndexValue:(int16_t)value_;

//- (BOOL)validateOrderIndex:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* type;


//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* url;


//- (BOOL)validateUrl:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) Issue* issue;

//- (BOOL)validateIssue:(id*)value_ error:(NSError**)error_;





@end

@interface _Asset (CoreDataGeneratedAccessors)

@end

@interface _Asset (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveDownloaded;
- (void)setPrimitiveDownloaded:(NSNumber*)value;

- (BOOL)primitiveDownloadedValue;
- (void)setPrimitiveDownloadedValue:(BOOL)value_;




- (NSString*)primitiveFilePath;
- (void)setPrimitiveFilePath:(NSString*)value;




- (NSNumber*)primitiveOrderIndex;
- (void)setPrimitiveOrderIndex:(NSNumber*)value;

- (int16_t)primitiveOrderIndexValue;
- (void)setPrimitiveOrderIndexValue:(int16_t)value_;




- (NSString*)primitiveType;
- (void)setPrimitiveType:(NSString*)value;




- (NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(NSString*)value;





- (Issue*)primitiveIssue;
- (void)setPrimitiveIssue:(Issue*)value;


@end

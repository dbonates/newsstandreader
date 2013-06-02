// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Issue.h instead.

#import <CoreData/CoreData.h>


extern const struct IssueAttributes {
	__unsafe_unretained NSString *date;
	__unsafe_unretained NSString *downloaded;
	__unsafe_unretained NSString *downloading;
	__unsafe_unretained NSString *free;
    __unsafe_unretained NSString *position;
	__unsafe_unretained NSString *issueDescription;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *new;
	__unsafe_unretained NSString *productIdentifier;
	__unsafe_unretained NSString *purchased;
	__unsafe_unretained NSString *receiptData;
	__unsafe_unretained NSString *state;
	__unsafe_unretained NSString *toc;
} IssueAttributes;

extern const struct IssueRelationships {
	__unsafe_unretained NSString *assets;
} IssueRelationships;

extern const struct IssueFetchedProperties {
	__unsafe_unretained NSString *coverImage;
	__unsafe_unretained NSString *previews;
} IssueFetchedProperties;

@class Asset;














@interface IssueID : NSManagedObjectID {}
@end

@interface _Issue : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (IssueID*)objectID;




@property (nonatomic, strong) NSDate* date;


//- (BOOL)validateDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* downloaded;


@property BOOL downloadedValue;
- (BOOL)downloadedValue;
- (void)setDownloadedValue:(BOOL)value_;

//- (BOOL)validateDownloaded:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* downloading;


@property BOOL downloadingValue;
- (BOOL)downloadingValue;
- (void)setDownloadingValue:(BOOL)value_;

//- (BOOL)validateDownloading:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* free;


@property BOOL freeValue;
- (BOOL)freeValue;
- (void)setFreeValue:(BOOL)value_;

//- (BOOL)validateFree:(id*)value_ error:(NSError**)error_;


@property (nonatomic, strong) NSNumber *position;


@property int32_t positionValue;
- (int32_t)positionValue;
- (void)setPositionValue:(int32_t)value_;

//- (BOOL)validatePosition:(id*)value_ error:(NSError**)error_;






@property (nonatomic, strong) NSString* issueDescription;


//- (BOOL)validateIssueDescription:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* new;


@property BOOL newValue;
- (BOOL)newValue;
- (void)setNewValue:(BOOL)value_;

//- (BOOL)validateNew:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* productIdentifier;


//- (BOOL)validateProductIdentifier:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* purchased;


@property BOOL purchasedValue;
- (BOOL)purchasedValue;
- (void)setPurchasedValue:(BOOL)value_;

//- (BOOL)validatePurchased:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSData* receiptData;


//- (BOOL)validateReceiptData:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSNumber* state;


@property int16_t stateValue;
- (int16_t)stateValue;
- (void)setStateValue:(int16_t)value_;

//- (BOOL)validateState:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSString* toc;


//- (BOOL)validateToc:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet* assets;

- (NSMutableSet*)assetsSet;




@property (nonatomic, readonly) NSArray *coverImage;

@property (nonatomic, readonly) NSArray *previews;


@end

@interface _Issue (CoreDataGeneratedAccessors)

- (void)addAssets:(NSSet*)value_;
- (void)removeAssets:(NSSet*)value_;
- (void)addAssetsObject:(Asset*)value_;
- (void)removeAssetsObject:(Asset*)value_;

@end

@interface _Issue (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveDate;
- (void)setPrimitiveDate:(NSDate*)value;




- (NSNumber*)primitiveDownloaded;
- (void)setPrimitiveDownloaded:(NSNumber*)value;

- (BOOL)primitiveDownloadedValue;
- (void)setPrimitiveDownloadedValue:(BOOL)value_;




- (NSNumber*)primitiveDownloading;
- (void)setPrimitiveDownloading:(NSNumber*)value;

- (BOOL)primitiveDownloadingValue;
- (void)setPrimitiveDownloadingValue:(BOOL)value_;




- (NSNumber*)primitiveFree;
- (void)setPrimitiveFree:(NSNumber*)value;

- (BOOL)primitiveFreeValue;
- (void)setPrimitiveFreeValue:(BOOL)value_;




- (NSNumber*)primitivePosition;
- (void)setPrimitivePosition:(NSNumber*)value;

- (NSInteger)primitivePositionValue;
- (void)setPrimitivePositionValue:(NSInteger)value_;





- (NSString*)primitiveIssueDescription;
- (void)setPrimitiveIssueDescription:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveNew;
- (void)setPrimitiveNew:(NSNumber*)value;

- (BOOL)primitiveNewValue;
- (void)setPrimitiveNewValue:(BOOL)value_;




- (NSString*)primitiveProductIdentifier;
- (void)setPrimitiveProductIdentifier:(NSString*)value;




- (NSNumber*)primitivePurchased;
- (void)setPrimitivePurchased:(NSNumber*)value;

- (BOOL)primitivePurchasedValue;
- (void)setPrimitivePurchasedValue:(BOOL)value_;




- (NSData*)primitiveReceiptData;
- (void)setPrimitiveReceiptData:(NSData*)value;




- (NSNumber*)primitiveState;
- (void)setPrimitiveState:(NSNumber*)value;

- (int16_t)primitiveStateValue;
- (void)setPrimitiveStateValue:(int16_t)value_;




- (NSString*)primitiveToc;
- (void)setPrimitiveToc:(NSString*)value;





- (NSMutableSet*)primitiveAssets;
- (void)setPrimitiveAssets:(NSMutableSet*)value;


@end

//
//  GiphyBasicDataManager.m
//  GiphyTest
//
//  Created by Russel on 14.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyBasicDataManager.h"

NSString * const kGiphyDataManagerBasicCollectionName = @"_GiphyCollection";

/**
 *  Maximal objects count collection may contain.
 */
const NSInteger kGiphyDataManagerMaxObjectsInCollection = 20;

@interface GiphyBasicDataManager ()

/**
 *  Dictionary to store local collection copies.
 */
@property(nonatomic)NSCache *collectionsCache;

#pragma mark - Private

/**
 *  Builds key to access to store.
 *  @param collectionName   Collection name to build store key for.
 */
- (NSString*)dataStoreKeyForCollectionName:(NSString*)collectionName;

/**
 *  Fetch object list for collection.
 *  @param collectionName Collection's name to extract objects for.
 *  @discussion If collection list is not already in cache that it fetches from disk and is saved to cache
 *              before returning. If collection doesn't exists empty one will be created.
 */
- (NSMutableArray*)collectionForName:(NSString*)collectionName;

/**
 *  Saves collection objects list from cache to disk.
 *  @param collectionName   Collection's name to save to disk.
 */
- (void)saveCollectionForName:(NSString*)collectionName;

@end

@implementation GiphyBasicDataManager

#pragma mark - Initialize

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static GiphyBasicDataManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[GiphyBasicDataManager alloc] init];
    });
    return sharedManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _collectionsCache = [[NSCache alloc] init];
        _collectionsCache.name = @"com.giphy.basicmanager";
    }
    return self;
}

#pragma mark - Data Store Protocol

- (void)addObject:(id<NSCoding,NSCopying>)object forCollection:(NSString *)collectionName{
    NSAssert(object, @"Object must not be nil");
    NSAssert(collectionName, @"Collection must not be nil");
    
    // extract objects list for collection
    NSMutableArray *objectsForCollection = [self collectionForName:collectionName];
    
    // remove previous object version and insert new one to the begining.
    NSUInteger indexForObject = [objectsForCollection indexOfObject:object];
    if (indexForObject != NSNotFound) {
        [objectsForCollection removeObjectAtIndex:indexForObject];
    }
    
    [objectsForCollection insertObject:object atIndex:0];
    
    // cut last objects if out of limits
    if ([objectsForCollection count] > kGiphyDataManagerMaxObjectsInCollection) {
        [objectsForCollection removeObjectsInRange:NSMakeRange(kGiphyDataManagerMaxObjectsInCollection, [objectsForCollection count] - kGiphyDataManagerMaxObjectsInCollection)];
    }
    
    // save changed list
    [self saveCollectionForName:collectionName];
}

- (void)removeObject:(id<NSCoding,NSCopying>)object forCollection:(NSString *)collectionName{
    NSAssert(object, @"Object must not be nil");
    NSAssert(collectionName, @"Collection must not be nil");
    
    // extract objects list for collection
    NSMutableArray *objectsForCollection = [self collectionForName:collectionName];
    
    if (objectsForCollection) {
        // remove object if contained in list and save
        NSUInteger indexForObject = [objectsForCollection indexOfObject:object];
        
        if (indexForObject != NSNotFound) {
            [objectsForCollection removeObjectAtIndex:indexForObject];
            [self saveCollectionForName:collectionName];
        }
    }
}

- (BOOL)containsObject:(id<NSCopying,NSCopying>)object forCollection:(NSString *)collectionName{
    NSAssert(object, @"Object must not be nil");
    NSAssert(collectionName, @"Collection must not be nil");
    
    // extract objects list in collection
    NSArray *objectsForCollection = [self collectionForName:collectionName];
    
    // check if list contains object
    return [objectsForCollection containsObject:object];
}

- (NSArray*)fetchObjectsFromCollection:(NSString *)collectionName{
    NSAssert(collectionName, @"Collection must not be nil");
    
    // extract objects list for collection
    return [self collectionForName:collectionName];
}

- (void)removeAllObjectsFromCollection:(NSString *)collectionName{
    NSAssert(collectionName, @"Collection must not be nil");
    
    // extract objects list for collection
    NSMutableArray *objectsForCollection = [self collectionForName:collectionName];
    
    // remove all objects from the list
    [objectsForCollection removeAllObjects];
    
    // save collection
    [self saveCollectionForName:collectionName];
}

#pragma mark - Private

- (NSString*)dataStoreKeyForCollectionName:(NSString*)collectionName{
    return [NSString stringWithFormat:@"%@_%@",kGiphyDataManagerBasicCollectionName, collectionName];
}

- (NSMutableArray*)collectionForName:(NSString*)collectionName{
    // try to extract objects list for collection from the cache
    NSMutableArray *collectionObjects = [_collectionsCache objectForKey:collectionName];
    
    if (!collectionObjects) {
        // extract collection data from disk and unarchive
        NSData *collectionData = [[NSUserDefaults standardUserDefaults] dataForKey:[self dataStoreKeyForCollectionName:collectionName]];
        if (collectionData) {
            collectionObjects = [[NSKeyedUnarchiver unarchiveObjectWithData:collectionData] mutableCopy];
        }else{
            // create empty collection if it doesn't exists
            collectionObjects = [NSMutableArray array];
        }
        
        // save collection to cache
        [_collectionsCache setObject:collectionObjects forKey:collectionName];
    }
    
    return collectionObjects;
}

- (void)saveCollectionForName:(NSString*)collectionName{
    // archive collection and save to disk
    NSMutableArray *collectionObjects = [_collectionsCache objectForKey:collectionName];
    if (collectionObjects) {
        NSData *collectionData = [NSKeyedArchiver archivedDataWithRootObject:collectionObjects];
        [[NSUserDefaults standardUserDefaults] setObject:collectionData forKey:[self dataStoreKeyForCollectionName:collectionName]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end

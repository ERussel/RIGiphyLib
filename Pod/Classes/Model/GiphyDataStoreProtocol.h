//
//  GiphyDataStoreProtocol.h
//  GiphyTest
//
//  Created by Russel on 14.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Protocol designed to provide interface to store
 *  user created data (such as search request).
 *  Object should be conformed to NSCoding protocol for serialization purpose
 *  and to NSCopying protocol. Objects divided by sets (collections) with unique name.
 */

@protocol GiphyDataStoreProtocol <NSObject>

/**
 *  Saves object to data store.
 *  @param object          Object to add to data store. Must not be nil.
 *  @param collectionName  Set's name to add object to. Must not be nil.
 */
- (void)addObject:(id<NSCoding, NSCopying>)object forCollection:(NSString*)collectionName;

/**
 *  Removes object from data store.
 *  @param object           Object to remove from data store. Must not be nil.
 *  @param collectionName   Set's name object belongs to. Must not be nil.
 */
- (void)removeObject:(id<NSCoding, NSCopying>)object forCollection:(NSString*)collectionName;

/**
 *  Checks whether data store contains object in given collection.
 *  @param object           Object to search in data store.
 *  @param collectionName   Set's name object containing in.
 *  @return YES if collection contains object, otherwise NO.
 */
- (BOOL)containsObject:(id<NSCopying, NSCopying>)object forCollection:(NSString*)collectionName;

/**
 *  Retrives all objects corresponding to collection.
 *  @param collectionName   Set's name to extract objects from. Must not be nil.
 *  @param NSArray of fetched objects. If there is no objects in collection empty array would be returned.
 */
- (NSArray*)fetchObjectsFromCollection:(NSString*)collectionName;

/**
 *  Removes all objects from given collection.
 *  @param collectionName   Set's name to remove objects from. Must not be nil.
 */
- (void)removeAllObjectsFromCollection:(NSString*)collectionName;

/**
 *  Destroys any memory stored data.
 *  @discussion Call this method to force memory freeing.
 */
- (void)clearCachedMemoryData;

@end

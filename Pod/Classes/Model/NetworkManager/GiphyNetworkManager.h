//
//  GiphyNetworkManager.h
//  GiphyTest
//
//  Created by Aft3rmath on 28.07.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AFNetworking/AFNetworking.h>
#import "GiphyObjectCacheProtocol.h"
#import "GiphyNetworkActivityProtocol.h"
#import "FLAnimatedImage.h"
#import "GiphyRequest.h"
#import "GiphyGIFObject.h"
#import "GiphyCategoryObject.h"
#import "GiphyTranslationResult.h"
#import "GiphyNetworkManagerConfiguration.h"

/**
 *  Notification name to post when manager completes still downloading operation.
 */
extern NSString * const GiphyNetworkManagerDidDownloadStillNotification;

/**
 *  Notification name to post when manager completes GIF downloading operation.
 */
extern NSString * const GiphyNetworkManagerDidDownloadGIFNotification;

/**
 *  Key corresponding to loaded object (GIF or still) to extract from notification's user info.
 */
extern NSString * const kGiphyNetworkManagerRecievedObjectKey;

/**
 *  Key corresponding to loaded object's url (GIF or still) to extract from notification's user info.
 */
extern NSString * const kGiphyNetworkManagerRecievedObjectURLKey;

/**
 *  Type describes how gifs search should work.
 */

typedef enum {
    /**
     *  Return gifs by searching inside its' description.
     */
    kGiphySearchTypeDescription,
    
    /**
     *  Return gifs by translating search phrase to gif content.
     */
    kGiphySearchTypeContent
}GiphySearchType;

/**
 *  Request type to group by.
 */
typedef enum{
    /**
     *  All request except provided below.
     */
    kGiphyRequestTypeDefault,
    
    /**
     *  Still downloading requests
     */
    kGiphyRequestTypeStill,
    
    /**
     *  GIF downloading requests
     */
    kGiphyRequestTypeGIF
}GiphyRequestType;

/**
 *  Defines cache settings for request.
 */
typedef enum {
    /**
     *  Perform request only if there is no corresponding response in cache
     */
    kGiphyRequestCachePolicyReturnCachedElseLoad,
    
    /**
     *  Perform request ignoring correponding cache request.
     */
    kGiphyRequestCachePolicyReloadIgnoringCache
}GiphyRequestCachePolicy;

/**
 *  Subclass of NSObject designed to provide servers interaction logic.
 */
@interface GiphyNetworkManager : NSObject

#pragma mark - Initialize

/**
 *  Checks whether network manager initialized
 */
+ (BOOL)isInitialized;

/**
 *  Initializes singletone with Parse server configurations
 *  @param config   Configuration object to setup connection to Parse server
 *  @return GiphyNetworkManager singletone.
 */
+ (instancetype)initializeWithConfiguration:(GiphyNetworkManagerConfiguration*)config;

/**
 *  @return Shared network manager.
 */
+ (instancetype) sharedManager;

#pragma mark - Giphy Network Manager

/**
 *  Cache to store response objects.
 */
@property(nonatomic)id<GiphyObjectCacheProtocol> objectCache;

/**
 *  Manager to control shared network acvity indicator's activity.
 */
@property(nonatomic)id<GiphyNetworkActivityProtocol> networkActivityManager;

/**
 *  Translates text from one language to another using Yandex API.
 *  @param sourceText           Text to be translated. Must not be empty.
 *  @param sourceLanguage       Language code to translate text from. Must not be empty.
 *  @param destinationLanguage  Language code to translate text to. Must not be empty.
 *  @param successBlock         Block to call if translation completes successfully. 
 *                              Translation result object will be passed as block's parameter.
 *  @param failureBlock         Block to call if translation fails. Error object will be passed as block's parameter.
 *  @return Object to cancel request if needed.
 */
- (id)getTranslationWithSourceText:(NSString*)sourceText
                   sourceLanguage:(NSString*)sourceLanguage
              destinationLanguage:(NSString*)destinationLanguage
                          successBlock:(void (^)(GiphyTranslationResult *translatedResult))successBlock
                          failureBlock:(void (^)(NSError *error))failureBlock;

/**
 *  Fetch build-in gif categories from server.
 *  @param successBlock Block to call when request completes successfully. Categories list will be passed as block's parameter.
 *  @param failureBlock Block to call when request fails. Error will be passed as block's parameter.
 *  @return Object to cancel request if needed.
 */
- (id)getCategoriesWithSuccessBlock:(void (^)(NSArray *gifCategoriesObjects))successBlock
                           failureBlock:(void (^)(NSError *error))failureBlock;

/**
 *  Fetch gif object by id.
 *  @param gifId        NSString unique gif id to fetch object by.
 *  @param successBlock Block to call on successfull gif fetch.
 *  @param failureBlock Block to call on failed gif fetch.
 *  @return Object to cancel request if needed.
 */
- (id)getGifById:(NSString*)gifId
    successBlock:(void (^)(GiphyGIFObject *gifObject))successBlock
    failureBlock:(void (^)(NSError *error))failureBlock;

/**
 *  Fetches gifs by searching with phrase (search text) using giphy.com API.
 *  @param searchText   Pharase (search text) to fetch gifs for. Must not be empty.
 *  @param searchType   Type of the gifs search logic.
 *  @param offset       Offset in the search result list to return objects from. Must be > 0.
 *  @param limit        Number of objects to return. Must be > 0.
 *  @return Object to cancel request if needed.
 */
- (id)getGifsWithSearchText:(NSString*)searchText
                searchType:(GiphySearchType)searchType
                    offset:(NSInteger)offset
                     limit:(NSInteger)limit
                   successBlock:(void (^)(NSArray *gifObjectsArray))successBlock
                   failureBlock:(void (^)(NSError *error))failureBlock;

/**
 *  Downloads image by url if there is no already loaded one in cache.
 *  @param url              URL to fetch image by. Must not be nil.
 *  @param cachePolicy      Cache policy to use on image requesting.
 *  @param successBlock     Block to call when request completes successfully. Fetched image will be passed as block's parameter.
 *  @param progressBlock    Block to notify about downloading progress. Progress value will be passed as block's parameter.
 *  @param failureBlock     Block to call when reqest fails. Error will be passed as parameter.
 *  @return Object to cancel request if needed.
 */
- (id)getStillByURL:(NSURL *)url
        cachePolicy:(GiphyRequestCachePolicy)cachePolicy
       successBlock:(void (^)(UIImage *stillImage))successBlock
      progressBlock:(void (^)(CGFloat progress))progressBlock
       failureBlock:(void (^)(NSError *error))failureBlock;

/**
 *  Downloads gif by url if there is no already loaded one in cache.
 *  @param url              URL to fetch gif by. Must not be nil.
 *  @param cachePolicy      Cache policy to use on gif requesting.
 *  @param successBlock     Block to call when request completes successfully. Fetched gif animated image will be passed as block's parameter.
 *  @param progressBlock    Block to notify about downloading progress. Progress value will be passed as block's parameter.
 *  @param failureBlock     Block to call when reqest fails. Error will be passed as parameter.
 *  @return Object to cancel request if needed.
 */
- (id)getGIFByURL:(NSURL *)url
      cachePolicy:(GiphyRequestCachePolicy)cachePolicy
          successBlock:(void (^)(FLAnimatedImage *animatedImage))successBlock
         progressBlock:(void (^)(CGFloat progress))progressBlock
               failureBlock:(void (^)(NSError *error))failureBlock;


/**
 *  Cancels request for given identifier.
 */
- (void)cancelRequestForCancellationIdentifier:(id)cancellationIdentifier;

/**
 *  Cancels all active requests.
 */
- (void)cancelAllRequests;

/**
 *  Pauses requests for given type.
 *  @param requestType Type to pause requests.
 */
- (void)pauseRequestsForType:(GiphyRequestType)requestType;

/**
 * Resumes requests for given type.
 *  @param requestType Type to resume requests.
 */
- (void)resumeRequestsForType:(GiphyRequestType)requestType;

@end

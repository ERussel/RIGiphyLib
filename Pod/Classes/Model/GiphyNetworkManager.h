//
//  GiphyNetworkManager.h
//  GiphyTest
//
//  Created by Aft3rmath on 28.07.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <AFNetworking/AFNetworking.h>
#import "FLAnimatedImage.h"
#import "GiphyRequest.h"
#import "GiphyGIFObject.h"
#import "GiphyCategoryObject.h"
#import "GiphyTranslationResult.h"

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
 *  Subclass of NSObject designed to provide servers interaction logic.
 */
@interface GiphyNetworkManager : NSObject

#pragma mark - Initialize

/**
 *  @return Shared network manager.
 */
+ (instancetype) sharedManager;

#pragma mark - Giphy Network Manager

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
 *  Fetch build-in gif categories from Parse server.
 *  @param successBlock Block to call when request completes successfully. Categories list will be passed as block's parameter.
 *  @param failureBlock Block to call when request fails. Error will be passed as block's parameter.
 *  @return Object to cancel request if needed.
 */
- (id)getCategoriesWithSuccessBlock:(void (^)(NSArray *gifCategoriesObjects))successBlock
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
        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
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
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
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

@end

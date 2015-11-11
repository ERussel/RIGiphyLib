//
//  GiphyRequest.h
//  GiphyTest
//
//  Created by Russel on 10.09.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

@class GiphyRequest;

#pragma mark - User Info Keys

/**
 *  Key to extract serializer for Foundation request.
 */
extern NSString * const kGiphyRequestUserInfoSerializerKey;

/**
 *  Key to extract block to call on attempt completion.
 */
extern NSString * const kGiphyRequestUserInfoAttemptCompletionBlockKey;

/**
 *  Key to extract block to notify about downloading progress.
 */
extern NSString * const kGiphyRequestUserInfoDownloadProgressBlock;

/**
 *  Operation success completion block definition
 */
typedef void (^GiphyRequestSuccessBlock)(GiphyRequest *request, id result);

/**
 *  Operation progress block definition.
 */
typedef void (^GiphyRequestProgressBlock)(GiphyRequest *request, CGFloat progress);

/**
 *  Operation fail block definition
 */
typedef void (^GiphyRequestFailBlock)(GiphyRequest *request, NSError *error);

/**
 *  Operation attempt block definition
 */
typedef void (^GiphyRequestAttemptCompletionBlock)(GiphyRequest *request, NSInteger madeAttempts);

/**
 *  Subclass of NSObject designed to provide request logic
 *  with repeat ability. On operation failing request checks number of made attempts and
 *  if this value is less than top bound than operation would be repeated.
 */

@interface GiphyRequest : NSObject

/**
 *  Creates repeating request with Foundation request.
 *  @param request  Foundation request to initialize with.
 *  @return Initialized repeating request.
 */
+ (instancetype)requestWithRequest:(NSURLRequest*)request;

/**
 *  Number of attempts restriction bound.
 *  By default 3.
 */
@property(nonatomic, readwrite)NSInteger maxAttempts;

/**
 *  Number of attempts request made to successfully complete operation.
 */
@property(nonatomic, readonly)NSInteger madeAttempts;

/**
 *  Flag states if operation is running.
 */
@property(nonatomic, readonly)BOOL executing;

/**
 *  Flag states whether request completed (successfully finished, failed).
 */
@property(nonatomic, readonly)BOOL completed;

/**
 *  Flag states whether request cancelled.
 */
@property(nonatomic, readonly)BOOL cancelled;

/**
 *  Request related integer value.
 *  By default 0.
 */
@property(nonatomic, readwrite)NSInteger operationType;

/**
 *  Pauses/resumes current request. Do nothing if request already completed or cancelled.
 */
@property(nonatomic, readwrite)BOOL paused;

/**
 *  Starts operation corresponding to the request.
 *  @param successBlock Block to call when operation corresponding to the request would complete successfully.
 *  @param failBlock    Block to call when request performed asked number of attempts to run operation but all of them failed with
 *                      the error passed as parameter.
 *  @param userInfo     NSDictionary to store additional data to build request.
 *  @see User info keys.
 */
- (void)executeRequestWithSuccessBlock:(GiphyRequestSuccessBlock)successBlock
                             failBlock:(GiphyRequestFailBlock)failBlock
                              userInfo:(NSDictionary*)userInfo;

/**
 *  Cancels current executing operation corresponding to the request.
 */
- (void)cancel;

@end

//
//  GiphyRequest.m
//  GiphyTest
//
//  Created by Russel on 10.09.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import "GiphyRequest.h"
#import <AFNetworking/AFNetworking.h>

NSString * const kGiphyRequestUserInfoSerializerKey = @"GiphyRequestUserInfoSerializerKey";
NSString * const kGiphyRequestUserInfoAttemptCompletionBlockKey = @"GiphyRequestUserInfoAttemptCompletionBlockKey";
NSString * const kGiphyRequestUserInfoDownloadProgressBlock = @"GiphyRequestUserInfoDownloadProgressBlock";

@interface GiphyRequest ()

#pragma mark - Giphy Request

/**
 *  Request object to create operation with. Supported NSURLRequest and PFQuery.
 */
@property(nonatomic)id requestObject;

/**
 *  Current running operation.
 */
@property(nonatomic)id activeOperation;

/**
 *  Success block to call when operation completes successfully.
 */
@property(nonatomic, copy)GiphyRequestSuccessBlock successBlock;

/**
 *  Fail block to call when all attempts to run operation made and all of them failed.
 */
@property(nonatomic, copy)GiphyRequestFailBlock failBlock;

/**
 *  NSDictionary to store additional data to build request.
 *  @see User info keys.
 */
@property(nonatomic, strong)NSDictionary *userInfo;

#pragma mark - Private

/**
 *  Executes request. Operation is created based on requestObject and starts.
 */
- (void)start;

/**
 *  Creates operation based on Foundation request and starts.
 *  @param foundationRequest    Foundation request to create and run operation.
 *  @param successBlock         Block to call when operation completes successfully.
 *  @param failBlock            Block to call if operation fails and no remained attempts to repeat.
 */
- (void)executeFoundationRequest:(NSURLRequest*)foundationRequest
                    successBlock:(GiphyRequestSuccessBlock)successBlock
                       failBlock:(GiphyRequestFailBlock)failBlock;

/**
 *  Creates operation based on Parse query and starts.
 *  @param foundationRequest    Parse query to create and run operation.
 *  @param successBlock         Block to call when operation completes successfully.
 *  @param failBlock            Block to call if operation fails and no remained attempts to repeat.
 */
- (void)executeParseQuery:(PFQuery*)parseQuery
             successBlock:(GiphyRequestSuccessBlock)successBlock
                failBlock:(GiphyRequestFailBlock)failBlock;

/**
 *  Changes request state to completed and clears operation related data.
 *  This method is called when operation completes successfully or there is no remained attempts to
 *  repeat it.
 */
- (void)completeExecution;

/**
 *  Cleares all data related to request executing.
 */
- (void)clearRequesData;


@end

@interface GiphyRequest (AFNetworking)

/**
 *  @return shared operation queue to execute operations in.
 */
+ (NSOperationQueue*)af_sharedOperationQueue;

@end

@implementation GiphyRequest (AFNetworking)

+ (NSOperationQueue*)af_sharedOperationQueue{
    static dispatch_once_t onceToken;
    static NSOperationQueue *sharedOperationQueue = nil;
    dispatch_once(&onceToken, ^{
        sharedOperationQueue = [[NSOperationQueue alloc] init];
        sharedOperationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    });
    
    return sharedOperationQueue;
}

@end


@implementation GiphyRequest

#pragma mark - Initialize

+ (instancetype)requestWithRequest:(NSURLRequest*)request{
    GiphyRequest *giphyRequest = [[self alloc] init];
    giphyRequest.requestObject = request;
    return giphyRequest;
}

+ (instancetype)requestWithParseQuery:(PFQuery *)query{
    GiphyRequest *giphyRequest = [[self alloc] init];
    giphyRequest.requestObject = query;
    return giphyRequest;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        // setup default values
        _maxAttempts = 3;
    }
    return self;
}

#pragma mark - Memory

- (void)dealloc{
    // cancel current operation on release
    [self cancel];
}

#pragma mark - Giphy Request

- (void)setPaused:(BOOL)paused{
    if (_paused != paused) {
        _paused = paused;
        
        // ignore flag if request completed or cancelled
        if (!_completed && !_cancelled) {
            if(!_paused){
                [self start];
            }else{
                _executing = NO;
                
                if (_activeOperation) {
                    [_activeOperation cancel];
                    _activeOperation = nil;
                }
            }
        }
    }
}

- (void)executeRequestWithSuccessBlock:(GiphyRequestSuccessBlock)successBlock
                             failBlock:(GiphyRequestFailBlock)failBlock
                              userInfo:(NSDictionary*)userInfo{
    NSAssert(_requestObject, @"Request object is not set");
    
    if (_completed) {
        NSLog(@"Can't execute completed request");
        return;
    }
    
    if (_cancelled) {
        NSLog(@"Can't execute cancelled request");
        return;
    }
    
    // do nothing if is request already executing
    if (_executing) {
        return;
    }
    
    // save operation related data
    self.successBlock = successBlock;
    self.failBlock = failBlock;
    self.userInfo = userInfo;
    
    // reset attempts counter
    _madeAttempts = 0;
    
    // start execution
    [self start];
}

- (void)cancel{
    if (_executing) {
        // cancel request if executing
        _executing = NO;
        _cancelled = YES;
        
        // cancel operation if there is active one
        if (_activeOperation && [_activeOperation respondsToSelector:@selector(cancel)]) {
            [_activeOperation performSelector:@selector(cancel) withObject:nil];
        }
    }
    
    // clear operation related data
    [self clearRequesData];
}

#pragma mark - Private

- (void)start{
    // mark operation executing
    _executing = YES;
    
    // increment attempts number
    _madeAttempts++;
    
    // start operation based on type
    if ([_requestObject isKindOfClass:[NSURLRequest class]]) {
        [self executeFoundationRequest:_requestObject
                          successBlock:self.successBlock
                             failBlock:self.failBlock];
    }else if ([_requestObject isKindOfClass:[PFQuery class]]){
        [self executeParseQuery:_requestObject
                   successBlock:self.successBlock
                      failBlock:self.failBlock];
    }
}

- (void)executeFoundationRequest:(NSURLRequest*)foundationRequest
                    successBlock:(GiphyRequestSuccessBlock)successBlock
                       failBlock:(GiphyRequestFailBlock)failBlock{
    // create operation
    _activeOperation = [[AFHTTPRequestOperation alloc] initWithRequest:foundationRequest];
    
    // setup response serializer if provided
    id responseSerializer = [_userInfo objectForKey:kGiphyRequestUserInfoSerializerKey];
    if (responseSerializer) {
        [(AFHTTPRequestOperation*)_activeOperation setResponseSerializer:responseSerializer];
    }
    
    // set completion block
    __weak __typeof(self) weakSelf = self;
    [_activeOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id resposeObject){
        // complete operation if not cancelled
        [weakSelf completeExecution];
        
        // return result via success block
        if (successBlock) {
            successBlock(weakSelf, resposeObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error){
        if ([error code] != NSURLErrorCancelled) {
            if (weakSelf.madeAttempts < weakSelf.maxAttempts) {
                // notify about attempt completion
                GiphyRequestAttemptCompletionBlock attemptCompletionBlock = [weakSelf.userInfo objectForKey:kGiphyRequestUserInfoAttemptCompletionBlockKey];
                if (attemptCompletionBlock) {
                    attemptCompletionBlock(weakSelf, weakSelf.madeAttempts);
                }
                
                // repeat failed operation if there is remained attempts
                [weakSelf start];
            }else{
                // complete operation if not cancelled
                [weakSelf completeExecution];
                
                // return error via fail block
                if (failBlock) {
                    failBlock(weakSelf, error);
                }
            }
        }else{
            if(weakSelf.executing){
                // complete request if was cancelled by the system
                [weakSelf cancel];
            }
        }
    }];
    
    // track download progress if corresponding block provided
    GiphyRequestProgressBlock downloadProgressBlock = [self.userInfo objectForKey:kGiphyRequestUserInfoDownloadProgressBlock];
    if (downloadProgressBlock) {
        [(AFHTTPRequestOperation*)_activeOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalExpectedBytesRead){
            if (downloadProgressBlock) {
                if (totalExpectedBytesRead > 0) {
                    downloadProgressBlock(weakSelf,(CGFloat)totalBytesRead/(CGFloat)totalExpectedBytesRead);
                }else{
                    downloadProgressBlock(weakSelf,0.0f);
                }
            }
        }];
    }
    
    // start operation
    [[[self class] af_sharedOperationQueue] addOperation:_activeOperation];
}

- (void)executeParseQuery:(PFQuery*)parseQuery
                    successBlock:(GiphyRequestSuccessBlock)successBlock
                       failBlock:(GiphyRequestFailBlock)failBlock{
    // save operation
    _activeOperation = parseQuery;
    __weak __typeof(self) weakSelf = self;

    [parseQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (!error || [error code] != NSURLErrorCancelled) {
            if (!error) {
                // complete operation
                [weakSelf completeExecution];
                
                // return result via success block
                if (successBlock) {
                    successBlock(weakSelf,objects);
                }
            }else{
                if (weakSelf.madeAttempts < weakSelf.maxAttempts) {
                    // notify about attempt completion
                    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = [weakSelf.userInfo objectForKey:kGiphyRequestUserInfoAttemptCompletionBlockKey];
                    if (attemptCompletionBlock) {
                        attemptCompletionBlock(weakSelf,weakSelf.madeAttempts);
                    }
                    
                    // repeat failed operation if there is remained attempts
                    [weakSelf start];
                }else{
                    //complete operation
                    [weakSelf completeExecution];
                    
                    // return error via fail block
                    if (failBlock) {
                        failBlock(weakSelf,error);
                    }
                }
            }
        }else {
            if(weakSelf.executing){
                // complete request if was cancelled by the system
                [weakSelf cancel];
            }
        }
    }];
}

- (void)completeExecution{
    _executing = NO;
    _completed = YES;
    
    [self clearRequesData];
}

- (void)clearRequesData{
    _activeOperation = nil;
    self.successBlock = nil;
    self.failBlock = nil;
    self.userInfo = nil;
}

@end

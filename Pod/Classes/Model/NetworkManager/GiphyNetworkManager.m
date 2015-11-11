//
//  GiphyNetworkManager.m
//  GiphyTest
//
//  Created by Aft3rmath on 28.07.15.
//  Copyright (c) 2015 Aft3rmath. All rights reserved.
//

#import "GiphyNetworkManager.h"
#import "FLAnimatedImageSerializer.h"
#import "GiphyGIFObject+Parser.h"
#import "GiphyCategoryObject+Parse.h"
#import "GiphyTranslationResult+Yandex.h"

/**
 *  Notification name to post when manager completes still loading.
 */
NSString * const GiphyNetworkManagerDidRecieveStillNotification = @"GiphyNetworkManagerDidRecieveStillNotification";

/**
 *  Notification name to post when manager completes GIF loading.
 */
NSString * const GiphyNetworkManagerDidRecieveGIFNotification = @"GiphyNetworkManagerDidRecieveGIFNotification";

/**
 *  Key corresponding to loaded object (GIF or still) to extract from notification's user info.
 */
NSString * const kGiphyNetworkManagerRecievedObjectKey = @"GiphyNetworkManagerRecievedObjectKey";

/**
 *  Key corresponding to loaded object's url (GIF or still) to extract from notification's user info.
 */
NSString * const kGiphyNetworkManagerRecievedObjectURLKey = @"GiphyNetworkManagerRecievedObjectURLKey";

/**
 *  Application's id registered on server.
 */
NSString * const kServerAppId = @"aTxS0APLlsPL63vsrB5OEJjKq1snWqmJ4MWaUGeG";

/**
 *  Application's key to access server's data.
 */
NSString * const kServerAPIKey = @"8l7t5cfT5rQBgN3qPSoNU7t5qlMXojcUwcU1hBdD";

/**
 *  URL to fetch categories from server.
 */
NSString * const kServerCategoriesURL = @"https://api.parse.com/1/classes/Category";

/**
 *  Yandex Translate API base url string.
 */
NSString * const kYandexAPIURL = @"https://translate.yandex.net/api/v1.5/tr.json/translate";

/**
 *  API key necessary to perform requests to Yande Translate API.
 */
NSString * const kYandexTranslatorAPIKey = @"trnsl.1.1.20150728T154240Z.76c8421d8a33d635.c1bb4bc674c3b9b6c42e3b1a2a1408fa323b68b2";

/**
 *  Giphy api base url string.
 */
NSString * const kGiphyAPIBaseURL = @"https://api.giphy.com/v1/gifs";

/**
 *  Giphy search by description url string
 */
NSString * const kGiphyAPISearchURL = @"https://api.giphy.com/v1/gifs/search";

/**
 *  Giphy translating text to gif content url string
 */
NSString * const kGiphyAPITranslateURL = @"https://api.giphy.com/v1/gifs/translate";

/**
 *  API key necessary to perfrom requests to Giphy API.
 */
NSString * const kGiphyAPIPublicBetaKey = @"dc6zaTOxFJmzC";

/**
 *  Default request timeout interval
 */
const CGFloat kNetworkManagerDefaultTimeoutInterval = 8.0f;

@interface GiphyNetworkManager()

/**
 *  Array to store active request to ignore response proccessing from cancelled.
 */
@property(nonatomic)NSMutableArray *requests;

#pragma mark - Requests

/**
 *  Saves request to shared list and registers network activity for it.
 */
- (void)addRequest:(id)request;

/**
 *  Removes request from shared list and drops network activity for it
 */
- (void)completeRequest:(id)request;

/**
 *  @return YES if given request already placed to shared request list.
 */
- (BOOL)hasRequest:(id)request;

@end

@implementation GiphyNetworkManager


#pragma mark - Initialize

+ (id)sharedManager {
    static GiphyNetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[self alloc] init];
    });
    return networkManager;
}

- (id)init
{
    self = [super init];
    if (self){
        _requests = [[NSMutableArray alloc] init];
        _networkActivityManager = (id<GiphyNetworkActivityProtocol>)[PFNetworkActivityIndicatorManager sharedManager];
    }
    
    return self;
}

#pragma mark - Translator API

- (id)getTranslationWithSourceText:(NSString*)sourceText
                    sourceLanguage:(NSString*)sourceLanguage
               destinationLanguage:(NSString*)destinationLanguage
                      successBlock:(void (^)(GiphyTranslationResult *translatedResult))successBlock
                      failureBlock:(void (^)(NSError *error))failureBlock{
    
    NSAssert(sourceText.length > 0, @"Source text is undefined and translation can't be performed");
    NSAssert(sourceLanguage.length > 0, @"Source language is undefined and translation can't be performed");
    NSAssert(destinationLanguage.length > 0, @"Destination language is undefined and translation can't be performed");
    
    // configure parameters for translation request
    NSDictionary *parameters = @{@"key": kYandexTranslatorAPIKey, @"text": sourceText, @"lang": [NSString stringWithFormat:@"%@-%@", sourceLanguage, destinationLanguage]};
    
    // create translation request
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:kYandexAPIURL parameters:parameters error:&error];
    
    // return error if request is not created
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(error);
            }
        });
        
        return nil;
    }
    
    request.timeoutInterval = kNetworkManagerDefaultTimeoutInterval;
    
    GiphyRequestSuccessBlock giphySuccessBlock = ^(GiphyRequest *giphyRequest, id result){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            // create inner translation result from yandex response
            GiphyTranslationResult *translationResult = [GiphyTranslationResult translationResultFromYandexResponse:result forOriginalText:sourceText];
            
            if (successBlock) {
                successBlock(translationResult);
            }
        }
    };
    
    GiphyRequestFailBlock giphyFailBlock = ^(GiphyRequest *giphyRequest, NSError *error){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    };
    
    // setup attempt block to be notified about failed fetch attempts
    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = ^(GiphyRequest *giphyRequest, NSInteger madeAttempts){
        NSLog(@"Made attempts %@ translating %@ from %@ to %@", @(madeAttempts), sourceText, sourceLanguage, destinationLanguage);
    };
    
    // wrap repeatable request for translation and execute
    GiphyRequest *giphyRequest = [GiphyRequest requestWithRequest:request];
    giphyRequest.operationType = kGiphyRequestTypeDefault;
    
    // save to local store to proccess result only for active requests
    [self addRequest:giphyRequest];
    
    [giphyRequest executeRequestWithSuccessBlock:giphySuccessBlock
                                       failBlock:giphyFailBlock
                                        userInfo:@{kGiphyRequestUserInfoSerializerKey : [AFJSONResponseSerializer serializer],
                                                   kGiphyRequestUserInfoAttemptCompletionBlockKey : attemptCompletionBlock}];
    
    return giphyRequest;
}


#pragma mark - Giphy API

-(id)getCategoriesWithSuccessBlock:(void (^)(NSArray *gifCategoriesObjects))successBlock
                      failureBlock:(void (^)(NSError *error))failureBlock
{
    // create request to load categories from server
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kServerCategoriesURL]];
    [request setValue:kServerAppId forHTTPHeaderField:@"X-Parse-Application-Id"];
    [request setValue:kServerAPIKey forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    
    GiphyRequestSuccessBlock giphySuccessBlock = ^(GiphyRequest *giphyRequest, NSDictionary* result){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            // extract categories
            NSArray *parseCategories = [result objectForKey:@"results"];
            
            // transform Parse categories to internal objects
            NSMutableArray *categories = [NSMutableArray array];
            for (NSDictionary* pfcategory in parseCategories) {
                GiphyCategoryObject *category = [GiphyCategoryObject categoryFromDictionary:pfcategory];
                [categories addObject:category];
            }
            
            if (successBlock) {
                successBlock(categories);
            }
        }
    };
    
    GiphyRequestFailBlock giphyFailBlock = ^(GiphyRequest *giphyRequest, NSError *error){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    };
    
    // setup attempt block to be notified about failed fetch attempts
    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = ^(GiphyRequest *giphyRequest, NSInteger madeAttempts){
        NSLog(@"Made attempts %@ to fetch gif categories", @(madeAttempts));
    };
    
    // wrap repeatable request to load categories and execute
    GiphyRequest *giphyRequest = [GiphyRequest requestWithRequest:request];
    giphyRequest.operationType = kGiphyRequestTypeDefault;
    
    // save to local store to proccess result only for active requests
    [self addRequest:giphyRequest];
    
    [giphyRequest executeRequestWithSuccessBlock:giphySuccessBlock
                                       failBlock:giphyFailBlock
                                        userInfo:@{kGiphyRequestUserInfoAttemptCompletionBlockKey : attemptCompletionBlock,
                                                   kGiphyRequestUserInfoSerializerKey : [AFJSONResponseSerializer serializer]}];
    
    return giphyRequest;
}

- (id)getGifById:(NSString*)gifId
    successBlock:(void (^)(GiphyGIFObject *gifObject))successBlock
    failureBlock:(void (^)(NSError *error))failureBlock{
    NSAssert(gifId.length > 0, @"Gif id can't be nil");
    
    // create fetch request
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET"
                                                                                 URLString:[kGiphyAPIBaseURL stringByAppendingPathComponent:gifId]
                                                                                parameters:@{@"api_key": kGiphyAPIPublicBetaKey}
                                                                                     error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(error);
            }
        });
        
        return nil;
    }
    
    request.timeoutInterval = kNetworkManagerDefaultTimeoutInterval;
    
    GiphyRequestSuccessBlock giphySuccessBlock = ^(GiphyRequest *giphyRequest, id result){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if(successBlock) {
                // parse giphy objects to internal gif objects
                GiphyGIFObject *gifObject = nil;
                id giphyData = result[@"data"];
                
                if (giphyData) {
                    if([giphyData isKindOfClass:[NSDictionary class]]) {
                        gifObject = [GiphyGIFObject gifObjectFromGiphyDictionary:giphyData];
                    }else if([giphyData isKindOfClass:[NSArray class]] && [giphyData count] > 0){
                        NSDictionary *giphyGif = [giphyData firstObject];
                        gifObject = [GiphyGIFObject gifObjectFromGiphyDictionary:giphyGif];
                    }
                }
                
                successBlock(gifObject);
            }
        }
    };
    
    GiphyRequestFailBlock giphyFailBlock = ^(GiphyRequest *giphyRequest, NSError *error){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    };
    
    // setup attempt block to be notified about failed fetch attempts
    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = ^(GiphyRequest *giphyRequest, NSInteger madeAttempts){
        NSLog(@"Made attempts %@ to fetch gif by id %@", @(madeAttempts), gifId);
    };
    
    // wrap repeatable gif get by id request and execute
    GiphyRequest *giphyRequest = [GiphyRequest requestWithRequest:request];
    giphyRequest.operationType = kGiphyRequestTypeDefault;
    
    // save to proccess response only for active request
    [self addRequest:giphyRequest];
    
    [giphyRequest executeRequestWithSuccessBlock:giphySuccessBlock
                                       failBlock:giphyFailBlock
                                        userInfo:@{kGiphyRequestUserInfoAttemptCompletionBlockKey : attemptCompletionBlock,
                                                   kGiphyRequestUserInfoSerializerKey : [AFJSONResponseSerializer serializer]}];
    
    return giphyRequest;
}

- (id)getGifsWithSearchText:(NSString*)searchText
                 searchType:(GiphySearchType)searchType
                     offset:(NSInteger)offset
                      limit:(NSInteger)limit
               successBlock:(void (^)(NSArray *gifObjectsArray))successBlock
               failureBlock:(void (^)(NSError *error))failureBlock{
    NSAssert(searchText.length > 0, @"Search string can't be empty");
    
    NSDictionary *parameters = nil;
    NSString *urlString = nil;
    
    if(searchType == kGiphySearchTypeDescription){
        // define url and parameters for description search
        urlString = kGiphyAPISearchURL;
        parameters = @{@"api_key": kGiphyAPIPublicBetaKey, @"q": searchText, @"offset" : @(offset), @"limit" : @(limit)};
    }else if(searchType == kGiphySearchTypeContent) {
        // define url and parameters for translating search
        urlString = kGiphyAPITranslateURL;
        parameters = @{@"api_key": kGiphyAPIPublicBetaKey, @"s": searchText};
    }else{
        [NSException raise:@"Unsupported search type" format:@"Values %@ is unsupported",@(searchType)];
    }
    
    // create search request
    NSError *error = nil;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:urlString parameters:parameters error:&error];
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (failureBlock) {
                failureBlock(error);
            }
        });
        
        return nil;
    }
    
    request.timeoutInterval = kNetworkManagerDefaultTimeoutInterval;
    
    GiphyRequestSuccessBlock giphySuccessBlock = ^(GiphyRequest *giphyRequest, id result){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if(successBlock) {
                // parse giphy objects to internal gif objects
                NSMutableArray *gifObjects = [NSMutableArray array];
                id giphyData = result[@"data"];
                
                if (giphyData) {
                    if([giphyData isKindOfClass:[NSDictionary class]]) {
                        GiphyGIFObject *gifObject = [GiphyGIFObject gifObjectFromGiphyDictionary:giphyData];
                        [gifObjects addObject:gifObject];
                    }else {
                        for (NSDictionary *giphyGif in giphyData) {
                            GiphyGIFObject *gifObject = [GiphyGIFObject gifObjectFromGiphyDictionary:giphyGif];
                            [gifObjects addObject:gifObject];
                        }
                    }
                }
                
                successBlock(gifObjects);
            }
        }
    };
    
    GiphyRequestFailBlock giphyFailBlock = ^(GiphyRequest *giphyRequest, NSError *error){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    };
    
    // setup attempt block to be notified about failed fetch attempts
    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = ^(GiphyRequest *giphyRequest, NSInteger madeAttempts){
        NSLog(@"Made attempts %@ to search gif for text %@ with content searching flag %@", @(madeAttempts), searchText, @(searchType));
    };
    
    // wrap repeatable gif search request and execute
    GiphyRequest *giphyRequest = [GiphyRequest requestWithRequest:request];
    giphyRequest.operationType = kGiphyRequestTypeDefault;
    
    // save to proccess response only for active request
    [self addRequest:giphyRequest];
    
    [giphyRequest executeRequestWithSuccessBlock:giphySuccessBlock
                                       failBlock:giphyFailBlock
                                        userInfo:@{kGiphyRequestUserInfoAttemptCompletionBlockKey : attemptCompletionBlock,
                                                   kGiphyRequestUserInfoSerializerKey : [AFJSONResponseSerializer serializer]}];
    
    return giphyRequest;
}

- (id)getStillByURL:(NSURL *)url
        cachePolicy:(NSURLRequestCachePolicy)cachePolicy
       successBlock:(void (^)(UIImage *stillImage))successBlock
      progressBlock:(void (^)(CGFloat progress))progressBlock
       failureBlock:(void (^)(NSError *error))failureBlock{
    
    NSAssert(url, @"URL to load still image must not be nil");
    
    // create request to fetch image from url if not exits in cache
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:cachePolicy
                                         timeoutInterval:kNetworkManagerDefaultTimeoutInterval];
    
    GiphyRequestSuccessBlock giphySuccessBlock = ^(GiphyRequest *giphyRequest, id result){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (result) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GiphyNetworkManagerDidRecieveStillNotification
                                                                    object:self
                                                                  userInfo:@{kGiphyNetworkManagerRecievedObjectKey : result,
                                                                                           kGiphyNetworkManagerRecievedObjectURLKey : url}];
            }
            
            if(successBlock) {
                successBlock(result);
            }
        }
    };
    
    GiphyRequestProgressBlock giphyProgressBlock = ^(GiphyRequest *giphyRequest, CGFloat progress){
        if ([self hasRequest:giphyRequest]) {
            if (progressBlock) {
                progressBlock(progress);
            }
        }
    };
    
    GiphyRequestFailBlock giphyFailBlock = ^(GiphyRequest *giphyRequest, NSError *error){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    };

    // setup attempt block to be notified about failed fetch attempts
    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = ^(GiphyRequest *giphyRequest, NSInteger madeAttempts){
        NSLog(@"Made attempts %@ to download still image at url %@", @(madeAttempts), url);
    };
    
    // wrap repeatable request to load image and execute
    GiphyRequest *giphyRequest = [GiphyRequest requestWithRequest:request];
    giphyRequest.operationType = kGiphyRequestTypeStill;
    
    // save to proccess response only for active request
    [self addRequest:giphyRequest];
    
    [giphyRequest executeRequestWithSuccessBlock:giphySuccessBlock
                                       failBlock:giphyFailBlock
                                        userInfo:@{kGiphyRequestUserInfoDownloadProgressBlock : giphyProgressBlock,
                                                   kGiphyRequestUserInfoAttemptCompletionBlockKey : attemptCompletionBlock,
                                                   kGiphyRequestUserInfoSerializerKey : [AFImageResponseSerializer serializer]}];
    
    return giphyRequest;
}

- (id)getGIFByURL:(NSURL *)url
      cachePolicy:(NSURLRequestCachePolicy)cachePolicy
     successBlock:(void (^)(FLAnimatedImage *animatedImage))successBlock
    progressBlock:(void (^)(CGFloat progress))progressBlock
     failureBlock:(void (^)(NSError *error))failureBlock{
    
    NSAssert(url, @"URL to load gif must not be nil");
    
    // create gif fetch request to download or extract from the cache
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:cachePolicy
                                         timeoutInterval:kNetworkManagerDefaultTimeoutInterval];
    
    GiphyRequestSuccessBlock giphySuccessBlock = ^(GiphyRequest *giphyRequest, id result){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (result) {
                [[NSNotificationCenter defaultCenter] postNotificationName:GiphyNetworkManagerDidRecieveGIFNotification
                                                                    object:self
                                                                  userInfo:@{kGiphyNetworkManagerRecievedObjectKey : result,
                                                                                           kGiphyNetworkManagerRecievedObjectURLKey : url}];
            }
            
            if(successBlock) {
                successBlock(result);
            }
        }
    };
    
    GiphyRequestProgressBlock giphyProgressBlock = ^(GiphyRequest *giphyRequest, CGFloat progress){
        if ([self hasRequest:giphyRequest]) {
            if (progressBlock) {
                progressBlock(progress);
            }
        }
    };
    
    GiphyRequestFailBlock giphyFailBlock = ^(GiphyRequest *giphyRequest, NSError *error){
        if ([self hasRequest:giphyRequest]) {
            [self completeRequest:giphyRequest];
            
            if (failureBlock) {
                failureBlock(error);
            }
        }
    };
    
    // setup attempt block to be notified about failed fetch attempts
    GiphyRequestAttemptCompletionBlock attemptCompletionBlock = ^(GiphyRequest *giphyRequest, NSInteger madeAttempts){
        NSLog(@"Made attempts %@ to download still image at url %@", @(madeAttempts), url);
    };
    
    // create repeatable gif fetch request and execute
    GiphyRequest *giphyRequest = [GiphyRequest requestWithRequest:request];
    giphyRequest.operationType = kGiphyRequestTypeGIF;
    
    // wrap repeatable request to load image and execute
    [self addRequest:giphyRequest];
    
    // pass special gif serializer to create internal animated image from response
    [giphyRequest executeRequestWithSuccessBlock:giphySuccessBlock
                                       failBlock:giphyFailBlock
                                        userInfo:@{kGiphyRequestUserInfoDownloadProgressBlock : giphyProgressBlock,
                                                   kGiphyRequestUserInfoAttemptCompletionBlockKey : attemptCompletionBlock,
                                                   kGiphyRequestUserInfoSerializerKey : [FLAnimatedImageSerializer serializer]}];
    
    return giphyRequest;
}

#pragma mark - Cancellation

- (void)cancelRequestForCancellationIdentifier:(id)cancellationIdentifier{
    if (cancellationIdentifier && [_requests containsObject:cancellationIdentifier]) {
        [_requests removeObject:cancellationIdentifier];
        [(GiphyRequest*)cancellationIdentifier cancel];
        
        [_networkActivityManager decrementActivityCount];
    }
}

- (void)cancelAllRequests{
    if ([_requests count] > 0) {
        NSArray *requestsToCancel = _requests;
        _requests = [[NSMutableArray alloc] init];
        
        for (GiphyRequest *request in requestsToCancel) {
            [request cancel];
            
            [_networkActivityManager decrementActivityCount];
        }
    }
}

#pragma mark - Pause/Resume

- (void)pauseRequestsForType:(GiphyRequestType)requestType{
    for (GiphyRequest *request in _requests) {
        if (request.operationType == requestType) {
            [request setPaused:YES];
        }
    }
}

- (void)resumeRequestsForType:(GiphyRequestType)requestType{
    for (GiphyRequest *request in _requests) {
        if (request.operationType == requestType) {
            [request setPaused:NO];
        }
    }
}

#pragma mark - Requests

- (void)addRequest:(id)request{
    if (![self hasRequest:request] && request) {
        // add request to shared list if is not already contained in
        [_requests addObject:request];
        
        // register network activity for it
        [_networkActivityManager incrementActivityCount];
    }
}

- (void)completeRequest:(id)request{
    if ([self hasRequest:request]) {
        // remove request from shared list if contained in
        [_requests removeObject:request];
        
        // drop network activity for request
        [_networkActivityManager decrementActivityCount];
    }
}

- (BOOL)hasRequest:(id)request{
    if (!request) {
        return NO;
    }
    
    return [_requests containsObject:request];
}


@end

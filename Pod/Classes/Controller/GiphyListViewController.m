//
//  GiphyListViewController.m
//  GiphyTest
//
//  Created by Russel on 15.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyListViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import "GiphyNavigationController.h"
#import "GiphyPreviewViewController.h"
#import "GiphySearchTableViewCell.h"
#import "GiphyCollectionViewNode.h"
#import "GiphyCategoryCollectionViewNode.h"
#import "GiphyOptionsView.h"
#import "GiphyBundle.h"
#import "GiphyNetworkManager.h"
#import "GiphyGIFObject.h"
#import "GiphyCategoryObject.h"
#import "GiphySearchRequestObject.h"
#import "UISearchBar+Language.h"
#import "GiphyPresentationAnimation.h"

typedef enum {
    kGiphyContentStateFound,
    kGiphyContentStateLoading,
    kGiphyContentStateError
}GiphyContentState;

typedef enum {
    kGiphyListTypeCategories,
    kGiphyListTypeSearchResults
}GiphyListType;

@interface GiphyListViewController ()<ASCollectionViewDataSource, ASCollectionViewDelegate, GiphyOptionsViewDelegate, UISearchBarDelegate, UIViewControllerTransitioningDelegate>

#pragma mark - Initialize

- (void)configureToolbar;

- (void)configureSearchBar;

- (void)configureContentView;

- (void)configureCategoryCollectionView;

- (void)configureSearchCollectionView;

#pragma mark - Giphy List View Controller

@property(nonatomic, weak)UISearchBar *searchBar;

@property(nonatomic, weak)UIView *contentView;

@property(nonatomic, weak)UILabel *errorLabel;

@property(nonatomic, weak)UIActivityIndicatorView *activityIndicatorView;

@property(nonatomic, weak)ASCollectionView *categoryCollectionView;

@property(nonatomic, weak)UIRefreshControl *categoryRefreshControl;

@property(nonatomic, weak)ASCollectionView *searchCollectionView;

@property(nonatomic, weak)UIRefreshControl *searchRefreshControl;

@property(nonatomic)GiphyOptionsView *searchHistoryView;

@property(nonatomic)GiphyPresentationAnimation *previewAnimation;

@property(nonatomic, readwrite)GiphyListType listType;

@property(nonatomic, readwrite)GiphyContentState contentState;

@property(nonatomic, readwrite)NSInteger itemSize;

@property(nonatomic, readwrite)NSInteger itemsSpace;

@property(nonatomic)NSArray *searchRequests;

@property(nonatomic)NSMutableArray *categories;

@property(nonatomic)id categoriesCancellationToken;

@property(nonatomic)GiphySearchRequestObject *searchRequestObject;

@property(nonatomic)NSMutableArray *searchResults;

@property(nonatomic)id searchCancellationToken;

@property(nonatomic)id translationCancellationToken;

@property(nonatomic)ASBatchContext *searchBatchContext;

@property(nonatomic)id<GiphyDataStoreProtocol> dataManager;

@property(nonatomic)id<GiphyImageCacheProtocol> imageCache;

@property(nonatomic, readwrite)CGFloat currentKeyboardY;

@end

@implementation GiphyListViewController

NSString* const kGiphySearchCellIdentifier = @"GiphySearchCellIdentifier";

NSString * const kGiphyDataManagerSearchRequestCollectionName = @"SearchRequestCollection";

NSString* const kGiphyDestinationLanguageCode = @"en";

const CGFloat kGiphyListItemSize = 151.0f;

const CGFloat kGiphyListItemSpace = 6.0f;

const NSInteger kGiphySearchPageSize = 60;

const CGFloat kGiphyErrorTitlePadding = 15.0f;

#pragma mark - Memory

- (void)dealloc{
    [self cancelCategoriesRequest];
    [self cancelGifSearchRequest];
    [self cancelTranslationRequest];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialize

- (instancetype)initWithDataManager:(id<GiphyDataStoreProtocol>)dataManager
                         imageCache:(id<GiphyImageCacheProtocol>)imageCache{
    self = [super init];
    if (self) {
        _dataManager = dataManager;
        _imageCache = imageCache;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _previewAnimation = [[GiphyPresentationAnimation alloc] init];
    _previewAnimation.backgroundTintColor = [UIColor colorWithRed:135.0f/255.0f
                                                            green:206.0f/255.0f
                                                             blue:250.0f/255.0f
                                                            alpha:1.0f];
    
    _searchResults = [[NSMutableArray alloc] init];
    _categories = [[NSMutableArray alloc] init];
    [self configure];
    [self updateCategories];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [_categoryCollectionView setContentInset:UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                                              0.0f,
                                                              CGRectGetHeight(self.navigationController.toolbar.frame),
                                                              0.0f)];
    [_searchCollectionView setContentInset:UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                                              0.0f,
                                                              CGRectGetHeight(self.navigationController.toolbar.frame),
                                                              0.0f)];
}

- (void)configure{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _currentKeyboardY = self.view.bounds.size.height;
    
    [self updateMeasurementInformation];
    
    [self configureToolbar];
    [self configureContentView];
    [self configureCategoryCollectionView];
    [self configureSearchCollectionView];
    [self configureSearchBar];
    
    [self updateScrollsToTop];
    
    _searchCollectionView.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowHide:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)configureToolbar{
    [self.navigationController setToolbarHidden:NO];
    [self resetToolbarItems];
}

- (void)resetToolbarItems{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[GiphyBundle imageNamed:@"giphy_logo.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UIBarButtonItem *logoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    
    UIBarButtonItem *cancelBarButtonItem = !_hidesCancelButton ? [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                         target:self
                                                                                         action:@selector(actionCancelGifPicking:)] : nil;
    
    UIBarButtonItem *spacingBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                          target:nil
                                                                                          action:nil];
    
    if (cancelBarButtonItem) {
        [self setToolbarItems:@[cancelBarButtonItem, spacingBarButtonItem, logoBarButtonItem, spacingBarButtonItem]];
    }else{
        [self setToolbarItems:@[spacingBarButtonItem, logoBarButtonItem, spacingBarButtonItem]];
    }
}

- (void)configureSearchBar{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    _searchBar = searchBar;
    
    self.navigationItem.titleView = searchBar;
}

- (void)configureContentView{
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    _contentView = contentView;
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(CGRectGetMidX(contentView.frame), CGRectGetMidY(contentView.frame));
    activityIndicatorView.hidesWhenStopped = YES;
    [contentView addSubview:activityIndicatorView];
    _activityIndicatorView = activityIndicatorView;
    
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.numberOfLines = 0;
    [contentView addSubview:errorLabel];
    _errorLabel = errorLabel;
}

- (void)configureCategoryCollectionView{
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLayout setMinimumInteritemSpacing:_itemsSpace];
    [collectionViewLayout setMinimumLineSpacing:_itemsSpace];
    [collectionViewLayout setSectionInset:UIEdgeInsetsMake(_itemsSpace, _itemsSpace, _itemsSpace, _itemsSpace)];
    ASCollectionView *collectionView = [[ASCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)
                                                          collectionViewLayout:collectionViewLayout
                                                             asyncDataFetching:NO];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.asyncDataSource = self;
    collectionView.asyncDelegate = self;
    collectionView.alwaysBounceVertical = YES;
    [_contentView addSubview:collectionView];
    _categoryCollectionView = collectionView;
    
    UIRefreshControl *categoryRefreshControl = [[UIRefreshControl alloc] init];
    [categoryRefreshControl addTarget:self
                             action:@selector(actionRefreshCategories:)
                   forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:categoryRefreshControl];
    _categoryRefreshControl = categoryRefreshControl;
}

- (void)configureSearchCollectionView{
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    [collectionViewLayout setMinimumInteritemSpacing:_itemsSpace];
    [collectionViewLayout setMinimumLineSpacing:_itemsSpace];
    [collectionViewLayout setSectionInset:UIEdgeInsetsMake(_itemsSpace, _itemsSpace, _itemsSpace, _itemsSpace)];
    ASCollectionView *collectionView = [[ASCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)
                                                          collectionViewLayout:collectionViewLayout
                                                             asyncDataFetching:NO];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.asyncDataSource = self;
    collectionView.asyncDelegate = self;
    collectionView.alwaysBounceVertical = YES;
    [_contentView addSubview:collectionView];
    _searchCollectionView = collectionView;
    
    UIRefreshControl *searchRefreshControl = [[UIRefreshControl alloc] init];
    [searchRefreshControl addTarget:self
                             action:@selector(actionRefreshSeachResults:)
                   forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:searchRefreshControl];
    _searchRefreshControl = searchRefreshControl;
}

#pragma mark - Giphy List View Controller

- (void)setContentState:(GiphyContentState)contentState{
    [self setContentState:contentState withErrorTitle:_errorLabel.text];
}

- (void)setContentState:(GiphyContentState)contentState withErrorTitle:(NSString*)errorTitle{
    _contentState = contentState;
    
    _errorLabel.text = errorTitle;
    if (contentState == kGiphyContentStateError) {
        _errorLabel.hidden = NO;
        
        CGSize titleSize = [_errorLabel sizeThatFits:CGSizeMake(_contentView.bounds.size.width - 2*kGiphyErrorTitlePadding, CGFLOAT_MAX)];
        _errorLabel.frame = CGRectMake(roundf(_contentView.frame.size.width/2.0f - titleSize.width/2.0f),
                                       roundf(_contentView.frame.size.height/2.0f - titleSize.height/2.0f),
                                       titleSize.width,
                                       titleSize.height);
    }else{
        _errorLabel.hidden = YES;
    }
    
    
    if (contentState == kGiphyContentStateLoading) {
        _activityIndicatorView.center = CGPointMake(CGRectGetMidX(_contentView.frame), CGRectGetMidY(_contentView.frame));
        [_activityIndicatorView startAnimating];
    }else{
        [_activityIndicatorView stopAnimating];
    }
}

- (void)setHidesCancelButton:(BOOL)hidesCancelButton{
    if (_hidesCancelButton != hidesCancelButton) {
        _hidesCancelButton = hidesCancelButton;
        [self resetToolbarItems];
    }
}

#pragma mark - Subclass

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Collection View Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if ([collectionView isEqual:_categoryCollectionView]) {
        return [_categories count];
    }else if([collectionView isEqual:_searchCollectionView]){
        return [_searchResults count];
    }
    
    return 0;
}

- (ASCellNode*)collectionView:(ASCollectionView *)collectionView nodeForItemAtIndexPath:(NSIndexPath *)indexPath{
    ASCellNode *cellNode = nil;
    
    if([collectionView isEqual:_categoryCollectionView]){
        GiphyCategoryObject *categoryObject = [_categories objectAtIndex:indexPath.row];
        NSString *categoryName = [categoryObject localizedTitle];
        cellNode = [[GiphyCategoryCollectionViewNode alloc] initWithStillURL:categoryObject.stillURL
                                                                  imageCache:_imageCache
                                                                      gifURL:categoryObject.gifURL
                                                               preferredSize:CGSizeMake(_itemSize, _itemSize) title:[[NSAttributedString alloc] initWithString:[(categoryName ? categoryName : @"") uppercaseString] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0f*_itemSize/kGiphyListItemSize], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
    }else if([collectionView isEqual:_searchCollectionView]){
        GiphyGIFObject *gifObject = [_searchResults objectAtIndex:indexPath.row];
        cellNode = [[GiphyCollectionViewNode alloc] initWithStillURL:gifObject.thumbnailStillURL
                                                          imageCache:_imageCache
                                                              gifURL:gifObject.thumbnailGifURL
                                                       preferredSize:CGSizeMake(_itemSize, _itemSize)];
    }
    
    return cellNode;
}

- (BOOL)shouldBatchFetchForCollectionView:(ASCollectionView *)collectionView{
    return [collectionView isEqual:_searchCollectionView];
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context{
    if (!self.searchCancellationToken) {
        __weak __typeof(self) weakSelf = self;
        self.searchBatchContext = context;
        self.searchCancellationToken = [[GiphyNetworkManager sharedManager] getGifsWithSearchText:_searchRequestObject.translationResult.translatedText
                                                                                       searchType:kGiphySearchTypeDescription
                                                                                           offset:[_searchResults count]
                                                                                            limit:kGiphySearchPageSize
                                                                                     successBlock:^(NSArray *gifObjectsArray){
                                                                                         if (weakSelf.searchCancellationToken) {
                                                                                             weakSelf.searchCancellationToken = nil;
                                                                                             
                                                                                             if ([gifObjectsArray count] > 0) {
                                                                                                 NSMutableArray *insertIndexPaths = [NSMutableArray array];
                                                                                                 for (NSInteger i = 0; i < [gifObjectsArray count]; i++) {
                                                                                                     [insertIndexPaths addObject:[NSIndexPath indexPathForRow:[weakSelf.searchResults count] + i inSection:0]];
                                                                                                 }
                                                                                                 
                                                                                                 [weakSelf.searchResults addObjectsFromArray:gifObjectsArray];
                                                                                                 
                                                                                                 [weakSelf.searchCollectionView insertItemsAtIndexPaths:insertIndexPaths completion:nil];
                                                                                                 
                                                                                                 [weakSelf.searchBatchContext completeBatchFetching:[gifObjectsArray count] == kGiphySearchPageSize];
                                                                                             }else{
                                                                                                 [weakSelf.searchBatchContext completeBatchFetching:NO];
                                                                                             }
                                                                                             
                                                                                             weakSelf.searchBatchContext = nil;
                                                                                         }
                                                                                     } failureBlock:^(NSError *error){
                                                                                         weakSelf.searchCancellationToken = nil;
                                                                                         
                                                                                         [weakSelf.searchBatchContext completeBatchFetching:YES];
                                                                                         weakSelf.searchBatchContext = nil;
                                                                                     }];
    }
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if ([collectionView isEqual:_categoryCollectionView]) {
        GiphyCategoryObject *category = [_categories objectAtIndex:indexPath.row];
        NSString *translatedCategoryTitle = [category titleForLocaleCode:kGiphyDestinationLanguageCode];
        NSString *localizedCategoryTitle = [category localizedTitle];
        
        if (translatedCategoryTitle) {
            GiphyTranslationResult *translationResult = [[GiphyTranslationResult alloc] initWithResults:@[translatedCategoryTitle]
                                                                                        forOriginalText:localizedCategoryTitle
                                                                                 translatedFromLanguage:[_searchBar inputLanguageCode]
                                                                                             toLanguage:kGiphyDestinationLanguageCode];
            GiphySearchRequestObject *searchRequestObject = [[GiphySearchRequestObject alloc] initWithTranslationResult:translationResult];
            [self startSearchingWithRequest:searchRequestObject animated:YES];
        }
        
    }else if ([collectionView isEqual:_searchCollectionView]){
        GiphyGIFObject *gifObject = [_searchResults objectAtIndex:indexPath.row];
        GiphyPreviewViewController *giphyPreviewController = [[GiphyPreviewViewController alloc] initWithGifObject:gifObject];
        [giphyPreviewController setModalPresentationStyle:UIModalPresentationCustom];
        [giphyPreviewController setTransitioningDelegate:self];
        [self.navigationController presentViewController:giphyPreviewController animated:YES completion:nil];
    }
}

#pragma mark - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    [self showsSearchHistory:YES animated:YES];
    [self showsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self showsSearchHistory:NO animated:YES];
    
    if (_listType != kGiphyListTypeSearchResults) {
        [self showsCancelButton:NO animated:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSString *currentLanguageCode = [searchBar inputLanguageCode];
    
    [self cancelTranslationRequest];
    
    if (![currentLanguageCode isEqualToString:kGiphyDestinationLanguageCode]) {
        __weak __typeof(self) weakSelf = self;
        self.translationCancellationToken = [[GiphyNetworkManager sharedManager] getTranslationWithSourceText:searchBar.text
                                                           sourceLanguage:[searchBar inputLanguageCode]
                                                      destinationLanguage:kGiphyDestinationLanguageCode
                                                             successBlock:^(GiphyTranslationResult *translationResult){
                                                                 if (weakSelf.translationCancellationToken) {
                                                                     weakSelf.translationCancellationToken = nil;
                                                                     
                                                                     GiphySearchRequestObject *searchRequestObject = [[GiphySearchRequestObject alloc] initWithTranslationResult:translationResult];
                                                                     [weakSelf startSearchingWithRequest:searchRequestObject
                                                                                                animated:YES];
                                                                 }
                                                             } failureBlock:^(NSError *error){
                                                                 weakSelf.searchCancellationToken = nil;
                                                             }];
    }else{
        GiphyTranslationResult *translationResult = [[GiphyTranslationResult alloc] initWithResults:@[searchBar.text]
                                                                                    forOriginalText:searchBar.text
                                                                             translatedFromLanguage:currentLanguageCode
                                                                                         toLanguage:kGiphyDestinationLanguageCode];
        GiphySearchRequestObject *searchRequestObject = [[GiphySearchRequestObject alloc] initWithTranslationResult:translationResult];
        [self startSearchingWithRequest:searchRequestObject animated:YES];
    }
    
    [_searchBar resignFirstResponder];
}

#pragma mark - Options View Delegate

- (void)optionsView:(GiphyOptionsView *)optionsView didSelectOptionAtIndex:(NSInteger)selectedIndex{
    // extract selected search request
    GiphySearchRequestObject *searchRequestObject = [_searchRequests objectAtIndex:selectedIndex];
    
    // complete interaction with search bar
    [_searchBar resignFirstResponder];
    
    // move to searching interface if needed
    [self startSearchingWithRequest:searchRequestObject animated:YES];
}

- (void)optionsWillHideView:(GiphyOptionsView *)optionsView{
    [_searchBar resignFirstResponder];
}

#pragma mark - Action

- (void)actionRefreshCategories:(UIRefreshControl*)refreshControl{
    if (!self.categoriesCancellationToken) {
        [self updateCategories];
    }
}

- (void)actionRefreshSeachResults:(UIRefreshControl*)refreshControl{
    [self updateGifListWithCurrentRequest];
}

- (void)actionSearchCancel:(UIBarButtonItem*)cancelBarButtonItem{
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }else{
        [self completeSearchingAnimated:YES];
    }
}

- (void)actionCancelGifPicking:(UIBarButtonItem*)cancelBarButton{
    [[NSNotificationCenter defaultCenter] postNotificationName:GiphyNavigationControllerDidCancelNotification
                                                        object:nil];
}

#pragma mark - Data

- (void)updateCategories{
    if (!self.categoriesCancellationToken) {
        
        if (_listType == kGiphyListTypeCategories && ![self.categories count]) {
            [self setContentState:kGiphyContentStateLoading];
        }
        
        __weak __typeof(self) weakSelf = self;
        self.categoriesCancellationToken = [[GiphyNetworkManager sharedManager] getCategoriesWithSuccessBlock:^(NSArray *gifCategories){
            if (weakSelf.categoriesCancellationToken) {
                weakSelf.categoriesCancellationToken = nil;
                
                [weakSelf.categories addObjectsFromArray:gifCategories];
                
                [weakSelf.categoryCollectionView setContentOffset:CGPointMake(0.0f, -weakSelf.categoryCollectionView.contentInset.top)];
                [weakSelf.categoryCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0] completion:nil];
                
                if (weakSelf.listType == kGiphyListTypeCategories) {
                    if ([gifCategories count] > 0) {
                        [weakSelf setContentState:kGiphyContentStateFound];
                    }else if(![weakSelf.categories count]){
                        [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyCategoriesNotFoundTitle"]];
                    }
                }
                
                [weakSelf.categoryRefreshControl endRefreshing];
            }
        } failureBlock:^(NSError *error){
            weakSelf.categoriesCancellationToken = nil;
            
            if (weakSelf.listType == kGiphyListTypeCategories && ![weakSelf.categories count]) {
                [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyConnectionError"]];
            }
            
            [weakSelf.categoryRefreshControl endRefreshing];
        }];
    }
}

- (void)cancelCategoriesRequest{
    if (_categoriesCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_categoriesCancellationToken];
        _categoriesCancellationToken = nil;
    }

    [self.categoryRefreshControl endRefreshing];
}

- (void)updateGifListWithCurrentRequest{
    [self cancelGifSearchRequest];
    
    if (_listType == kGiphyListTypeSearchResults && ![self.searchResults count]) {
        [self setContentState:kGiphyContentStateLoading];
    }
    
    __weak __typeof(self) weakSelf = self;
    self.searchCancellationToken = [[GiphyNetworkManager sharedManager] getGifsWithSearchText:_searchRequestObject.translationResult.translatedText
                                                                                   searchType:kGiphySearchTypeDescription
                                                                                       offset:0
                                                                                        limit:kGiphySearchPageSize
                                                                                 successBlock:^(NSArray *gifObjects){
                                                                                     if (weakSelf.searchCancellationToken) {
                                                                                         weakSelf.searchCancellationToken = nil;
                                                                                         
                                                                                         [weakSelf.searchResults removeAllObjects];
                                                                                         [weakSelf.searchResults addObjectsFromArray:gifObjects];
                                                                                         
                                                                                         [weakSelf.searchCollectionView setContentOffset:CGPointMake(0.0f, -weakSelf.searchCollectionView.contentInset.top)];
                                                                                         [weakSelf.searchCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0] completion:nil];
                                                                                         
                                                                                         if (weakSelf.listType == kGiphyListTypeSearchResults) {
                                                                                             if ([gifObjects count] > 0) {
                                                                                                 [weakSelf setContentState:kGiphyContentStateFound];
                                                                                             }else if(![weakSelf.searchResults count]){
                                                                                                 [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphySearchNotFoundTitle"]];
                                                                                             }
                                                                                         }
                                                                                         
                                                                                         [weakSelf.searchRefreshControl endRefreshing];
                                                                                     }
                                                                                 } failureBlock:^(NSError *error){
                                                                                     weakSelf.searchCancellationToken = nil;
                                                                                     
                                                                                     if (weakSelf.listType == kGiphyListTypeSearchResults && ![weakSelf.searchResults count]) {
                                                                                         [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyConnectionError"]];
                                                                                     }
                                                                                     
                                                                                     [weakSelf.searchRefreshControl endRefreshing];
                                                                                 }];
}

- (void)cancelGifSearchRequest{
    if (_searchCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_searchCancellationToken];
        _searchCancellationToken = nil;
    }
    
    if (_searchBatchContext) {
        [_searchBatchContext completeBatchFetching:NO];
        _searchBatchContext = nil;
    }
    
    [self.searchRefreshControl endRefreshing];
}

- (void)cancelTranslationRequest{
    if (_translationCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_translationCancellationToken];
        _translationCancellationToken = nil;
    }
}

#pragma mark - Notification

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _currentKeyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    
    if ([_searchHistoryView visible]) {
        [_searchHistoryView.tableView setContentInset:UIEdgeInsetsMake(_categoryCollectionView.contentInset.top, 0.0f, self.view.bounds.size.height - _currentKeyboardY, 0.0f)];
    }
}

#pragma mark - Transitioning Delegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    _previewAnimation.animationType = GiphyPresentationAnimationTypeAppearance;
    return _previewAnimation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    _previewAnimation.animationType = GiphyPresentationAnimationTypeDismiss;
    return _previewAnimation;
}

#pragma mark - Private

- (void)showsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated{
    if (showsCancelButton && !self.navigationItem.rightBarButtonItem) {
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[GiphyBundle imageNamed:@"cancel_search_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(actionSearchCancel:)];
        [self.navigationItem setRightBarButtonItem:cancelBarButtonItem animated:animated];
    }else if (!showsCancelButton && self.navigationItem.rightBarButtonItem){
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
    }
}

- (void)showsSearchHistory:(BOOL)showsSearchHistory animated:(BOOL)animated{
    if (showsSearchHistory) {
        
        _searchRequests = [_dataManager fetchObjectsFromCollection:kGiphyDataManagerSearchRequestCollectionName];
        NSMutableArray *options = [NSMutableArray array];
        
        for (GiphySearchRequestObject *searchRequest in _searchRequests) {
            if (searchRequest.translationResult.originalText.length > 0) {
                [options addObject:searchRequest.translationResult.originalText];
            }
        }
        
        if (!_searchHistoryView) {
            _searchHistoryView = [[GiphyOptionsView alloc] initWithFrame:self.view.bounds options:options];
            _searchHistoryView.delegate = self;
            _searchHistoryView.anchorPoint = CGPointMake(0.0f, 0.0f);
            _searchHistoryView.rowBackgroundColor = [UIColor whiteColor];
            _searchHistoryView.tableView.backgroundColor = [UIColor whiteColor];
            _searchHistoryView.tableView.scrollEnabled = YES;
            _searchHistoryView.dimmedColor = [UIColor colorWithWhite:0.0f alpha:0.3f];
            _searchHistoryView.rowIcon = [[GiphyBundle imageNamed:@"search_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        }else{
            _searchHistoryView.frame = self.view.bounds;
            _searchHistoryView.options = options;
        }
        
        _searchHistoryView.tableView.hidden = [options count] == 0;
        _searchHistoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_searchHistoryView.tableView setContentInset:UIEdgeInsetsMake(_categoryCollectionView.contentInset.top, 0.0f, self.view.bounds.size.height - _currentKeyboardY, 0.0f)];
        [_searchHistoryView.tableView setContentOffset:CGPointMake(0.0f, -_categoryCollectionView.contentInset.top) animated:NO];
        
        [_searchHistoryView showOnView:self.view position:CGPointMake(0.0f, 0.0f) animated:animated];
    }else if([_searchHistoryView visible]){
        [_searchHistoryView hideAnimated:animated];
        _searchRequests = nil;
    }
    
    [self updateScrollsToTop];
}

- (void)startSearchingWithRequest:(GiphySearchRequestObject*)searchRequestObject animated:(BOOL)animated{
    if (!searchRequestObject || [self.searchRequestObject isEqual:searchRequestObject]) {
        return;
    }
    
    [self updateDatastoreWithSearchRequestObject:searchRequestObject];
    [self setSearchRequestObject:searchRequestObject];
    
    [_searchBar setText:searchRequestObject.translationResult.originalText];
    
    if (_listType != kGiphyListTypeSearchResults) {
        _listType = kGiphyListTypeSearchResults;
        
        [self showsCancelButton:YES animated:animated];
        [self updateScrollsToTop];
        [self setContentState:kGiphyContentStateFound];
        
        _searchCollectionView.contentInset = _categoryCollectionView.contentInset;
        
        _categoryCollectionView.hidden = YES;
        _searchCollectionView.hidden = NO;
        
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        
        CATransition *transitionAnimation = [CATransition animation];
        [transitionAnimation setType:kCATransitionPush];
        [transitionAnimation setSubtype:kCATransitionFromRight];
        [_contentView.layer addAnimation:transitionAnimation forKey:@"startSearchTransition"];
        
        [CATransaction commit];
    }
    
    [self updateGifListWithCurrentRequest];
}

- (void)completeSearchingAnimated:(BOOL)animated{
    if (_listType != kGiphyListTypeCategories) {
        _listType = kGiphyListTypeCategories;
        
        [self cancelTranslationRequest];
        [self cancelGifSearchRequest];
        
        [_searchBar setText:nil];
        [self showsCancelButton:NO animated:animated];
        [self updateScrollsToTop];
        [self setContentState:kGiphyContentStateFound];
        
        _categoryCollectionView.hidden = NO;
        _searchCollectionView.hidden = YES;
        
        if (_searchHistoryView) {
            _searchHistoryView.tableView.scrollsToTop = NO;
        }
        
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        
        CATransition *transitionAnimation = [CATransition animation];
        [transitionAnimation setType:kCATransitionPush];
        [transitionAnimation setSubtype:kCATransitionFromLeft];
        [_contentView.layer addAnimation:transitionAnimation forKey:@"completeSearchTransition"];
        
        [CATransaction setCompletionBlock:^{
            if (_listType != kGiphyListTypeSearchResults) {
                [self.searchResults removeAllObjects];
                self.searchRequestObject = nil;
                
                [_searchCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0] completion:nil];
            }
        }];
        
        [CATransaction commit];
    }
}

- (void)updateScrollsToTop{
    _categoryCollectionView.scrollsToTop = (_listType == kGiphyListTypeCategories && ![_searchHistoryView visible]);
    _searchCollectionView.scrollsToTop = (_listType == kGiphyListTypeSearchResults && ![_searchHistoryView visible]);
    
    if (_searchHistoryView) {
        _searchHistoryView.tableView.scrollsToTop = [_searchHistoryView visible];
    }
}

- (BOOL)updateMeasurementInformation{
    CGFloat aspectRatio = self.view.frame.size.width/320.0f;
    
    CGFloat newItemSize = aspectRatio*kGiphyListItemSize;
    CGFloat newItemsSpace = aspectRatio*kGiphyListItemSpace;
    
    BOOL didMeasurementChange = NO;
    
    if (fabs(newItemSize - _itemSize) > FLT_EPSILON){
        _itemSize = newItemSize;
        didMeasurementChange = YES;
    }
    
    if (fabs(newItemsSpace - _itemsSpace) > FLT_EPSILON) {
        _itemsSpace = newItemsSpace;
        didMeasurementChange = YES;
    }
    
    return didMeasurementChange;
}

- (void)updateDatastoreWithSearchRequestObject:(GiphySearchRequestObject*)searchRequestObject{
    if (searchRequestObject) {
        [_dataManager removeObject:searchRequestObject forCollection:kGiphyDataManagerSearchRequestCollectionName];
        [_dataManager addObject:searchRequestObject forCollection:kGiphyDataManagerSearchRequestCollectionName];
    }
}

@end

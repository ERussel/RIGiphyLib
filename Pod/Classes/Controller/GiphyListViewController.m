//
//  GiphyListViewController.m
//  GiphyTest
//
//  Created by Russel on 15.10.15.
//  Copyright © 2015 Aft3rmath. All rights reserved.
//

#import "GiphyListViewController.h"
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASRangeHandlerRender.h>
#import <AsyncDisplayKit/_ASDisplayView.h>
#import "GiphyNavigationController.h"
#import "GiphyPreviewViewController.h"
#import "GiphySearchTableViewCell.h"
#import "GiphySearchCollectionViewNode.h"
#import "GiphyCategoryCollectionViewNode.h"
#import "GiphyOptionsView.h"
#import "GiphyBundle.h"
#import "GiphyNetworkManager.h"
#import "GiphyGIFObject.h"
#import "GiphyCategoryObject.h"
#import "GiphySearchRequestObject.h"
#import "UISearchBar+Language.h"
#import "GiphyPresentationAnimation.h"

/**
 *  Type to define controller's display state.
 */
typedef enum {
    /**
     *  Content found and displayed.
     */
    kGiphyContentStateFound,
    
    /**
     *  No content but loading now.
     */
    kGiphyContentStateLoading,
    
    /**
     *  No content and error occured.
     */
    kGiphyContentStateError
}GiphyContentState;

/**
 *  Type of content list.
 */
typedef enum {
    /**
     *  GIF categories list.
     */
    kGiphyListTypeCategories,
    
    /**
     *  GIF search results list.
     */
    kGiphyListTypeSearchResults
}GiphyListType;

@interface GiphyListViewController ()<ASCollectionViewDataSource, ASCollectionViewDelegate, GiphyOptionsViewDelegate, GiphyPreviewViewControllerDelegate,
UISearchBarDelegate, UIViewControllerTransitioningDelegate>

#pragma mark - Initialize

/**
 *  Unhides controller's toolbar and places logo and cancel button (if needed) on it.
 *  \sa resetToolbarItems.
 */
- (void)configureToolbar;

/**
 *  Gerates objects and places its on toolbar. By default cancel button and giphy logo are displayed.
 *  \sa hidesCancelButton.
 */
- (void)resetToolbarItems;

/**
 *  Configures searchbar placed on navigation bar.
 *  By default white search field with translucent light gray background.
 */
- (void)configureSearchBar;

/**
 *  Configures content view to display categories and search lists.
 *  Left/right push animation applies to content view on switch between lists.
 */
- (void)configureContentView;

/**
 *  Configures collection view to display GIF categories.
 */
- (void)configureCategoryCollectionView;

/**
 *  Configures collection view to display GIF search results.
 */
- (void)configureSearchCollectionView;

#pragma mark - Giphy List View Controller

/**
 *  Search bar display on navigation bar to provide GIF search interface.
 */
@property(nonatomic, weak)UISearchBar *searchBar;

/**
 *  Content view to display GIF lists and visualize switch animation between its.
 *  Activity indicator and error message label also are placed on it.
 */
@property(nonatomic, weak)UIView *contentView;

/**
 *  Label to display error message in error content state. By default message is display on the content view's center.
 */
@property(nonatomic, weak)UILabel *errorLabel;

/**
 *  Activity indicator to animate in loading content state. By default is placed on the content view's center.
 */
@property(nonatomic, weak)UIActivityIndicatorView *activityIndicatorView;

/**
 *  Collection view to display categories list.
 */
@property(nonatomic, weak)ASCollectionView *categoryCollectionView;

/**
 *  Refresh control to allow user update categories list.
 *  \sa actionRefreshCategories:
 */
@property(nonatomic, weak)UIRefreshControl *categoryRefreshControl;

/**
 *  Collection view to display search results list.
 */
@property(nonatomic, weak)ASCollectionView *searchCollectionView;

/**
 *  Refresh control to allow user update search results list.
 */
@property(nonatomic, weak)UIRefreshControl *searchRefreshControl;

/**
 *  View to display search request history. Activated when user starts editing text in search bar.
 */
@property(nonatomic)GiphyOptionsView *searchHistoryView;

/**
 *  Animator object to control transition from/to GIF preview controller.
 */
@property(nonatomic)GiphyPresentationAnimation *previewAnimation;

/**
 *  Current visible list type. By default category list is visible.
 *  \sa GiphyListType.
 */
@property(nonatomic, readwrite)GiphyListType listType;

/**
 *  Current content state.
 *  \sa GiphyContentState.
 */
@property(nonatomic, readwrite)GiphyContentState contentState;

/**
 *  Calculated list item's size.
 *  \sa updateMeasurementInformation
 */
@property(nonatomic, readwrite)NSInteger itemSize;

/**
 *  Calculated space between items in landscape orientation.
 *  \sa updateMeasurementInformation
 */
@property(nonatomic, readwrite)NSInteger horizontalItemsSpace;

/**
 *  Calculated space between items in landscape orientation.
 *  \sa updateMeasurementInformation
 */
@property(nonatomic, readwrite)NSInteger verticalItemsSpace;

/**
 *  Array of GiphySearchRequestObject objects representing history list of the search attempts.
 *  Populating from data manager.
 *  \sa dataManager
 */
@property(nonatomic)NSArray *searchRequests;

/**
 *  Array of GiphyCategoryObject objects representing GIF categories to display in correponding collection view.
 *  Loading from network manager.
 *  \sa updateCategories.
 */
@property(nonatomic)NSMutableArray *categories;

/**
 *  Token to cancel categories loading request.
 */
@property(nonatomic)id categoriesCancellationToken;

/**
 *  Current search object to request GIFs for search collection view.
 *  \sa updateGifListWithCurrentRequest.
 */
@property(nonatomic)GiphySearchRequestObject *searchRequestObject;

/**
 *  Array of GiphyGIFObject objects to display in search collection view.
 */
@property(nonatomic)NSMutableArray *searchResults;

/**
 *  Token to cancel GIF search request.
 */
@property(nonatomic)id searchCancellationToken;

/**
 *  Token to cancel search request translation.
 */
@property(nonatomic)id translationCancellationToken;

/**
 *  Context to control search list batching logic.
 *  \sa collectionView:willBeginBatchFetchWithContext:
 */
@property(nonatomic)ASBatchContext *searchBatchContext;

/**
 *  Data manager to save related objects. By default is used to cache user search requests to display history.
 */
@property(nonatomic)id<GiphyDataStoreProtocol> dataManager;

/**
 *  Custom cache object to store loaded stills.
 */
@property(nonatomic)id<GiphyImageCacheProtocol> imageCache;

/**
 *  Keyboards current y origin value which used to proper layout search history view and list insets.
 */
@property(nonatomic, readwrite)CGFloat currentKeyboardY;

#pragma mark - Data

/**
 *  Performs categories fetch request via shared network manager. To cancel request call corresponding cancellation method.
 *  \sa cancelCategoriesRequest.
 */
- (void)updateCategories;

/**
 *  Cancels category request using cancellation token.
 *  \sa categoriesCancellationToken
 */
- (void)cancelCategoriesRequest;

/**
 *  Cancels previous search fetch request and starts new one based on current user request. To cancel fetch call corresponding cancellation method.
 *  \sa cancelGifSearchRequest.
 */
- (void)updateGifListWithCurrentRequest;

/**
 *  Cancels current search fetch request using cancellation token.
 *  \sa searchCancellationToken.
 */
- (void)cancelGifSearchRequest;

/**
 *  Cancels translation request using cancellation token.
 *  \sa translationCancellationToken.
 */
- (void)cancelTranslationRequest;

#pragma mark - Action

/**
 *  Invoked when user changes category list refresh control's state.
 *  Starts loading categories if there is no request alredy running.
 *  @param refreshControl   Refresh control which was activated by the user.
 */
- (void)actionRefreshCategories:(UIRefreshControl*)refreshControl;

/**
 *  Invoked when user changes search list refresh control's state.
 *  Starts loading objects for current search request if there is no request alredy running.
 *  @param refreshControl   Refresh control which was activated by the user.
 */
- (void)actionRefreshSeachResults:(UIRefreshControl*)refreshControl;

/**
 *  Invoked when user presses cancel button near the search.
 *  If at the pressing moment search bar was active than it resigns first responder otherwise
 *  content switches from search list to category list by cancelling search request.
 *  @param cancelBarButtonItem   Cancel button pressed by the user.
 */
- (void)actionSearchCancel:(UIBarButtonItem*)cancelBarButtonItem;

/**
 *  Invoked when user presses cancel button on the toolbar.
 *  Sends notification that user wants cancel gif selection proccess.
 *  @param cancelBarButton  Cancel button pressed by the user.
 */
- (void)actionCancelGifPicking:(UIBarButtonItem*)cancelBarButton;

#pragma mark - Private

/**
 *  Hides/unhides search cancellation button near the search bar.
 *  @param showCancelButton Flag states whether button should be displayed or not.
 *  @param animated Flag states whether transition should be animated.
 */
- (void)showsCancelButton:(BOOL)showsCancelButton animated:(BOOL)animated;

/**
 *  Hides/unhides search history view.
 *  @param showsSearchHistory Flag states whether search history should be displayed or not.
 *  @param animated Flag states whether transition should be animated.
 */
- (void)showsSearchHistory:(BOOL)showsSearchHistory animated:(BOOL)animated;

/**
 *  Called when user wants to start searching by text phrase.
 *  This method performs translation if needed and starts searching with request.
 *  @param text             Text phrase to search GIFs by.
 *  @param inputLanguage    Text phrase input language.
 */
- (void)startSearchingWithText:(NSString*)text inputLanguage:(NSString*)inputLanguage;

/**
 *  Called when search information entered by the user proccessed and translated to Giphy support language.
 *  By default this method switches interface to search list and starts search fetch request. Also this method
 *  saves search request to history list, updates cancel button state and "scrolls to top" logic.
 *  @param searchRequestObject Search request object generated from the user information to request GIFs.
 *  @param animated Flag states whether transition should be animated.
 *  \sa showsCancelButton:animated:
 *  \sa updateScrollsToTop
 *  \sa completeSearchingAnimated:
 */
- (void)startSearchingWithRequest:(GiphySearchRequestObject*)searchRequestObject animated:(BOOL)animated;

/**
 *  Opposite method for above one. By default this method cancels search request and switches interface to categories list. Also this method
 *  update cancel button state and scrolls to top logic.
 *  @param animated Flag states whether transition should be animated.
 */
- (void)completeSearchingAnimated:(BOOL)animated;

/**
 *  Selects current visible scroll view to proccess "scrolls to top request".
 */
- (void)updateScrollsToTop;

/**
 *  Updates measument information: item size, horizontal and vertical space between items based on device type and screen size.
 *  @return YES if measurement information changed, otherwise NO.
 */
- (BOOL)updateMeasurementInformation;

/**
 *  Applies calculated measurement information to given collection view.
 *  @param collectionView   Collection view to update with measurement information.
 *  @param interfaceOrient  Interface orientation collection view displayed in.
 */
- (void)applyMeasurementInformationToCollectionView:(ASCollectionView*)collectionView atInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

/**
 *  Updates given collection view's layout based on bars layout.
 */
- (void)updateContentInsetsForCollectionView:(ASCollectionView*)collectionView;

/**
 *  Saves search request to data store. If data store already contains it than it would move to first position in history list.
 *  @param searchRequest Search request to save to data store.
 */
- (void)updateDatastoreWithSearchRequestObject:(GiphySearchRequestObject*)searchRequestObject;

/**
 *  Method is called to fix leak related to deallocation of invisible nodes when data gets reload.
 *  @param nodeClass Collection node class to remove invisible node objects for.
 *  \sa <a>https://github.com/facebook/AsyncDisplayKit/issues/791</a>
 */
- (void)clearInvisibleNodesForNodeClass:(Class)nodeClass;

@end

@implementation GiphyListViewController

/**
 *  Collection name to store search requests via data manager.
 */
NSString * const kGiphyDataManagerSearchRequestCollectionName = @"SearchRequestCollection";

/**
 *  Giphy supported language code.
 */
NSString* const kGiphyDestinationLanguageCode = @"en";

/**
 *  Collection view item size for 320x568 (iPhone 5/5s) screen.
 */
const CGFloat kGiphyListItemSizeDefault = 135.0f;

/**
 *  Collection view item size for 768x1024 (iPad) screen.
 */
const CGFloat kGiphyListItemSizeIPad = 250.0f;

/**
 *  Number of items to display per row for iPhone 4s in landscape orientation.
 */
const CGFloat kGiphyListItemHorizontalCountCompact = 3;

/**
 *  Number of items to display per row by default in landscape orientation.
 */
const CGFloat kGiphyListItemHorizontalCountDefault = 4;

/**
 *  Number of items to display per row by default in portraint orientation.
 */
const CGFloat kGiphyListItemVerticalCountDefault = 2;

/**
 *  Number of items to display per row on iPad in landscape orientation.
 */
const CGFloat kGiphyListItemHorizontalCountIPad = 4;

/**
 *  Number of items to display per row on iPad in portrait orientation.
 */
const CGFloat kGiphyListItemVerticalCountIPad = 3;

/**
 *  Limit for page size when fetch GIFs for search request.
 */
const NSInteger kGiphySearchPageSize = 60;

/**
 *  Left/right padding for error message.
 */
const CGFloat kGiphyErrorTitlePadding = 15.0f;

#pragma mark - Memory

- (void)dealloc{
    // clear invisible nodes
    [self clearInvisibleNodesForNodeClass:[GiphyCollectionViewNode class]];
    
    // cancel any active requests
    [self cancelCategoriesRequest];
    [self cancelGifSearchRequest];
    [self cancelTranslationRequest];
    
    // clear any data store in memory
    [_dataManager clearCachedMemoryData];
    
    // clear notifications observation
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Initialize

- (instancetype)initWithDataManager:(id<GiphyDataStoreProtocol>)dataManager
                         imageCache:(id<GiphyImageCacheProtocol>)imageCache{
    self = [super init];
    if (self) {
        _dataManager = dataManager;
        _imageCache = imageCache;
        
        // default initialize
        _previewBlurColor = [UIColor colorWithRed:120.0f/255.0f green:120.0f/255.0f blue:120.0f/255.0f alpha:1.0f];
        _cellPlaceholderColor = [UIColor colorWithWhite:229.0f/255.0f alpha:1.0f];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // create preview animator controller
    _previewAnimation = [[GiphyPresentationAnimation alloc] init];
    _previewAnimation.backgroundTintColor = _previewBlurColor;
    
    // create local data stores
    _searchResults = [[NSMutableArray alloc] init];
    _categories = [[NSMutableArray alloc] init];
    
    // setup view
    [self configure];
    
    // start categories loading
    [self updateCategories];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    // setup list insets based on bars' layout
    [self updateContentInsetsForCollectionView:_categoryCollectionView];
    [self updateContentInsetsForCollectionView:_searchCollectionView];
}

- (void)configure{
    // setup default style
    self.view.backgroundColor = [UIColor whiteColor];
    
    // update insets by hand
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // keyboard hidden by default
    _currentKeyboardY = self.view.bounds.size.height;
    
    // setup collection view measurement
    [self updateMeasurementInformation];
    
    // setup view hierarchy
    [self configureToolbar];
    [self configureContentView];
    [self configureCategoryCollectionView];
    [self configureSearchCollectionView];
    [self configureSearchBar];
    
    // only visible scroll view responds to status bar tap
    [self updateScrollsToTop];
    
    // by default categories should be visible
    _searchCollectionView.hidden = YES;
    
    // listen keyboard appearance notifications
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
    // setup logo toolbar item
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[[GiphyBundle imageNamed:@"giphy_logo.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    UIBarButtonItem *logoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:imageView];
    
    // setup cancel button if needed
    UIBarButtonItem *cancelBarButtonItem = !_hidesCancelButton ? [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                               target:self
                                                                                                               action:@selector(actionCancelGifPicking:)] : nil;
    
    UIBarButtonItem *spacingBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                          target:nil
                                                                                          action:nil];
    
    // fill tool bar with items
    if (cancelBarButtonItem) {
        [self setToolbarItems:@[cancelBarButtonItem, spacingBarButtonItem, logoBarButtonItem, spacingBarButtonItem]];
    }else{
        [self setToolbarItems:@[spacingBarButtonItem, logoBarButtonItem, spacingBarButtonItem]];
    }
}

- (void)configureSearchBar{
    // create search bar with default style
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    [self.view addSubview:searchBar];
    _searchBar = searchBar;
    
    // add toolbar to navigation bar
    self.navigationItem.titleView = searchBar;
}

- (void)configureContentView{
    // create content view
    UIView *contentView = [[UIView alloc] initWithFrame:self.view.bounds];
    contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:contentView];
    _contentView = contentView;
    
    // add activity default styled inficator for loading state
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(CGRectGetMidX(contentView.frame), CGRectGetMidY(contentView.frame));
    activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicatorView.hidesWhenStopped = YES;
    [contentView addSubview:activityIndicatorView];
    _activityIndicatorView = activityIndicatorView;
    
    // add default styled label to display in error state
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.numberOfLines = 0;
    [contentView addSubview:errorLabel];
    _errorLabel = errorLabel;
}

- (void)configureCategoryCollectionView{
    // create categories collection view
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    ASCollectionView *collectionView = [[ASCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)
                                                          collectionViewLayout:collectionViewLayout
                                                             asyncDataFetching:NO];
    [self applyMeasurementInformationToCollectionView:collectionView atInterfaceOrientation:self.interfaceOrientation];
    
    // apply collection view style
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    
    // setup callbacks
    collectionView.asyncDataSource = self;
    collectionView.asyncDelegate = self;
    
    // add to view hierarchy
    [_contentView addSubview:collectionView];
    _categoryCollectionView = collectionView;
    
    // add refresh control
    UIRefreshControl *categoryRefreshControl = [[UIRefreshControl alloc] init];
    [categoryRefreshControl addTarget:self
                             action:@selector(actionRefreshCategories:)
                   forControlEvents:UIControlEventValueChanged];
    [collectionView addSubview:categoryRefreshControl];
    _categoryRefreshControl = categoryRefreshControl;
}

- (void)configureSearchCollectionView{
    // create search collection view
    UICollectionViewFlowLayout *collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
    ASCollectionView *collectionView = [[ASCollectionView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height)
                                                          collectionViewLayout:collectionViewLayout
                                                             asyncDataFetching:NO];
    [self applyMeasurementInformationToCollectionView:collectionView atInterfaceOrientation:self.interfaceOrientation];
    
    // apply collection view style
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    collectionView.alwaysBounceVertical = YES;
    
    // setup callbacks
    collectionView.asyncDataSource = self;
    collectionView.asyncDelegate = self;
    
    // add to view hierarchy
    [_contentView addSubview:collectionView];
    _searchCollectionView = collectionView;
    
    // add refresh control
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
        // display error label for error state by centering in content view
        _errorLabel.hidden = NO;
        
        CGSize titleSize = [_errorLabel sizeThatFits:CGSizeMake(_contentView.bounds.size.width - 2*kGiphyErrorTitlePadding, CGFLOAT_MAX)];
        _errorLabel.frame = CGRectMake(roundf(_contentView.frame.size.width/2.0f - titleSize.width/2.0f),
                                       roundf(_contentView.frame.size.height/2.0f - titleSize.height/2.0f),
                                       titleSize.width,
                                       titleSize.height);
        _errorLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }else{
        _errorLabel.hidden = YES;
    }
    
    
    if (contentState == kGiphyContentStateLoading) {
        // display activity indicator for loading stateby centering in content view
        _activityIndicatorView.center = CGPointMake(CGRectGetMidX(_contentView.frame), CGRectGetMidY(_contentView.frame));
        _activityIndicatorView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin |   UIViewAutoresizingFlexibleBottomMargin;
        [_activityIndicatorView startAnimating];
    }else{
        [_activityIndicatorView stopAnimating];
    }
}

- (void)setHidesCancelButton:(BOOL)hidesCancelButton{
    // hides cancel button flag change so reset toolbar
    if (_hidesCancelButton != hidesCancelButton) {
        _hidesCancelButton = hidesCancelButton;
        [self resetToolbarItems];
    }
}

- (void)setPreviewBlurColor:(UIColor *)previewBlurColor{
    // preview background's blue changed so update preview animator
    if (![_previewBlurColor isEqual:previewBlurColor]) {
        _previewBlurColor = previewBlurColor;
        
        if (_previewAnimation) {
            _previewAnimation.backgroundTintColor = previewBlurColor;
        }
    }
}

#pragma mark - Subclass

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    // update collection view layout for new orientation
    [self applyMeasurementInformationToCollectionView:_categoryCollectionView atInterfaceOrientation:toInterfaceOrientation];
    [_categoryCollectionView.collectionViewLayout invalidateLayout];
    
    [self applyMeasurementInformationToCollectionView:_searchCollectionView atInterfaceOrientation:toInterfaceOrientation];
    [_searchCollectionView.collectionViewLayout invalidateLayout];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    // update content insets for new orientation
    [self updateContentInsetsForCollectionView:_categoryCollectionView];
    [self updateContentInsetsForCollectionView:_searchCollectionView];
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
        // setup category cell
        GiphyCategoryObject *categoryObject = [_categories objectAtIndex:indexPath.row];
        NSString *categoryName = [categoryObject localizedTitle];
        
        CGFloat defaultItemSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? kGiphyListItemSizeDefault : kGiphyListItemSizeIPad;
        cellNode = [[GiphyCategoryCollectionViewNode alloc] initWithStillURL:categoryObject.stillURL
                                                                  imageCache:_imageCache
                                                                      gifURL:!_ignoresGIFPreloadForCell ? categoryObject.gifURL : nil
                                                               preferredSize:CGSizeMake(_itemSize, _itemSize) title:[[NSAttributedString alloc] initWithString:[(categoryName ? categoryName : @"") uppercaseString] attributes:@{NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue" size:14.0f*_itemSize/defaultItemSize], NSForegroundColorAttributeName : [UIColor whiteColor]}]];
        [(GiphyCategoryCollectionViewNode*)cellNode setPlaceholderColor:_cellPlaceholderColor];
    }else if([collectionView isEqual:_searchCollectionView]){
        // setup search cell
        GiphyGIFObject *gifObject = [_searchResults objectAtIndex:indexPath.row];
        cellNode = [[GiphySearchCollectionViewNode alloc] initWithStillURL:_usesOriginalStillAsPlaceholder ? gifObject.originalStillURL : gifObject.thumbnailStillURL
                                                          imageCache:_imageCache
                                                              gifURL:!_ignoresGIFPreloadForCell ? gifObject.thumbnailGifURL : nil
                                                       preferredSize:CGSizeMake(_itemSize, _itemSize)];
        [(GiphySearchCollectionViewNode*)cellNode setPlaceholderColor:_cellPlaceholderColor];
    }
    
    return cellNode;
}

- (BOOL)shouldBatchFetchForCollectionView:(ASCollectionView *)collectionView{
    // allow next search page loading if there is any page previously loaded
    return [collectionView isEqual:_searchCollectionView] && !self.searchCancellationToken && [_searchResults count] > 0;
}

- (void)collectionView:(ASCollectionView *)collectionView willBeginBatchFetchWithContext:(ASBatchContext *)context{
    if (!self.searchCancellationToken && [_searchResults count] > 0) {
        __weak __typeof(self) weakSelf = self;
        
        // save batch context reference to cancel if needed
        self.searchBatchContext = context;
        
        // perform next page request
        self.searchCancellationToken = [[GiphyNetworkManager sharedManager] getGifsWithSearchText:_searchRequestObject.translationResult.translatedText
                                                                                       searchType:kGiphySearchTypeDescription
                                                                                           offset:[_searchResults count]
                                                                                            limit:kGiphySearchPageSize
                                                                                     successBlock:^(NSArray *gifObjectsArray){
                                                                                         if (weakSelf.searchCancellationToken) {
                                                                                             // batch was not cancelled earlier
                                                                                             weakSelf.searchCancellationToken = nil;
                                                                                             
                                                                                             if ([gifObjectsArray count] > 0) {
                                                                                                 // generate collection view paths to insert
                                                                                                 NSMutableArray *insertIndexPaths = [NSMutableArray array];
                                                                                                 for (NSInteger i = 0; i < [gifObjectsArray count]; i++) {
                                                                                                     [insertIndexPaths addObject:[NSIndexPath indexPathForRow:[weakSelf.searchResults count] + i inSection:0]];
                                                                                                 }
                                                                                                 
                                                                                                 // update local store
                                                                                                 [weakSelf.searchResults addObjectsFromArray:gifObjectsArray];
                                                                                                 
                                                                                                 // update collection view
                                                                                                 [weakSelf.searchCollectionView insertItemsAtIndexPaths:insertIndexPaths completion:nil];
                                                                                                 
                                                                                                 // complete batch request
                                                                                                 [weakSelf.searchBatchContext completeBatchFetching:[gifObjectsArray count] == kGiphySearchPageSize];
                                                                                             }else{
                                                                                                 // no objects loaded so there no remained pages to load
                                                                                                 [weakSelf.searchBatchContext completeBatchFetching:NO];
                                                                                             }
                                                                                             
                                                                                             weakSelf.searchBatchContext = nil;
                                                                                         }
                                                                                     } failureBlock:^(NSError *error){
                                                                                         // try batch later due to error
                                                                                         weakSelf.searchCancellationToken = nil;
                                                                                         
                                                                                         [weakSelf.searchBatchContext completeBatchFetching:YES];
                                                                                         weakSelf.searchBatchContext = nil;
                                                                                     }];
    }else{
        // can't perform batch now so try later
        [context completeBatchFetching:YES];
    }
}

#pragma mark - Collection View Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    if ([collectionView isEqual:_categoryCollectionView]) {
        // create search request from category
        GiphyCategoryObject *category = [_categories objectAtIndex:indexPath.row];
        NSString *translatedCategoryTitle = [category titleForLocaleCode:kGiphyDestinationLanguageCode];
        NSString *localizedCategoryTitle = [category localizedTitle];
        
        if (translatedCategoryTitle) {
            GiphyTranslationResult *translationResult = [[GiphyTranslationResult alloc] initWithResults:@[translatedCategoryTitle]
                                                                                        forOriginalText:localizedCategoryTitle
                                                                                 translatedFromLanguage:[_searchBar inputLanguageCode]
                                                                                             toLanguage:kGiphyDestinationLanguageCode];
            GiphySearchRequestObject *searchRequestObject = [[GiphySearchRequestObject alloc] initWithTranslationResult:translationResult];
            
            // switch to search interface
            [self startSearchingWithRequest:searchRequestObject animated:YES];
        }
        
    }else if ([collectionView isEqual:_searchCollectionView]){
        // pause downloading to optimize preview GIF downloading
        [[GiphyNetworkManager sharedManager] pauseRequestsForType:kGiphyRequestTypeStill];
        [[GiphyNetworkManager sharedManager] pauseRequestsForType:kGiphyRequestTypeGIF];
        
        // extract selected GIF
        GiphyGIFObject *gifObject = [_searchResults objectAtIndex:indexPath.row];
        
        // open preview controller
        GiphyPreviewViewController *giphyPreviewController = [[GiphyPreviewViewController alloc] initWithGifObject:gifObject];
        giphyPreviewController.delegate = self;
        [giphyPreviewController setModalPresentationStyle:UIModalPresentationCustom];
        [giphyPreviewController setTransitioningDelegate:self];
        [self.navigationController presentViewController:giphyPreviewController animated:YES completion:nil];
    }
}

#pragma mark - SearchBar Delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // user decided to enter search phrase so display history and cancel button
    [self showsSearchHistory:YES animated:YES];
    [self showsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    // user completed editing search phrase so close history
    [self showsSearchHistory:NO animated:YES];
    
    // if user in category list than remove cancel button thus search already cancelled
    if (_listType != kGiphyListTypeSearchResults) {
        [self showsCancelButton:NO animated:YES];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    // user started searching
    if (searchBar.text.length > 0) {
        // start searching by entered phrase and input language
        [self startSearchingWithText:searchBar.text inputLanguage:[searchBar inputLanguageCode]];
        
        // hide keyboard
        [_searchBar resignFirstResponder];
    }
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
    // complete search phrase editing
    [_searchBar resignFirstResponder];
}

#pragma mark - Preview Controller Delegate

- (void)giphyPreviewControllerDidCancel:(GiphyPreviewViewController *)giphyPreviewController{
    // resume paused downloading while preview presented
    [[GiphyNetworkManager sharedManager] resumeRequestsForType:kGiphyRequestTypeStill];
    [[GiphyNetworkManager sharedManager] resumeRequestsForType:kGiphyRequestTypeGIF];
}

- (void)giphyPreviewController:(GiphyPreviewViewController *)giphyPreviewController didSelectGIFObject:(GiphyGIFObject *)gifObject{
    // resume paused downloading while preview presented
    [[GiphyNetworkManager sharedManager] resumeRequestsForType:kGiphyRequestTypeStill];
    [[GiphyNetworkManager sharedManager] resumeRequestsForType:kGiphyRequestTypeGIF];
}

#pragma mark - Action

- (void)actionRefreshCategories:(UIRefreshControl*)refreshControl{
    // update categories list if not already in progress
    if (!self.categoriesCancellationToken) {
        [self updateCategories];
    }
}

- (void)actionRefreshSeachResults:(UIRefreshControl*)refreshControl{
    if (_searchRequestObject) {
        // update search results list if there is current user request object
        [self updateGifListWithCurrentRequest];
    }else if(_searchBar.text.length > 0){
        // update search by text phrase if there is entered text
        [self startSearchingWithText:_searchBar.text inputLanguage:[_searchBar inputLanguageCode]];
        [_searchBar resignFirstResponder];
    }else{
        // otherwise cancel update
        [refreshControl endRefreshing];
    }
}

- (void)actionSearchCancel:(UIBarButtonItem*)cancelBarButtonItem{
    if ([_searchBar isFirstResponder]) {
        // if search phrase editing active than cancel it
        [_searchBar resignFirstResponder];
    }else{
        // otherwise cancel search request and switch to categories
        [self completeSearchingAnimated:YES];
    }
}

- (void)actionCancelGifPicking:(UIBarButtonItem*)cancelBarButton{
    // post notification that user wants to cancel GIF selection
    [[NSNotificationCenter defaultCenter] postNotificationName:GiphyNavigationControllerDidCancelNotification
                                                        object:nil];
}

#pragma mark - Data

- (void)updateCategories{
    // do nothing if categories fetch in progress
    if (!self.categoriesCancellationToken) {
        
        // switch content to loading state if there is nothing previously loaded
        if (_listType == kGiphyListTypeCategories && ![self.categories count]) {
            [self setContentState:kGiphyContentStateLoading];
        }
        
        __weak __typeof(self) weakSelf = self;
        self.categoriesCancellationToken = [[GiphyNetworkManager sharedManager] getCategoriesWithSuccessBlock:^(NSArray *gifCategories){
            if (weakSelf.categoriesCancellationToken) {
                weakSelf.categoriesCancellationToken = nil;
                
                // update categories store with new data
                [weakSelf.categories removeAllObjects];
                [weakSelf.categories addObjectsFromArray:gifCategories];
                
                // update categories collection view
                [weakSelf.categoryCollectionView setContentOffset:CGPointMake(0.0f, -weakSelf.categoryCollectionView.contentInset.top)];
                
                [weakSelf clearInvisibleNodesForNodeClass:[GiphyCategoryCollectionViewNode class]];
                [weakSelf.categoryCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0] completion:nil];
                
                // if categories not found switch to error state
                if (weakSelf.listType == kGiphyListTypeCategories) {
                    if ([gifCategories count] > 0) {
                        [weakSelf setContentState:kGiphyContentStateFound];
                    }else{
                        [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyCategoriesNotFoundTitle"]];
                    }
                }
                
                // complete update
                [weakSelf.categoryRefreshControl endRefreshing];
            }
        } failureBlock:^(NSError *error){
            weakSelf.categoriesCancellationToken = nil;
            
            // display error message if content is empty
            if (weakSelf.listType == kGiphyListTypeCategories && ![weakSelf.categories count]) {
                [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyConnectionError"]];
            }
            
            [weakSelf.categoryRefreshControl endRefreshing];
        }];
    }
}

- (void)cancelCategoriesRequest{
    // cancel categories request if there is active one
    if (_categoriesCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_categoriesCancellationToken];
        _categoriesCancellationToken = nil;
    }
}

- (void)updateGifListWithCurrentRequest{
    // cancel previously search request
    [self cancelGifSearchRequest];
    
    // switch content to loading state if there is nothing previously loaded
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
                                                                                         
                                                                                         // update local store with new objects
                                                                                         [weakSelf.searchResults removeAllObjects];
                                                                                         [weakSelf.searchResults addObjectsFromArray:gifObjects];
                                                                                         
                                                                                         // update search collection view
                                                                                         [weakSelf.searchCollectionView setContentOffset:CGPointMake(0.0f, -weakSelf.searchCollectionView.contentInset.top)];
                                                                                         [weakSelf clearInvisibleNodesForNodeClass:[GiphySearchCollectionViewNode class]];
                                                                                         [weakSelf.searchCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0] completion:nil];
                                                                                         
                                                                                         // if GIFs not found than switch to error state
                                                                                         if (weakSelf.listType == kGiphyListTypeSearchResults) {
                                                                                             if ([gifObjects count] > 0) {
                                                                                                 [weakSelf setContentState:kGiphyContentStateFound];
                                                                                             }else{
                                                                                                 [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphySearchNotFoundTitle"]];
                                                                                             }
                                                                                         }
                                                                                         
                                                                                         [weakSelf.searchRefreshControl endRefreshing];
                                                                                     }
                                                                                 } failureBlock:^(NSError *error){
                                                                                     weakSelf.searchCancellationToken = nil;
                                                                                     
                                                                                     // display error message if content is empty
                                                                                     if (weakSelf.listType == kGiphyListTypeSearchResults && ![weakSelf.searchResults count]) {
                                                                                         [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyConnectionError"]];
                                                                                     }
                                                                                     
                                                                                     [weakSelf.searchRefreshControl endRefreshing];
                                                                                 }];
}

- (void)cancelGifSearchRequest{
    // cancel search fetch request
    if (_searchCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_searchCancellationToken];
        _searchCancellationToken = nil;
    }
    
    // cancel batching for search request
    if (_searchBatchContext) {
        [_searchBatchContext completeBatchFetching:NO];
        _searchBatchContext = nil;
    }
}

- (void)cancelTranslationRequest{
    // cancel translation request
    if (_translationCancellationToken) {
        [[GiphyNetworkManager sharedManager] cancelRequestForCancellationIdentifier:_translationCancellationToken];
        _translationCancellationToken = nil;
    }
}

#pragma mark - Notification

- (void)keyboardWillShowHide:(NSNotification *)notification
{
    // extract keyboard y position
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _currentKeyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
    
    // update search history view's content offset to match keyboard
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
        // add cancel button if already not exist
        UIBarButtonItem *cancelBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[GiphyBundle imageNamed:@"cancel_search_icon.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                style:UIBarButtonItemStylePlain
                                                                               target:self
                                                                               action:@selector(actionSearchCancel:)];
        [self.navigationItem setRightBarButtonItem:cancelBarButtonItem animated:animated];
    }else if (!showsCancelButton && self.navigationItem.rightBarButtonItem){
        // remove cancel button
        [self.navigationItem setRightBarButtonItem:nil animated:animated];
    }
}

- (void)showsSearchHistory:(BOOL)showsSearchHistory animated:(BOOL)animated{
    if (showsSearchHistory) {
        // update search requests from data store
        _searchRequests = [_dataManager fetchObjectsFromCollection:kGiphyDataManagerSearchRequestCollectionName];
        NSMutableArray *options = [NSMutableArray array];
        
        // create options list to display in history view
        for (GiphySearchRequestObject *searchRequest in _searchRequests) {
            if (searchRequest.translationResult.originalText.length > 0) {
                [options addObject:searchRequest.translationResult.originalText];
            }
        }
        
        // create default styled history view if not created earlier
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
        
        // don't display table view if there is no search requests
        _searchHistoryView.tableView.hidden = [options count] == 0;
        _searchHistoryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // configure content insets
        [_searchHistoryView.tableView setContentInset:UIEdgeInsetsMake(_categoryCollectionView.contentInset.top, 0.0f, self.view.bounds.size.height - _currentKeyboardY, 0.0f)];
        
        // configure content offsets
        [_searchHistoryView.tableView setContentOffset:CGPointMake(0.0f, -_categoryCollectionView.contentInset.top) animated:NO];
        
        // present search history view
        [_searchHistoryView showOnView:self.view position:CGPointMake(0.0f, 0.0f) animated:animated];
    }else if([_searchHistoryView visible]){
        // hide search history view
        [_searchHistoryView hideAnimated:animated];
        
        // clear local search requests list
        _searchRequests = nil;
    }
    
    // mark that history view responsible for "scroll to top" action
    [self updateScrollsToTop];
}

- (void)startSearchingWithText:(NSString*)text inputLanguage:(NSString*)inputLanguage{
    // cancel current translation request
    [self cancelTranslationRequest];
    
    // clear current search request
    _searchRequestObject = nil;
    
    if (![inputLanguage isEqualToString:kGiphyDestinationLanguageCode]) {
        // if input language is different from giphy support language than send translation request
        __weak __typeof(self) weakSelf = self;
        self.translationCancellationToken = [[GiphyNetworkManager sharedManager] getTranslationWithSourceText:text
                                                                                               sourceLanguage:inputLanguage
                                                                                          destinationLanguage:kGiphyDestinationLanguageCode
                                                                                                 successBlock:^(GiphyTranslationResult *translationResult){
                                                                                                     if (weakSelf.translationCancellationToken) {
                                                                                                         weakSelf.translationCancellationToken = nil;
                                                                                                         
                                                                                                         // create search request from translation result
                                                                                                         GiphySearchRequestObject *searchRequestObject = [[GiphySearchRequestObject alloc] initWithTranslationResult:translationResult];
                                                                                                         
                                                                                                         // switch to search interface
                                                                                                         [weakSelf startSearchingWithRequest:searchRequestObject
                                                                                                                                    animated:YES];
                                                                                                     }
                                                                                                 } failureBlock:^(NSError *error){
                                                                                                     // translation request failed so display error message if content is empty
                                                                                                     weakSelf.translationCancellationToken = nil;
                                                                                                     
                                                                                                     if (weakSelf.listType == kGiphyListTypeSearchResults && [weakSelf.searchResults count] == 0) {
                                                                                                         [weakSelf setContentState:kGiphyContentStateError withErrorTitle:[GiphyBundle localizedString:@"LGiphyConnectionError"]];
                                                                                                     }
                                                                                                 }];
    }else{
        // if input language as the same as supported one than just switch to search interface with new request
        GiphyTranslationResult *translationResult = [[GiphyTranslationResult alloc] initWithResults:@[text]
                                                                                    forOriginalText:text
                                                                             translatedFromLanguage:inputLanguage
                                                                                         toLanguage:kGiphyDestinationLanguageCode];
        GiphySearchRequestObject *searchRequestObject = [[GiphySearchRequestObject alloc] initWithTranslationResult:translationResult];
        [self startSearchingWithRequest:searchRequestObject animated:YES];
    }
}

- (void)startSearchingWithRequest:(GiphySearchRequestObject*)searchRequestObject animated:(BOOL)animated{
    // do nothing if there is no search request provided or it is the same is current one
    if (!searchRequestObject || [self.searchRequestObject isEqual:searchRequestObject]) {
        return;
    }
    
    // save search request to data store and mark as current
    [self updateDatastoreWithSearchRequestObject:searchRequestObject];
    [self setSearchRequestObject:searchRequestObject];
    
    // display search phrase in search bar
    [_searchBar setText:searchRequestObject.translationResult.originalText];
    
    // update list type
    if (_listType != kGiphyListTypeSearchResults) {
        _listType = kGiphyListTypeSearchResults;
        
        // display cancel button
        [self showsCancelButton:YES animated:animated];
        
        // mark that search collection view is responsible for "scroll to top" action
        [self updateScrollsToTop];
        
        // mark content state as found to clear error state
        [self setContentState:kGiphyContentStateFound];
        
        // update content inset
        _searchCollectionView.contentInset = _categoryCollectionView.contentInset;
        
        // switch from categories to search collection view
        _categoryCollectionView.hidden = YES;
        _searchCollectionView.hidden = NO;
        
        // animate transition to search state
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        
        CATransition *transitionAnimation = [CATransition animation];
        [transitionAnimation setType:kCATransitionPush];
        [transitionAnimation setSubtype:kCATransitionFromRight];
        [_contentView.layer addAnimation:transitionAnimation forKey:@"startSearchTransition"];
        
        [CATransaction commit];
    }
    
    // start loading GIFs for search request
    [self updateGifListWithCurrentRequest];
}

- (void)completeSearchingAnimated:(BOOL)animated{
    // update list type if changed
    if (_listType != kGiphyListTypeCategories) {
        _listType = kGiphyListTypeCategories;
        
        // cancel translation and search requests
        [self cancelTranslationRequest];
        [self cancelGifSearchRequest];
        
        // complete refreshing search collection view
        [self.searchRefreshControl endRefreshing];
        
        // hide search history view if visible
        if ([_searchHistoryView visible]) {
            [_searchHistoryView hideAnimated:YES];
        }
        
        // clear search bar no need to display anything
        [_searchBar setText:nil];
        
        // remove cancel button
        [self showsCancelButton:NO animated:animated];
        
        // mark that categories collection view responsible to handle status bar tap
        [self updateScrollsToTop];
        
        // mark content state as found to clear error state
        [self setContentState:kGiphyContentStateFound];
        
        // switch from categories to search collection view
        _categoryCollectionView.hidden = NO;
        _searchCollectionView.hidden = YES;
        
        // animate transition to categories state
        [CATransaction begin];
        [CATransaction setDisableActions:!animated];
        
        CATransition *transitionAnimation = [CATransition animation];
        [transitionAnimation setType:kCATransitionPush];
        [transitionAnimation setSubtype:kCATransitionFromLeft];
        [_contentView.layer addAnimation:transitionAnimation forKey:@"completeSearchTransition"];
        
        [CATransaction setCompletionBlock:^{
            if (_listType != kGiphyListTypeSearchResults) {
                // clear search results store when search collection view already hidden
                [self.searchResults removeAllObjects];
                self.searchRequestObject = nil;
                
                // clear search collection view
                [self clearInvisibleNodesForNodeClass:[GiphySearchCollectionViewNode class]];
                [_searchCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0] completion:nil];
            }
        }];
        
        [CATransaction commit];
    }
}

- (void)updateScrollsToTop{
    // mark visible scroll view to be responsible to handle "scroll to top action"
    _categoryCollectionView.scrollsToTop = (_listType == kGiphyListTypeCategories && ![_searchHistoryView visible]);
    _searchCollectionView.scrollsToTop = (_listType == kGiphyListTypeSearchResults && ![_searchHistoryView visible]);
    
    if (_searchHistoryView) {
        _searchHistoryView.tableView.scrollsToTop = [_searchHistoryView visible];
    }
}

- (BOOL)updateMeasurementInformation{
    // extract view size
    CGFloat viewWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    CGFloat viewHeight = MAX(self.view.frame.size.width, self.view.frame.size.height);
    
    // calculate aspect ration to apply if needed
    CGFloat aspectRatio = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? viewWidth/320.0f : viewWidth/768.0f;
    
    // calculate new item size based on device type
    CGFloat newItemSize = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? aspectRatio*kGiphyListItemSizeDefault : aspectRatio*kGiphyListItemSizeIPad;
    
    // calculate space between items in portrait
    CGFloat verticalItemSpace = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? (viewWidth - kGiphyListItemVerticalCountDefault*newItemSize)/(kGiphyListItemVerticalCountDefault + 1) : (viewWidth - kGiphyListItemVerticalCountIPad*newItemSize)/(kGiphyListItemVerticalCountIPad + 1);
    
    // calculate space between items in landscape
    CGFloat horizontalItemSpace = 0.0f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && viewHeight < 568.0f) {
        if (viewHeight < 568.0f) {
            // landscape space between items for iPhone 4/4s
            horizontalItemSpace = (viewHeight - kGiphyListItemHorizontalCountCompact*newItemSize)/(kGiphyListItemHorizontalCountCompact + 1);
        }else{
            // landscape space between items for any iPhone except iPhone 4/4s
            horizontalItemSpace = (viewHeight - kGiphyListItemHorizontalCountDefault*newItemSize)/(kGiphyListItemHorizontalCountDefault + 1);
        }
    }else{
        // landscape space between items for iPad
        horizontalItemSpace = (viewHeight - kGiphyListItemHorizontalCountIPad*newItemSize)/(kGiphyListItemHorizontalCountIPad + 1);
    }
    
    // flag states whether measurement information changed
    BOOL didMeasurementChange = NO;
    
    // update item's size if changed
    if (fabs(newItemSize - _itemSize) > FLT_EPSILON){
        _itemSize = newItemSize;
        didMeasurementChange = YES;
    }
    
    // update space between items in portrait orientation
    if (fabs(verticalItemSpace - _verticalItemsSpace) > FLT_EPSILON) {
        _verticalItemsSpace = verticalItemSpace;
        didMeasurementChange = YES;
    }

    // update space between items in landscape orientation
    if (fabs(horizontalItemSpace - _horizontalItemsSpace) > FLT_EPSILON) {
        _horizontalItemsSpace = horizontalItemSpace;
        didMeasurementChange = YES;
    }
    
    return didMeasurementChange;
}

- (void)applyMeasurementInformationToCollectionView:(ASCollectionView*)collectionView atInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // choose space between items based on orientation
    CGFloat itemSpace = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? _verticalItemsSpace : _horizontalItemsSpace;
    
    // apply measurement to collection view
    [(UICollectionViewFlowLayout*)collectionView.collectionViewLayout setMinimumInteritemSpacing:itemSpace];
    [(UICollectionViewFlowLayout*)collectionView.collectionViewLayout setMinimumLineSpacing:itemSpace];
    [(UICollectionViewFlowLayout*)collectionView.collectionViewLayout setSectionInset:UIEdgeInsetsMake(itemSpace, itemSpace, itemSpace, itemSpace)];
}

- (void)updateContentInsetsForCollectionView:(ASCollectionView*)collectionView{
    // calculate content inset by including bars' heights
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(CGRectGetMaxY(self.navigationController.navigationBar.frame),
                                                  0.0f,
                                                  CGRectGetHeight(self.navigationController.toolbar.frame),
                                                  0.0f);
    
    // apply content insets
    [collectionView setContentInset:contentInsets];
}

- (void)updateDatastoreWithSearchRequestObject:(GiphySearchRequestObject*)searchRequestObject{
    // move or insert search request object to top in history list
    if (searchRequestObject) {
        [_dataManager removeObject:searchRequestObject forCollection:kGiphyDataManagerSearchRequestCollectionName];
        [_dataManager addObject:searchRequestObject forCollection:kGiphyDataManagerSearchRequestCollectionName];
    }
}

- (void)clearInvisibleNodesForNodeClass:(Class)nodeClass{
    UIWindow *window = [[ASRangeHandlerRender class] performSelector:NSSelectorFromString(@"workingWindow")];
    for (UIView *view in [window subviews]) {
        if ([view isKindOfClass:[_ASDisplayView class]]) {
            ASDisplayNode *node = [view performSelector:@selector(asyncdisplaykit_node)];
            if ([node isKindOfClass:nodeClass]) {
                if (node.isNodeLoaded) {
                    if (node.layerBacked) {
                        [node.layer removeFromSuperlayer];
                    } else {
                        [node.view removeFromSuperview];
                    }
                }
            }
        }
    }
}

@end

//
//  SearchViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "SearchViewController.h"
#import "GradientView.h"
#import "UIImage+Ext.h"
#import "RegsStyle.h"
#import "DocketViewController.h"
#import "DocumentViewController.h"
#import "EntityViewController.h"
#import "RegulationsGovClient.h"


#import "RWDropdownMenu/RWDropdownMenu.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <Reader/ReaderViewController.h>

#import "RegsClient.h"

#define SEARCH_BAR_HEIGHT 42

#define IF_NOT_EXISTS(a, b) a ? a : b

typedef NS_ENUM (NSInteger, SearchTypeIndex) {
    SearchTypeDocket = 0,
    SearchTypeDocument,
    SearchTypeFederalRegister,
    SearchTypeNonFederalRegister,
    SearchTypePresidentialDocuments,
    SearchTypeExecutiveOrders,
    SearchTypeEntity
};

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ReaderViewControllerDelegate>

@property (nonatomic) SearchTypeIndex selectedType;
@property (nonatomic) BOOL loading;
@property (nonatomic, copy) NSString *nextPage;

@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIButton *toggleTypeButton;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) NSArray *buttonImages;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, strong) RWDropdownMenu *dropdown;
@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;

@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicatorView;
@property (nonatomic, strong) SVProgressHUD *loadingIndicator;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedType = SearchTypeDocket;
    [self setupView];
    [self updateViewConstraints];
    self.encapsulatedTableView.hidden = YES;
    self.title = @"Finder";
    self.loading = NO;
    [self clear:nil];
    [self.containerView addGestureRecognizer:self.tapGestureRecognizer];
    
}

- (void) setupView {
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.encapsulatedTableView];
    [self.containerView addSubview:self.searchBar];
    _searchField.rightView = self.clearButton;
    
}

- (void) updateViewConstraints {
    
    
    [self.encapsulatedTableView setNeedsLayout];
    
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = TRUE;
        
        [self.searchBar autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.searchBar autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.searchBar autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];
        [self.searchBar autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.searchBar autoSetDimension:ALDimensionHeight toSize:SEARCH_BAR_HEIGHT];
        
        [self.encapsulatedTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.searchBar withOffset:-1];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];
        
        [self.toggleTypeButton autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.toggleTypeButton autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5.0];
        [self.toggleTypeButton autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5.0];
        [self.toggleTypeButton autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.toggleTypeButton];
        
        [self.searchField autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.toggleTypeButton withOffset:5];
        [self.searchField autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.searchBar withOffset:-5];
        [self.searchField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [self.searchField autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
        
    }
    
    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITextField *) searchField {
    if(!_searchField) {
        _searchField = [[UITextField alloc] init];
        _searchField.backgroundColor = [UIColor whiteColor];
        _searchField.placeholder = @"Search Dockets";
        _searchField.font = [RegsStyle searchTextFont];
        _searchField.translatesAutoresizingMaskIntoConstraints = NO;
        _searchField.delegate = self;
        _searchField.keyboardAppearance = UIKeyboardAppearanceLight;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _searchField;
}

-(UIButton *)clearButton {
    if(!_clearButton) {
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _clearButton.backgroundColor = [UIColor clearColor];
        [_clearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
        [_clearButton setImage:[[UIImage imageNamed:@"multiply-symbol-mini"] imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    return _clearButton;
}

-(UIView *)searchBar {
    if(!_searchBar) {
        _searchBar = [[UIView alloc] initWithFrame:CGRectZero];
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBar.layer.borderWidth = 1;
        _searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _searchBar.backgroundColor = [UIColor whiteColor];
        [_searchBar addSubview:self.searchField];
        [_searchBar addSubview:self.toggleTypeButton];
    }
    
    
    return _searchBar;
}

-(EncapsulatedTableView *) encapsulatedTableView {
    if(!_encapsulatedTableView) {
        _encapsulatedTableView = [[EncapsulatedTableView alloc] init];
        _encapsulatedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _encapsulatedTableView.tableView.dataSource = self;
        _encapsulatedTableView.tableView.delegate = self;
        _encapsulatedTableView.tableView.rowHeight = 60.;
        _encapsulatedTableView.tableView.bounces = YES;
    }
    return _encapsulatedTableView;
}

-(NSArray *)buttonImages {
    if(!_buttonImages) {
        _buttonImages = @[
                          [[UIImage imageNamed:@"document-multiple"] imageWithColor:[RegsStyle darkBackgroundColor]],
                            [[UIImage imageNamed:@"document"] imageWithColor:[RegsStyle darkBackgroundColor]],
                            [[UIImage imageNamed:@"bank"] imageWithColor:[RegsStyle darkBackgroundColor]],
                            [[UIImage imageNamed:@"booklet"] imageWithColor:[RegsStyle darkBackgroundColor]],
                          [[UIImage imageNamed:@"dot-multiple-mini"] imageWithColor:[RegsStyle darkBackgroundColor]],
                          [[UIImage imageNamed:@"document-scroll"] imageWithColor:[RegsStyle darkBackgroundColor]],
                          [[UIImage imageNamed:@"pen-fountain-mini"] imageWithColor:[RegsStyle darkBackgroundColor]]
                              ];
    }
    return _buttonImages;
}
-(UIButton *)toggleTypeButton {
    if(!_toggleTypeButton) {
        _toggleTypeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _toggleTypeButton.translatesAutoresizingMaskIntoConstraints = NO;
        _toggleTypeButton.backgroundColor = [UIColor clearColor];
        [_toggleTypeButton addTarget:self action:@selector(showDropdown:) forControlEvents:UIControlEventTouchUpInside];
        [_toggleTypeButton setImage:self.buttonImages[0] forState:UIControlStateNormal];
    }
    return _toggleTypeButton;
}


-(void) showDropdown:(id)sender {
    
    __weak typeof(self) _self = self;

    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithText:@"Dockets"
                                 image:[self.buttonImages[0] imageWithColor:[UIColor whiteColor]]
                                action:^{
                                    _self.selectedType = SearchTypeDocket;
                                    [_self clear:nil];
                                    [_self.results removeAllObjects];
                                    [_self.encapsulatedTableView.tableView reloadData];
                                    [_self updateViewConstraints];
                                    [_self.toggleTypeButton setImage:self.buttonImages[0] forState:UIControlStateNormal];
                                }],
      [RWDropdownMenuItem itemWithText:@"Documents"
                                 image:[self.buttonImages[1] imageWithColor:[UIColor whiteColor]]
                                action:^{
                                    _self.selectedType = SearchTypeDocument;
                                    [_self clear:nil];
                                    [_self.results removeAllObjects];
                                    [_self.encapsulatedTableView.tableView reloadData];
                                    [_self updateViewConstraints];
                                    [_self.toggleTypeButton setImage:self.buttonImages[1] forState:UIControlStateNormal];
                                    
                                }],
    
    [RWDropdownMenuItem itemWithText:@"Federal Register Documents"
                               image:[self.buttonImages[3] imageWithColor:[UIColor whiteColor]]
                              action:^{
                                  _self.selectedType = SearchTypeFederalRegister;
                                  [_self clear:nil];
                                  [_self.results removeAllObjects];
                                  [_self.encapsulatedTableView.tableView reloadData];
                                  [_self updateViewConstraints];
                                  [_self.toggleTypeButton setImage:self.buttonImages[3] forState:UIControlStateNormal];
                              }],
    
    [RWDropdownMenuItem itemWithText:@"Non-Federal Register Documents"
                               image:[self.buttonImages[4] imageWithColor:[UIColor whiteColor]]
                              action:^{
                                  _self.selectedType = SearchTypeNonFederalRegister;
                                  [_self clear:nil];
                                  [_self.results removeAllObjects];
                                  [_self.encapsulatedTableView.tableView reloadData];
                                  [_self updateViewConstraints];
                                  [_self.toggleTypeButton setImage:self.buttonImages[4] forState:UIControlStateNormal];
                              }],
    
    [RWDropdownMenuItem itemWithText:@"Presidential Documents"
                               image:[self.buttonImages[5] imageWithColor:[UIColor whiteColor]]
                              action:^{
                                  _self.selectedType = SearchTypePresidentialDocuments;
                                  [_self clear:nil];
                                  [_self.results removeAllObjects];
                                  [_self.encapsulatedTableView.tableView reloadData];
                                  [_self updateViewConstraints];
                                  [_self.toggleTypeButton setImage:self.buttonImages[5] forState:UIControlStateNormal];
                              }],
      [RWDropdownMenuItem itemWithText:@"Executive Orders"
                                 image:[self.buttonImages[6] imageWithColor:[UIColor whiteColor]]
                                action:^{
                                    _self.selectedType = SearchTypeExecutiveOrders;
                                    [_self clear:nil];
                                    [_self.results removeAllObjects];
                                    [_self.encapsulatedTableView.tableView reloadData];
                                    [_self updateViewConstraints];
                                    [_self.toggleTypeButton setImage:self.buttonImages[6] forState:UIControlStateNormal];
                                }],
    ];
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentLeft style:RWDropdownMenuStyleTranslucent navBarImage:nil completion:nil];
}

-(void) clearText:(id)sender {
    [self clear:sender];
    self.searchField.text = @"";
}
-(void) clear:(id)sender {
    
    NSString *search = @"Search ";
    NSString *typeString;
    
    switch (self.selectedType) {
        case SearchTypeDocket:
            typeString = @"Dockets";
            break;
        case SearchTypeDocument:
            typeString = @"Documents";
            break;
        case SearchTypeFederalRegister:
            typeString = @"Federal Register Documents";
            break;
        case SearchTypeNonFederalRegister:
            typeString = @"Non-Federal Register Documents";
            break;
        case SearchTypePresidentialDocuments:
            typeString = @"Presidential Documents";
            break;
        case SearchTypeExecutiveOrders:
            typeString = @"Executive Orders";
            break;
        case SearchTypeEntity:
            typeString = @"Entities";
            break;
        default:
            typeString = @"";
            break;
    
    }
    
    self.searchField.placeholder = [search stringByAppendingString:typeString];
}

-(void) executeSearch {
    
    if(![RegsClient checkInternetConnection]) return;
    
    self.encapsulatedTableView.hidden = YES;
    
    __weak typeof(self) _self = self;
    
    void (^success)(AFHTTPRequestOperation *, id);
    
    success = ^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        _self.results = [[(NSDictionary *)responseObject objectForKey:@"results"] mutableCopy];
        _self.nextPage = [(NSDictionary *)responseObject objectForKey:@"next"];
        _self.encapsulatedTableView.hidden = NO;
        [_self.encapsulatedTableView.tableView reloadData];
        [_self updateViewConstraints];
        [_self.searchField resignFirstResponder];
    };
    void (^failure)(id, NSError *);
    
    failure = ^(AFHTTPRequestOperation *operation, NSError * error) {
        [SVProgressHUD showErrorWithStatus:@"Search Failed" maskType:SVProgressHUDMaskTypeGradient];
    };
    
    
    switch (self.selectedType) {
        case SearchTypeDocket: {
            
                [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
                [[RegsClient sharedClient] searchDocket:self.searchField.text success:success failure:failure];
            } break;
        
        case SearchTypeDocument: {
                [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
                [[RegsClient sharedClient] searchDocument:self.searchField.text success:success failure:failure];
                
            } break;
            
        case SearchTypeEntity: {
                [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
                [[RegsClient sharedClient] searchEntity:self.searchField.text success:success failure:failure];
            } break;
            
        case SearchTypeFederalRegister: {
                [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
                [[RegsClient sharedClient] searchFederalRegister:self.searchField.text success:success failure:failure];
            } break;
        
        case SearchTypeNonFederalRegister: {
                [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
            [[RegsClient sharedClient] searchNonFederalRegister:self.searchField.text success:success failure:failure];
            } break;
        
        case SearchTypePresidentialDocuments: {
            
            [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
            
            [[RegulationsGovClient sharedClient] searchPresidentialDocumentsWithTerm:self.searchField.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [SVProgressHUD dismiss];
                _self.results = [[(NSDictionary *)responseObject objectForKey:@"results"] mutableCopy];
                _self.nextPage = [(NSDictionary *)responseObject objectForKey:@"next_page_url"];
                _self.encapsulatedTableView.hidden = NO;
                [_self.encapsulatedTableView.tableView reloadData];
                [_self updateViewConstraints];
                [_self.searchField resignFirstResponder];
            } failure:failure];
        } break;
            
        case SearchTypeExecutiveOrders: {
            [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
            [[RegulationsGovClient sharedClient] searchExecutiveOrdersWithTerm:self.searchField.text success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [SVProgressHUD dismiss];
                _self.results = [[(NSDictionary *)responseObject objectForKey:@"results"] mutableCopy];
                _self.nextPage = [(NSDictionary *)responseObject objectForKey:@"next_page_url"];
                _self.encapsulatedTableView.hidden = NO;
                [_self.encapsulatedTableView.tableView reloadData];
                [_self updateViewConstraints];
                [_self.searchField resignFirstResponder];
            } failure:failure];
        }
            
        default:
            break;
    }
}

-(void) tableViewRefreshWithShow:(BOOL)yesOrNo {
    if(yesOrNo) {
        self.encapsulatedTableView.hidden = YES;
    } else self.encapsulatedTableView.hidden = NO;
    
    [self.encapsulatedTableView.tableView reloadData];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self executeSearch];
    return YES;
}

#pragma mark - Tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.results.count; }

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.font = [RegsStyle titleLabelFont];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [RegsStyle summaryTextFont];
    }
    
    NSDictionary *item = self.results[indexPath.row];
    NSDictionary *_item = [self mapItemToCell:item];
    cell.textLabel.text = _item[@"title"];
    cell.detailTextLabel.text = _item[@"subtitle"];
    return cell;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(!self.loading)
    {
        if(![RegsClient checkInternetConnection]) return;
        
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets edgeInsets = scrollView.contentInset;
        
        float y = offset.y+bounds.size.height - edgeInsets.bottom;
        float h = size.height;
        
        float threshold = 15;
        
        if((self.nextPage.length > 0) && (y > h + threshold))
        {
            [self loadNextPage];
            self.loading = YES;
        }
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(![RegsClient checkInternetConnection]) return;
    
    NSDictionary *item = self.results[indexPath.row];
   
    NSString *_id = [item[@"url"] lastPathComponent];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    if([item[@"_type"] isEqualToString:@"docket"]) {
        
        [[RegsClient sharedClient] getDocket:_id success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.encapsulatedTableView.tableView deselectRowAtIndexPath:indexPath animated:NO];
            if(responseObject) {
                [SVProgressHUD dismiss];
                DocketViewController *nextController = [[DocketViewController alloc] init];
                nextController.item = responseObject;
                nextController.title = item[@"_id"];
                [self.navigationController pushViewController:nextController animated:YES];
          
            }
            else [SVProgressHUD showErrorWithStatus:@"Error loading docket" maskType:SVProgressHUDMaskTypeGradient];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error loading docket" maskType:SVProgressHUDMaskTypeGradient];
        }];
        
    } else if ([item[@"_type"] isEqualToString:@"document"]) {
        
        [[RegsClient sharedClient] getDocument:_id success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.encapsulatedTableView.tableView deselectRowAtIndexPath:indexPath animated:NO];
            if(responseObject) {
                [SVProgressHUD dismiss];
                DocumentViewController *nextController = [[DocumentViewController alloc] init];
                nextController.item = responseObject;
                nextController.title = item[@"_id"];
                [self.navigationController pushViewController:nextController animated:YES];
                
            }
            else [SVProgressHUD showErrorWithStatus:@"Error loading document" maskType:SVProgressHUDMaskTypeGradient];
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error loading document" maskType:SVProgressHUDMaskTypeGradient];
        }];
    } else if ([item[@"_type"] isEqualToString:@"entity"]) {
        [[RegsClient sharedClient] getEntity:_id success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.encapsulatedTableView.tableView deselectRowAtIndexPath:indexPath animated:NO];
            if(responseObject) {
                [SVProgressHUD dismiss];
                EntityViewController *nextController = [[EntityViewController alloc] init];
                nextController.item = responseObject;
                nextController.title = item[@"_id"];
                nextController.entity = item[@"_id"];
                [self.navigationController pushViewController:nextController animated:YES];
            }
            else [SVProgressHUD showErrorWithStatus:@"Error loading entity" maskType:SVProgressHUDMaskTypeGradient];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error loading entity" maskType:SVProgressHUDMaskTypeGradient];
        }];
        
    } else if ([item[@"type"] isEqualToString:@"Presidential Document"]) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        
        NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@.%@", item[@"citation"], @"pdf"]];
        NSURL *url = [NSURL URLWithString:item[@"pdf_url"]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:[NSURLRequest requestWithURL:url]];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(!responseObject) {
                [SVProgressHUD showErrorWithStatus:@"Error: No document."];
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            } else {
                
                [SVProgressHUD dismiss];
                [responseObject writeToFile:tempPath atomically:YES];
                ReaderDocument *readerDocument = [[ReaderDocument alloc] initWithFilePath:tempPath password:nil];
                ReaderViewController *modalViewController = [[ReaderViewController alloc] initWithReaderDocument:readerDocument];
                modalViewController.delegate = self;
                [self presentViewController:modalViewController animated:YES completion:^{
                    
                    [tableView deselectRowAtIndexPath:indexPath animated:NO];
                }];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:@"Error"];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }];
        [operation start];
    
    }
}
-(NSDictionary *)mapItemToCell:(NSDictionary *)item {
    
    NSDictionary *_item;
    
    if(item[@"_type"]) {
        if([item[@"_type"] isEqualToString:@"docket"]) {
            _item = @{
                      @"title":IF_NOT_EXISTS(item[@"fields"][@"title"], @""),
                      @"subtitle":IF_NOT_EXISTS(item[@"fields"][@"docket_id"], @"")
                      };
        } else if ([item[@"_type"] isEqualToString:@"document"]) {
            
            _item = @{
                      @"title":IF_NOT_EXISTS(item[@"fields"][@"title"], @""),
                      @"subtitle":IF_NOT_EXISTS(item[@"_id"], @"")
                      };
        } else if ([item[@"_type"] isEqualToString:@"entity"]) {
            
            _item = @{
                      @"title":IF_NOT_EXISTS(item[@"fields"][@"name"], @""),
                      @"subtitle":IF_NOT_EXISTS(item[@"_id"], @"")
                      };
            
        }
    }
    else if (item[@"type"]) {
        if([item[@"type"] isEqualToString:@"Presidential Document"]) {
            _item = @{
                      @"title":item[@"title"],
                      @"subtitle":item[@"citation"]
                      };
            
        }
    }

    
    return _item;
}

- (UITapGestureRecognizer *) tapGestureRecognizer {
    if(!_tapGestureRecognizer) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        _tapGestureRecognizer.numberOfTapsRequired = 1;
        _tapGestureRecognizer.cancelsTouchesInView = NO;
        [self.containerView addGestureRecognizer:_tapGestureRecognizer];
    }
    return _tapGestureRecognizer;
}

- (void) didTap:(id)sender { [self.searchField resignFirstResponder]; }

-(void) loadNextPage {
    
    if(self.nextPage && self.results && !self.loading) {
        
        self.loading = YES;
        
        if(![RegsClient checkInternetConnection]) return;
        
        [SVProgressHUD showWithStatus:@"Loading additional entries" maskType:SVProgressHUDMaskTypeGradient];

        __weak typeof(self) _self = self;
        
        void (^success)(AFHTTPRequestOperation *, id);
        
        success = ^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray *more = [(NSDictionary *)responseObject objectForKey:@"results"];
            if(more.count == 0) {
                _self.nextPage = nil;
            } else {
                [_self.results addObjectsFromArray:more];
                
                if([(NSDictionary *)responseObject objectForKey:@"next"]) {
                    _self.nextPage = [(NSDictionary *)responseObject objectForKey:@"next"];
                } else if ([(NSDictionary *)responseObject objectForKey:@"next_page_url"]) {
                    _self.nextPage = [(NSDictionary *)responseObject objectForKey:@"next"];
                }
                [_self.encapsulatedTableView.tableView reloadData];
                [_self updateViewConstraints];
                _self.loading = NO;
                [SVProgressHUD dismiss];
            }
            
        };
        
        [[RegsClient sharedClient] get:self.nextPage success:success failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            self.loading = NO;
            [SVProgressHUD dismiss];
        }];
    }
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

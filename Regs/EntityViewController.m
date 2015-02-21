//
//  EntityViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "EntityViewController.h"
#import <HMSegmentedControl/HMSegmentedControl.h>
#import "UIColor+Custom.h"
#import "BookmarkManager.h"
#import "RegsStyle.h"
#import "RegsClient.h"
#import "SearchBar.h"
#import "UIImage+Ext.h"
#import "DocumentViewController.h"
#import "DocketViewController.h"
#import <SVProgressHUD/SVProgressHUD.h>

#define SEARCH_BAR_HEIGHT 42
#define MODE_BAR_HEIGHT 28

@interface EntityViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITableView *topDocketsTableView;
@property (nonatomic, strong) UITableView *topCommentsTableView;
@property (nonatomic, strong) UITableView *allDocketsTableView;
@property (nonatomic, strong) UITableView *allDocumentsTableView;
@property (nonatomic, strong) NSArray *searchBars;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, weak) UITableView *activeTableView;
@property (nonatomic, strong) NSArray *tableViews;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableArray *results;
@property (nonatomic, copy) NSString *nextPage;

@property (nonatomic, strong) GradientView *containerView;

//top dockets, submitter mentions, top agencies, recent comments
@end

@implementation EntityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self bookmarkButton];
    self.name = self.item[@"name"];
    self.title = self.name;
    self.activeTableView = self.tableViews[0];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.segmentedControl];
    
    for(UITableView *tableView in self.tableViews) {
        [self.containerView addSubview:tableView];
    }
    
    [self setTitleView:self.name subtitle:nil];
    [self setConstraints];
    [self.segmentedControl setSelectedSegmentIndex:0];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setConstraints {
    //Mode bar
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:0
                                                                    constant:MODE_BAR_HEIGHT]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:.95
                                                                    constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:self.segmentedControl
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                       
                                                                    constant:10]];
    
    
    for(UITableView *tableView in self.tableViews) {
        [self constrainTable:tableView];
    }
    
}

- (CGFloat) allDocketsTableViewHeight {
    CGFloat h = self.results.count * self.allDocketsTableView.rowHeight;
    return  h > self.containerView.frame.size.height - 20 ? -1 : h;
}

-(void) constrainTable:(UITableView *)tableView {
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.segmentedControl
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:-1]];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.segmentedControl
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:0]];
    
    NSInteger numberOfRows = [self tableView:tableView numberOfRowsInSection:0];
    
    [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.containerView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1
                                                                    constant:0]];
    
    if([self.tableViews indexOfObject:tableView] < 3) {
        [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                       attribute:NSLayoutAttributeHeight
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self.segmentedControl
                                                                       attribute:NSLayoutAttributeHeight
                                                                      multiplier:0
                                                                        constant:numberOfRows * tableView.rowHeight]];
    } else {
        CGFloat tvHeight = [self tableViewHeight:tableView];
        if(tvHeight > -1) {
            [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                           attribute:NSLayoutAttributeHeight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.containerView
                                                                           attribute:NSLayoutAttributeHeight
                                                                          multiplier:0
                                                                            constant:tvHeight + SEARCH_BAR_HEIGHT - 1]];
        } else {
            [self.containerView addConstraint:[NSLayoutConstraint constraintWithItem:tableView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.containerView
                                                                           attribute:NSLayoutAttributeCenterY
                                                                          multiplier:1
                                                                            constant:SEARCH_BAR_HEIGHT/2. - 1]];
        }
    }
    
    
    
    
}

- (CGFloat) tableViewHeight:(UITableView *)tableView {
    NSInteger idx = [self.tableViews indexOfObject:tableView];
    CGFloat h = [self.data[idx] count] * tableView.rowHeight;
    return  h > self.containerView.frame.size.height - 20 ? -1 : h;
}

-(UITableView *) topCommentsTableView {
    
    if(!_topCommentsTableView) {
        _topCommentsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _topCommentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _topCommentsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _topCommentsTableView.dataSource = self;
        _topCommentsTableView.delegate = self;
        _topCommentsTableView.layer.borderWidth = 1;
        _topCommentsTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _topCommentsTableView.rowHeight = 45;
    }
    
    return _topCommentsTableView;
}

-(UITableView *) topDocketsTableView {
    
    if(!_topDocketsTableView) {
        _topDocketsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _topDocketsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _topDocketsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _topDocketsTableView.dataSource = self;
        _topDocketsTableView.delegate = self;
        _topDocketsTableView.layer.borderWidth = 1;
        _topDocketsTableView.hidden = NO;
        _topDocketsTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _topDocketsTableView.rowHeight = 45;
    }
    
    return _topDocketsTableView;
}

-(UITableView *) allDocketsTableView {
    
    if(!_allDocketsTableView) {
        _allDocketsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _allDocketsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _allDocketsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _allDocketsTableView.dataSource = self;
        _allDocketsTableView.delegate = self;
        _allDocketsTableView.hidden = YES;
        _allDocketsTableView.layer.borderWidth = 1;
        _allDocketsTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _allDocketsTableView.rowHeight = 45;
        _allDocketsTableView.tableHeaderView = self.searchBars[0];
        
    }
    
    return _allDocketsTableView;
}

-(UITableView *) allDocumentsTableView {
    
    if(!_allDocumentsTableView) {
        _allDocumentsTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _allDocumentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _allDocumentsTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _allDocumentsTableView.dataSource = self;
        _allDocumentsTableView.delegate = self;
        _allDocumentsTableView.hidden = YES;
        _allDocumentsTableView.layer.borderWidth = 1;
        _allDocumentsTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _allDocumentsTableView.rowHeight = 45;
        _allDocumentsTableView.tableHeaderView = self.searchBars[1];
        
    }
    
    return _allDocumentsTableView;
}

-(UIView *)searchBarWithPlaceholder:(NSString *)p {
    SearchBar *bar = [[SearchBar alloc] initWithFrame:CGRectMake(0, 0, self.allDocketsTableView.frame.size.width, SEARCH_BAR_HEIGHT)];
    bar.searchField.delegate = self;
    [bar.clearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    bar.searchField.placeholder = p;
    return bar;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self executeSearch:textField];
    return YES;
}

-(void) clearText:(id)sender {
    UITextField *textField = (UITextField *)[sender superview];
    textField.text = @"";
}

- (void) executeSearch:(UITextField *)sender {
    __weak typeof(self) weakSelf = self;
    [SVProgressHUD showWithStatus:@"Searching..." maskType:SVProgressHUDMaskTypeGradient];
    NSString *query = [NSString stringWithFormat:@"submitter:%@ %@", weakSelf.entity, sender.text];
    if(sender == [self.searchBars[0] searchField]) {
        [[RegsClient sharedClient] searchDocket:query success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [weakSelf.results[0] removeAllObjects];
            [weakSelf.results[0] addObjectsFromArray:[(NSDictionary *)responseObject objectForKey:@"results"]];
            weakSelf.nextPage = [(NSDictionary *)responseObject objectForKey:@"next"];
            [weakSelf.allDocketsTableView reloadData];
            [weakSelf.containerView removeConstraints:self.containerView.constraints];
            [weakSelf setConstraints];
            [weakSelf.containerView setNeedsUpdateConstraints];
            [sender resignFirstResponder];
            weakSelf.allDocketsTableView.hidden = NO;
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
            
        }];
    } else {
        [[RegsClient sharedClient] searchDocument:query success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [weakSelf.results[1] removeAllObjects];
            [weakSelf.results[1] addObjectsFromArray:[(NSDictionary *)responseObject objectForKey:@"results"]];
            weakSelf.nextPage = [(NSDictionary *)responseObject objectForKey:@"next"];
            [weakSelf.allDocumentsTableView reloadData];
            [weakSelf.containerView removeConstraints:self.containerView.constraints];
            [weakSelf setConstraints];
            [weakSelf.containerView setNeedsUpdateConstraints];
            [sender resignFirstResponder];
            weakSelf.allDocumentsTableView.hidden = NO;
            [SVProgressHUD dismiss];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
            
        }];
    }
}
-(HMSegmentedControl *)segmentedControl {
    if(!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectZero];
        _segmentedControl.sectionTitles = @[@"Top Dockets", @"Top Agencies", @"Recent Comments", @"All Dockets", @"All Documents"];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        _segmentedControl.textColor = [UIColor darkGrayColor];
        _segmentedControl.selectedTextColor = [UIColor blackColor];
        _segmentedControl.font = [RegsStyle segmentedControlFont];
        _segmentedControl.selectionIndicatorColor = [RegsStyle secondaryLineColor];
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
        _segmentedControl.layer.borderWidth = 1;
        _segmentedControl.layer.borderColor = [UIColor lightGrayColor].CGColor;
        __weak typeof(self) weakSelf = self;
        [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
            weakSelf.activeTableView.hidden = YES;
            weakSelf.activeTableView = weakSelf.tableViews[index];
            weakSelf.activeTableView.hidden = NO;
        }];
    }
    return _segmentedControl;
}

-(NSMutableArray *)data {
    if(!_data) {
        
        _data = [NSMutableArray array];
        
        NSDictionary *stats = self.item[@"stats"];
        NSArray *topKeys = @[@"text_mentions", @"submitter_mentions"];
        NSArray *nextKeys = @[@"top_dockets", @"top_agencies", @"recent_comments"];
        
        for(int i = 0; i < nextKeys.count; ++i) {
            
            [_data addObject:[NSMutableArray array]];
            
            for(int j = 0; j < topKeys.count; ++j) {
                [_data[i] addObject:[NSMutableArray array]];
                id obj = stats[topKeys[j]][nextKeys[i]];
                if(obj) _data[i][j] = obj;
            }
        }
        
        [_data addObject:self.results[0]];
        [_data addObject:self.results[1]];
        
    }
    
    return _data;
}

-(NSMutableArray *)results {
    if(!_results) {
        _results = [@[[NSMutableArray array], [NSMutableArray array]] mutableCopy];
    }
    return _results;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if([self.tableViews indexOfObject:tableView] < 3) return 2;
    else return 1;
}

-(NSArray *) tableViews {
    if(!_tableViews) {
        _tableViews = @[ self.topDocketsTableView, self.topCommentsTableView, self.allDocketsTableView, self.allDocumentsTableView];
    }
    return _tableViews;
}

-(NSArray *) searchBars {
    if(!_searchBars) {
        _searchBars = @[[self searchBarWithPlaceholder:[NSString stringWithFormat:@"Search %@ Dockets", self.title]], [self searchBarWithPlaceholder:[NSString stringWithFormat:@"Search %@ Documents", self.title]]];
    }
    return _searchBars;
}


-(CGFloat) tableViewHeight {
    NSInteger r = 0, s = 0;
    for(NSArray *section in self.data[2]) {
        if(section.count > 0) s++;
        r+=section.count;
    }
    
    CGFloat h = r * self.topCommentsTableView.rowHeight + s * 20.;
    return  h > self.containerView.frame.size.height - 20 ? -1 : h;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger index = [self.tableViews indexOfObject:tableView];
    
    if(index < 3) return [self.data[index][section] count];
    else return [self.data[index] count];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"Header"];
    
    if(headerFooterView == nil) {
        headerFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"Header"];
    }
    
    return headerFooterView;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *thv = (UITableViewHeaderFooterView *)view;
        thv.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:10];
        thv.contentView.tintColor = [UIColor lightGrayColor];
        thv.textLabel.text = section == 0 ? @"Text Mentions" : @"Submitter Mentions";
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    if(section > 2) return 0;
    if([self.tableViews indexOfObject:tableView]) return 0;
    return ([self.data[section] count] == 0) ? 0 : 20;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSInteger tableIndex = [self.tableViews indexOfObject:tableView];
   
    NSDictionary *item = tableIndex < 3 ? self.data[tableIndex][indexPath.section][indexPath.row] : self.data[tableIndex][indexPath.row];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Thin" size:12];
    }
    
    NSDictionary *mappedItem = [self mapItemToCell:item tableIndex:tableIndex];
    cell.textLabel.text = mappedItem[@"title"];
    cell.detailTextLabel.text = mappedItem[@"subtitle"];
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger tableIndex = [self.tableViews indexOfObject:tableView];
    NSDictionary *item = tableIndex < 3 ? self.data[tableIndex][indexPath.section][indexPath.row] : self.data[tableIndex][indexPath.row];
    switch(tableIndex) {
        case 0:
        case 2:
            {
            NSString *_id = [item[@"url"] lastPathComponent];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];

            [[RegsClient sharedClient] getDocket:_id success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
                
                if(responseObject) {
                    [SVProgressHUD dismiss];
                    DocketViewController *nextController = [[DocketViewController alloc] init];
                    nextController.item = responseObject;
                    nextController.title = item[@"id"];
                    [self.navigationController pushViewController:nextController animated:NO];
                    
                }
                else [SVProgressHUD showErrorWithStatus:@"Error loading docket" maskType:SVProgressHUDMaskTypeGradient];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Error loading docket" maskType:SVProgressHUDMaskTypeGradient];
            }];
        }
        break;
        case 1:
        case 3: {
            NSString *docID = item[@"id"];
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            [[RegsClient sharedClient] getDocument:docID success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [SVProgressHUD dismiss];
                DocumentViewController *nextController = [[DocumentViewController alloc] init];
                nextController.summary = item[@"summary"];
                nextController.item = responseObject;
                nextController.hideDocket = YES;
                [self.navigationController pushViewController:nextController animated:YES];
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
            }]; }
        break;
        
    }
}

-(UIBarButtonItem *) bookmarkButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark-small-mini"] style:UIBarButtonItemStylePlain target:self action:@selector(addBookmark:)];
}

-(void) addBookmark:(id)sender {
    [[BookmarkManager sharedManager] add:self.item as:BookmarkTypeEntity];
}


-(NSDictionary *)mapItemToCell:(NSDictionary *)item tableIndex:(NSInteger)index {
    
    NSDictionary *_item;
    
    if(!item) return nil;
    
    if (index == 1) {
        _item = @{
                  @"title": item[@"id"],
                  @"subtitle": item[@"name"]
                  };

    } else {
        if([item[@"_type"] isEqualToString:@"docket"]) {
            _item = @{
                      @"title": item[@"fields"][@"title"],
                      @"subtitle": item[@"_id"]
                      };
        } else if ([item[@"_type"] isEqualToString:@"document"]) {
            _item = @{
                      @"title": item[@"fields"][@"title"],
                      @"subtitle": [item[@"url"] lastPathComponent]
                      };
        } else {
            _item = @{
                      @"title": item[@"title"],
                      @"subtitle": item[@"id"]
                      };

        }

    }
    return _item;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

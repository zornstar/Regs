//
//  BookmarkViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "BookmarkViewController.h"
#import "GradientView.h"
#import "EntityViewController.h"
#import "DocketViewController.h"
#import "DocumentViewController.h"
#import "UIColor+Custom.h"
#import "RegsClient.h"
#import "BookmarkManager.h"
#import "RegsStyle.h"
#import <HMSegmentedControl/HMSegmentedControl.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define MODE_BAR_HEIGHT 28

@interface BookmarkViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) NSMutableDictionary *bookmarks;
@property (nonatomic, strong) NSArray *encapsulatedTableViews;
@property (nonatomic, weak) EncapsulatedTableView *activeEncapsulatedTableView;
@property (nonatomic, strong) GradientView *containerView;

@end

@implementation BookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Bookmarks";
    self.didSetupConstraints = NO;
    self.activeEncapsulatedTableView = self.encapsulatedTableViews[0];
    self.activeEncapsulatedTableView.hidden = NO;
    
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.segmentedControl];
    
    for(EncapsulatedTableView *e in self.encapsulatedTableViews) {
        [self.containerView addSubview:e];
    }
    
    [[BookmarkManager sharedManager] addObserver:self forKeyPath:@"bookmarks" options:NSKeyValueObservingOptionNew context:nil];
    [self updateViewConstraints];
    [self.segmentedControl setSelectedSegmentIndex:0];
    // Do any additional setup after loading the view.
}

- (void)updateViewConstraints {
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];
        [self.segmentedControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.segmentedControl autoSetDimension:ALDimensionHeight toSize:MODE_BAR_HEIGHT];
        
        for(EncapsulatedTableView *etv in self.encapsulatedTableViews) {
            [etv autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.segmentedControl withOffset:MODE_BAR_HEIGHT - 1];
            [etv autoAlignAxisToSuperviewAxis:ALAxisVertical];
            [etv autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
            [etv autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.segmentedControl];
        }
    }
    
    [super updateViewConstraints];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
     NSDictionary *bookmarks = [BookmarkManager sharedManager].bookmarks;
    return [self indexOfTableView:tableView] == BookmarkTypeDocument ? [bookmarks[@"Documents"] count] : 1;
}

- (void)dealloc {
    [[BookmarkManager sharedManager] removeObserver:self forKeyPath:@"bookmarks"];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *bookmarks = [BookmarkManager sharedManager].bookmarks;
    
    switch ([self indexOfTableView:tableView]) {
        case BookmarkTypeDocket:
        return [bookmarks[@"Dockets"] count];
        break;
        case BookmarkTypeDocument: {
            if([bookmarks[@"Documents"] count] == 0) return 0;
            else return [bookmarks[@"Documents"][section] count];
        }
        
        default:
        break;
    }
    
    return 0;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSArray *bookmarks;
    NSInteger tableIndex = [self indexOfTableView:tableView];
    switch (tableIndex) {
        case BookmarkTypeDocket:
        bookmarks = [BookmarkManager sharedManager].bookmarks[@"Dockets"];
        break;
        case BookmarkTypeDocument:
        bookmarks = [BookmarkManager sharedManager].bookmarks[@"Documents"];
        default:
        break;
    }
    
    NSDictionary *item;
    
    if(tableIndex < 1) {
        item = bookmarks[indexPath.row];
    } else {
        item = bookmarks[indexPath.section][indexPath.row];
    }
    
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:14];
        cell.detailTextLabel.font = [UIFont fontWithName:@"Lato-Thin" size:12];
    }
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"id"];
    return cell;
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
        
        NSInteger tableIndex = [self indexOfTableView:tableView];
        
        if(tableIndex == 1) {
            NSDictionary *firstItem = [BookmarkManager sharedManager].bookmarks[@"Documents"][section][0];
            NSString *agency = [firstItem[@"id"] componentsSeparatedByString:@"-"][0];
            thv.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:10];
            thv.contentView.tintColor = [UIColor lightGrayColor];
            thv.textLabel.text = agency;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(EncapsulatedTableView *) encapsulatedTableView {
    EncapsulatedTableView *_encapsulatedTableView = [[EncapsulatedTableView alloc] init];
    _encapsulatedTableView.translatesAutoresizingMaskIntoConstraints = NO;
    _encapsulatedTableView.tableView.dataSource = self;
    _encapsulatedTableView.tableView.delegate = self;
    _encapsulatedTableView.hidden = YES;
    return _encapsulatedTableView;
}

-(NSArray *)encapsulatedTableViews {
    if(!_encapsulatedTableViews) {
        _encapsulatedTableViews = @[ [self encapsulatedTableView] , [self encapsulatedTableView ], [self encapsulatedTableView] ];
    }
    return _encapsulatedTableViews;
}

-(HMSegmentedControl *)segmentedControl {
    if(!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectZero];
        _segmentedControl.sectionTitles = @[@"Dockets", @"Documents"];
        _segmentedControl.selectedSegmentIndex = 0;
        _segmentedControl.translatesAutoresizingMaskIntoConstraints = NO;
        _segmentedControl.backgroundColor = [UIColor whiteColor];
        _segmentedControl.textColor = [UIColor darkGrayColor];
        _segmentedControl.selectedTextColor = [UIColor blackColor];
        _segmentedControl.font = [UIFont fontWithName:@"Lato-Thin" size:12];
        _segmentedControl.selectionIndicatorColor = [RegsStyle secondaryLineColor];
        _segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
        _segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationUp;
        _segmentedControl.layer.borderWidth = 1;
        _segmentedControl.layer.borderColor = [UIColor lightGrayColor].CGColor;
        __weak typeof(self) weakSelf = self;
        [_segmentedControl setIndexChangeBlock:^(NSInteger index) {
            weakSelf.activeEncapsulatedTableView.hidden = YES;
            weakSelf.activeEncapsulatedTableView = weakSelf.encapsulatedTableViews[index];
            weakSelf.activeEncapsulatedTableView.hidden = NO;
        }];
    }
    return _segmentedControl;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if([self indexOfTableView:tableView] == 1) return 20;
    return 0;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"bookmarks"]) {
        [[self.encapsulatedTableViews[0] tableView] reloadData];
        [[self.encapsulatedTableViews[1] tableView] reloadData];
        [self.encapsulatedTableViews[0] setNeedsLayout];
        [self.encapsulatedTableViews[1] setNeedsLayout];
    }
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(![RegsClient checkInternetConnection]) return;
    
    NSArray *bookmarks;
    BookmarkType type = [self indexOfTableView:tableView];
    
    switch (type) {
        case 0:
        bookmarks = [BookmarkManager sharedManager].bookmarks[@"Dockets"];
        break;
        case 1:
        bookmarks = [BookmarkManager sharedManager].bookmarks[@"Documents"];
        default:
        break;
    }
    
    NSDictionary *item;
    
    if(type < 1) {
        item = bookmarks[indexPath.row];
    } else {
        item = bookmarks[indexPath.section][indexPath.row];
    }
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    if(type == BookmarkTypeDocket) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [[RegsClient sharedClient] getDocket:item[@"id"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            if(responseObject) {
                [SVProgressHUD dismiss];
                DocketViewController *nextController = [[DocketViewController alloc] init];
                nextController.item = responseObject;
                nextController.title = item[@"id"];
                [self.navigationController pushViewController:nextController animated:YES];
                
            }
            else [SVProgressHUD showErrorWithStatus:@"Error loading docket." maskType:SVProgressHUDMaskTypeGradient];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:@"Error loading docket." maskType:SVProgressHUDMaskTypeGradient];
        }];
        
    } else if (type == BookmarkTypeEntity) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [[RegsClient sharedClient] getEntity:item[@"id"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            if(responseObject) {
                [SVProgressHUD dismiss];
                EntityViewController *nextController = [[EntityViewController alloc] init];
                nextController.item = responseObject;
                nextController.title = item[@"id"];
                [self.navigationController pushViewController:nextController animated:YES];
                
            }
            else [SVProgressHUD showErrorWithStatus:@"Error loading entity." maskType:SVProgressHUDMaskTypeGradient];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error loading entity." maskType:SVProgressHUDMaskTypeGradient];
        }];
        
    } else if (type == BookmarkTypeDocument) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        [[RegsClient sharedClient] getDocument:item[@"id"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(responseObject) {
                [SVProgressHUD dismiss];
                DocumentViewController *nextController = [[DocumentViewController alloc] init];
                nextController.item = responseObject;
                nextController.title = item[@"id"];
                [self.navigationController pushViewController:nextController animated:YES];
                
            }
            else [SVProgressHUD showErrorWithStatus:@"Error loading document." maskType:SVProgressHUDMaskTypeGradient];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error loading document." maskType:SVProgressHUDMaskTypeGradient];
        }];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray *bookmarks;
        
        BookmarkType type = [self indexOfTableView:tableView];
        
        switch (type) {
            case 0:
                bookmarks = [BookmarkManager sharedManager].bookmarks[@"Dockets"];
                break;
            case 1:
                bookmarks = [BookmarkManager sharedManager].bookmarks[@"Documents"];
                break;
            default:
                break;
        }
        
        NSDictionary *item;
        
        if(type < 1) {
            item = bookmarks[indexPath.row];
        } else {
            item = bookmarks[indexPath.section][indexPath.row];
        }
        
        [[BookmarkManager sharedManager] delete:item as:type];
        
        [[self.encapsulatedTableViews[0] tableView] reloadData];
        [[self.encapsulatedTableViews[1] tableView] reloadData];
        [self.encapsulatedTableViews[0] setNeedsLayout];
        [self.encapsulatedTableViews[1] setNeedsLayout];
    }
    
}

- (NSInteger) indexOfTableView:(UITableView *)tv {
    for(NSInteger i = 0; i < self.encapsulatedTableViews.count; ++i) {
        if([self.encapsulatedTableViews[i] tableView] == tv) {
            return i;
        }
    }
    return -1;
}



@end

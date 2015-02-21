//
//  AgencyViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "FederalAgencyViewController.h"
#import "FedAgencyDetailViewController.h"
#import "RegsClient.h"
#import "GradientView.h"
#import "RegsStyle.h"
#import "RegulationsGovClient.h"
#import "UIImage+Ext.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <SVProgressHUD/SVProgressHUD.h>

#define SEARCH_BAR_HEIGHT 42
#define MODE_BAR_HEIGHT 28

//top_submitter_entities
//Federal Aviation Administration
//popular_dockets
//recent_dockets
//

@interface FederalAgencyViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSArray *agencies;
@property (nonatomic, strong) NSArray *filteredAgencies;
@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;
@property (nonatomic, strong) UITextField *searchField;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) NSArray *indexTitles;
@property (nonatomic, strong) NSMutableArray *sectionedAgencies;
@property (nonatomic, strong) UILabel *noConnectionLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) BOOL loaded;

@end

@implementation FederalAgencyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self load];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.encapsulatedTableView];
    [self.containerView addSubview:self.searchBar];
    [self.containerView addSubview:self.noConnectionLabel];
    [self.searchBar addSubview:self.searchField];
    self.searchField.rightView = self.clearButton;
    
    self.title = @"Agencies";
    
    self.loaded = FALSE;
    
}

- (void) load {
    if([AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWiFi || [AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWWAN) {
        __weak typeof(self) weakSelf = self;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [[RegulationsGovClient sharedClient] getAgenciesWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            weakSelf.agencies = responseObject;
            weakSelf.loaded = TRUE;
            [weakSelf textFieldDidChange:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
        }];

    } else {
        self.noConnectionLabel.text = @"Check Internet Connection";
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(!self.loaded) [self load];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) updateViewConstraints {
    
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
        
        [self.searchField autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.searchBar withOffset:5];
        [self.searchField autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.searchBar withOffset:-5];
        [self.searchField autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:5];
        [self.searchField autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:5];
        
    }
    
    [super updateViewConstraints];
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    __block NSDictionary *item = self.sectionedAgencies[indexPath.section][indexPath.row];
    NSString *abbv = [item[@"short_name"] copy];
    __block NSString *title = [self.sectionedAgencies[indexPath.section][indexPath.row][@"name"] copy];
    
    FedAgencyDetailViewController *nextController = [[FedAgencyDetailViewController alloc] init];
    NSDictionary *dict = @{
                           @"name":[title copy],
                           @"short_name":[abbv copy],
                           @"description":[item[@"description"] copy],
                           @"recent_articles_url":[item[@"recent_articles_url"] copy],
                           @"agency_id":[item[@"id"] stringValue]
                           };
    nextController.item = dict;
    [self.navigationController pushViewController:nextController animated:YES];
    /*
     [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
     [[RegsClient sharedClient] getAgency:abbv success:^(AFHTTPRequestOperation *operation, id responseObject) {
     AgencyDetailViewController *nextController = [[AgencyDetailViewController alloc] init];
     [SVProgressHUD dismiss];
     if(!responseObject) {
     
     //handle
     [SVProgressHUD showErrorWithStatus:@"No data for agency found." maskType:SVProgressHUDMaskTypeGradient];
     }
     [responseObject setObject:item[@"id"] forKey:@"agency_id"];
     [responseObject setObject:item[@"description"] forKey:@"description"];
     nextController.item = responseObject;
     nextController.title = title;
     nextController.abbv = abbv;
     [self.navigationController pushViewController:nextController animated:YES];
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     //progress
     //throw alert
     [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
     [tableView deselectRowAtIndexPath:indexPath animated:NO];
     }];*/
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionedAgencies.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sectionedAgencies[section] count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.font = [RegsStyle defaultLabelFont];
        cell.detailTextLabel.font = [RegsStyle detailTextFont];
    }
    
    cell.textLabel.text = self.sectionedAgencies[indexPath.section][indexPath.row][@"name"];
    cell.detailTextLabel.text = self.sectionedAgencies[indexPath.section][indexPath.row][@"short_name"];
    
    NSURL *url = [NSURL URLWithString:self.sectionedAgencies[indexPath.section][indexPath.row][@"logo"][@"thumb_url"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    __weak UITableViewCell *weakCell = cell;
    cell.imageView.image = nil;
    [cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (weakCell)
        {
            weakCell.imageView.image = image;
            [weakCell setNeedsLayout];
        }
        
        
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
       
    }];
    return cell;
}



-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.indexTitles;
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

-(EncapsulatedTableView *) encapsulatedTableView {
    if(!_encapsulatedTableView) {
        _encapsulatedTableView = [[EncapsulatedTableView alloc] init];
        _encapsulatedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _encapsulatedTableView.tableView.dataSource = self;
        _encapsulatedTableView.tableView.delegate = self;
        _encapsulatedTableView.tableView.rowHeight = 70;
    }
    return _encapsulatedTableView;
}

-(UITextField *) searchField {
    if(!_searchField) {
        _searchField = [[UITextField alloc] init];
        _searchField.backgroundColor = [UIColor whiteColor];
        _searchField.font = [RegsStyle defaultLabelFont];
        _searchField.translatesAutoresizingMaskIntoConstraints = NO;
        _searchField.delegate = self;
        [_searchField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _searchField.font = [RegsStyle searchTextFont];
        _searchField.placeholder = @" Filter Agencies";
        _searchField.keyboardAppearance = UIKeyboardAppearanceLight;
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.rightViewMode = UITextFieldViewModeAlways;
    }
    return _searchField;
}

-(UIView *)searchBar {
    if(!_searchBar) {
        _searchBar = [[UIView alloc] initWithFrame:CGRectZero];
        _searchBar.translatesAutoresizingMaskIntoConstraints = NO;
        _searchBar.layer.borderWidth = 1;
        _searchBar.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _searchBar.backgroundColor = [UIColor whiteColor];
    }
    
    
    return _searchBar;
}

-(UIButton *)clearButton {
    if(!_clearButton) {
        _clearButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        _clearButton.backgroundColor = [UIColor clearColor];
        [_clearButton addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
        [_clearButton setImage:[[UIImage imageNamed:@"multiply-symbol-mini"] imageWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
    }
    
    return _clearButton;
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
        thv.textLabel.text = self.indexTitles[section];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ([self.sectionedAgencies[section] count] == 0) ? 0 : 20;
}

-(NSArray *)indexTitles {
    if(!_indexTitles) {
        _indexTitles = [@"A B C D E F G H I J K L M N O P Q R S T U V W X Y Z" componentsSeparatedByString:@" "];
    }
    return _indexTitles;
}

-(NSArray *) sectionedAgencies {
    
    if(!_sectionedAgencies) {
        
        NSString *filter = self.searchField.text;
        
        _sectionedAgencies = [NSMutableArray array];
        
        NSInteger currentIndex = 0;
        
        for(NSString *idx in self.indexTitles) {
            NSMutableArray *letter = [NSMutableArray array];
            [_sectionedAgencies addObject:letter];
            for(; currentIndex < self.agencies.count; ++currentIndex) {
                NSString *agency = self.agencies[currentIndex][@"name"];
                if([[agency substringToIndex:1].uppercaseString isEqualToString:idx]) {
                    if (filter.length == 0) {
                        [letter addObject:self.agencies[currentIndex]];
                    } else if ([self.agencies[currentIndex][@"name"] rangeOfString:filter options:NSCaseInsensitiveSearch].location != NSNotFound) {
                        [letter addObject:self.agencies[currentIndex]];
                    }
                    
                } else break;
            }
            
            
        }
    }
    return _sectionedAgencies;
}

-(void) clear:(id)sender {
    self.searchField.text = @"";
}

-(void) textFieldDidChange:(UITextField *)searchField {
    self.sectionedAgencies = nil;
    [self.encapsulatedTableView.tableView reloadData];
    self.didSetupConstraints = NO;
    [self updateViewConstraints];
    [self.encapsulatedTableView setNeedsLayout];
    [self.containerView setNeedsUpdateConstraints];
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

- (void) didTap:(id)sender {
    [self.searchField resignFirstResponder];
}

-(UILabel *)noConnectionLabel {
    if(!_noConnectionLabel) {
        _noConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width,100)];
        _noConnectionLabel.center = self.containerView.center;
        _noConnectionLabel.numberOfLines = 1;
        _noConnectionLabel.font = [RegsStyle titleLabelFont];
        _noConnectionLabel.textAlignment = NSTextAlignmentCenter;
        _noConnectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noConnectionLabel.backgroundColor = [UIColor clearColor];
    }
    return _noConnectionLabel;
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

//
//  RecentViewController.m
//  Regs
//
//  Created by Matthew Zorn on 12/26/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RegisterViewController.h"
#import <HMSegmentedControl/HMSegmentedControl.h>
#import "RegsStyle.h"
#import "RegulationsGovClient.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImage+Ext.h"
#import <Reader/ReaderViewController.h>
#import "DocketCell.h"
#import <THCalendarDatePicker/THDatePickerViewController.h>


#define MODE_BAR_HEIGHT 28

@interface RegisterViewController () <UITableViewDataSource, UITableViewDelegate, ReaderViewControllerDelegate, THDatePickerDelegate>

@property (nonatomic, strong) NSMutableArray *tableViewHeightConstraints;
@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;
@property (nonatomic, strong) EncapsulatedTableView *sortedEncapsulatedTableView;
@property (nonatomic) BOOL tableViewOrSortedTableView;
@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) NSArray *sortedEntries;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UILabel *noRegisterLabel;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) THDatePickerViewController *datePicker;
@property (nonatomic) BOOL loaded;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.date = [NSDate date];
    [self setTitleView:@"FEDERAL REGISTER" subtitle:[self.dateFormatter stringFromDate:self.date]];
    
    [self.containerView addSubview:self.noRegisterLabel];
    [self.containerView addSubview:self.encapsulatedTableView];
    [self.containerView addSubview:self.sortedEncapsulatedTableView];
    [self.containerView addSubview:self.segmentedControl];
    
    self.tableViewOrSortedTableView = YES;
    
    self.sortedEncapsulatedTableView.hidden = YES;
    self.encapsulatedTableView.hidden = YES;
    
    self.loaded = FALSE;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleDate:)];
    tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.navigationController.navigationBar addGestureRecognizer:tapGestureRecognizer];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-simple-01"] style:UIBarButtonItemStylePlain target:self action:@selector(lessDay:)];
    
    UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow-simple-02"] style:UIBarButtonItemStylePlain target:self action:@selector(moreDay:)];
    
    self.navigationItem.leftBarButtonItems = @[backButton, forwardButton];
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    
    [self updateViewConstraints];
    
    if(!self.loaded){
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self loadDate];
            
        });
        
        self.loaded = TRUE;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self updateViewConstraints];
}

- (void) viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self updateViewConstraints];
}

- (void) updateViewConstraints {
    
    [self.encapsulatedTableView setNeedsLayout];
    [self.sortedEncapsulatedTableView setNeedsLayout];
    
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = TRUE;
        
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.segmentedControl autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];
        [self.segmentedControl autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.segmentedControl autoSetDimension:ALDimensionHeight toSize:MODE_BAR_HEIGHT];
        
        [self.encapsulatedTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.segmentedControl withOffset:MODE_BAR_HEIGHT - 1];
        [self.encapsulatedTableView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        [self.encapsulatedTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.segmentedControl];
        
        [self.sortedEncapsulatedTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.segmentedControl withOffset:MODE_BAR_HEIGHT - 1];
        [self.sortedEncapsulatedTableView autoAlignAxisToSuperviewAxis:ALAxisVertical];
        [self.sortedEncapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        [self.sortedEncapsulatedTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.segmentedControl];
        
        [self.noRegisterLabel autoCenterInSuperview];
        
    }
    
    [super updateViewConstraints];
}


- (void) loadDate {
    [self setTitleView:@"FEDERAL REGISTER" subtitle:[self.dateFormatter stringFromDate:self.date]];
    __weak typeof(self) _self = self;
    //check internet connection
    
    if([AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWiFi || [AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWWAN) {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [[RegulationsGovClient sharedClient] getRegisterByDay:self.date success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            _self.sortedEncapsulatedTableView.hidden = self.tableViewOrSortedTableView;
            _self.encapsulatedTableView.hidden = !self.tableViewOrSortedTableView;
            
            [SVProgressHUD dismiss];
            _self.entries = responseObject[@"raw"];
            _self.sortedEntries = responseObject[@"sorted"];
            
            if(_self.entries.count == 0) {
                _self.noRegisterLabel.hidden = NO;
                _self.noRegisterLabel.text = [NSString stringWithFormat:@"No Federal Register for %@", [self.dateFormatter stringFromDate:self.date]];
                _self.encapsulatedTableView.hidden = YES;
                _self.sortedEncapsulatedTableView.hidden = YES;
            } else {
                _self.noRegisterLabel.hidden = YES;
                
                if(_self.segmentedControl.selectedSegmentIndex == 0) {
                    _self.encapsulatedTableView.hidden = NO;
                } else {
                    _self.sortedEncapsulatedTableView.hidden = NO;
                }
                
            }
            
            [_self.encapsulatedTableView.tableView reloadData];
            [_self.sortedEncapsulatedTableView.tableView reloadData];
            [_self updateViewConstraints];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
        }];
        
    } else {
        self.noRegisterLabel.text = @"Check Internet Connection";
        [self updateViewConstraints];
    }
    
}

-(EncapsulatedTableView *) encapsulatedTableView {
    if(!_encapsulatedTableView) {
        _encapsulatedTableView = [[EncapsulatedTableView alloc] init];
        _encapsulatedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _encapsulatedTableView.tableView.dataSource = self;
        _encapsulatedTableView.tableView.delegate = self;
    }
    return _encapsulatedTableView;
}

-(EncapsulatedTableView *) sortedEncapsulatedTableView {
    if(!_sortedEncapsulatedTableView) {
        _sortedEncapsulatedTableView = [[EncapsulatedTableView alloc] init];
        _sortedEncapsulatedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _sortedEncapsulatedTableView.tableView.dataSource = self;
        _sortedEncapsulatedTableView.tableView.delegate = self;
    }
    return _sortedEncapsulatedTableView;
}

-(HMSegmentedControl *)segmentedControl {
    if(!_segmentedControl) {
        _segmentedControl = [[HMSegmentedControl alloc] initWithFrame:CGRectZero];
        _segmentedControl.sectionTitles = @[@"Page", @"Agency"];
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
            
            if(weakSelf.entries.count != 0) {
                weakSelf.tableViewOrSortedTableView = !index;
                weakSelf.sortedEncapsulatedTableView.hidden = weakSelf.tableViewOrSortedTableView;
                weakSelf.encapsulatedTableView.hidden = !weakSelf.tableViewOrSortedTableView;
            }
            
        }];
    }
    return _segmentedControl;
}

-(UILabel *)noRegisterLabel {
    if(!_noRegisterLabel) {
        _noRegisterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width,100)];
        _noRegisterLabel.center = self.containerView.center;
        _noRegisterLabel.numberOfLines = 1;
        _noRegisterLabel.font = [RegsStyle titleLabelFont];
        _noRegisterLabel.textAlignment = NSTextAlignmentCenter;
        _noRegisterLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _noRegisterLabel.backgroundColor = [UIColor clearColor];
    }
    return _noRegisterLabel;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocketCell *cell = (DocketCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *entry;
    if(tableView == self.encapsulatedTableView.tableView) {
        entry = self.entries[indexPath.row];
    } else {
        entry = self.sortedEntries[indexPath.section][@"values"][indexPath.row];
    }
    
    
    if(!cell) {
        cell = [[DocketCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    
    cell.titleLabel.text = entry[@"title"];
    cell.summaryLabel.text = entry[@"abstract"];
    cell.idLabel.text = entry[@"citation"];
    
    
    if([entry[@"type"] isEqualToString:@"Rule"]) {
        cell.iconView.image = [[UIImage imageNamed:@"note"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"Proposed Rule"]) {
        cell.iconView.image = [[UIImage imageNamed:@"note-write"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"Notice"]) {
        cell.iconView.image = [[UIImage imageNamed:@"man-influence"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else cell.iconView.image = nil;
    
    [cell updateConstraints];
    //[document objectForKey:@"summary"]
    //[document objectForKey:@"date"]
    //[document objectForKey:@"type"]
    //[document objectForKEy:@"comments_open"]
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"FR %@.%@", [self.dateFormatter stringFromDate:self.date], @"pdf"]];
    
    NSDictionary *entry;
    if(tableView == self.encapsulatedTableView.tableView) {
        entry = self.entries[indexPath.row];
    } else {
        entry = self.sortedEntries[indexPath.section][@"values"][indexPath.row];
    }
    
    
    NSURL *url = [NSURL URLWithString:entry[@"pdf_url"]];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == self.sortedEncapsulatedTableView.tableView ? self.sortedEntries.count : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.sortedEncapsulatedTableView.tableView ? [self.sortedEntries[section][@"values"] count] : self.entries.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *entry;
    if(tableView == self.encapsulatedTableView.tableView) {
        entry = self.entries[indexPath.row];
    } else {
        entry = self.sortedEntries[indexPath.section][@"values"][indexPath.row];
    }
    return [self heightForEntry:entry];
}

-(CGFloat) heightForEntry:(NSDictionary *)item {
    return [item[@"abstract"] length] > 0 ? 105 : 75;
}

-(NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}



-(void) lessDay:(id)sender {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = -1;
    self.date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:0];
    [self loadDate];
}

-(void) moreDay:(id)sender{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    self.date = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:0];
    [self loadDate];
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (THDatePickerViewController *)datePicker {
    if(!_datePicker) {
        _datePicker = [THDatePickerViewController datePicker];
        _datePicker.delegate = self;
        //[_datePicker setAutoCloseOnSelectDate:YES];
        _datePicker.selectedBackgroundColor = [RegsStyle darkBackgroundColor];
        _datePicker.disableHistorySelection = NO;
        
    }
    
    _datePicker.date = self.date;
    return _datePicker;
}

- (void) datePickerDonePressed:(THDatePickerViewController *)datePicker {
    [self dismissSemiModalViewWithCompletion:^{
        self.date = datePicker.date;
        [self loadDate];
    }];
}

- (void) toggleDate:(id)sender {
    [self presentSemiViewController:self.datePicker withOptions:@{
                                                                  KNSemiModalOptionKeys.pushParentBack    : @(NO),
                                                                  KNSemiModalOptionKeys.animationDuration : @(1.0),
                                                                  KNSemiModalOptionKeys.shadowOpacity     : @(0.3),
                                                                  }];
}

-(void)datePicker:(THDatePickerViewController *)datePicker selectedDate:(NSDate *)selectedDate {
    [self dismissSemiModalViewWithCompletion:^{
        self.date = selectedDate;
        [self loadDate];
    }];
    
}

- (void)datePickerCancelPressed:(THDatePickerViewController *)datePicker { }

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
        thv.textLabel.text = self.sortedEntries[section][@"name"];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return (tableView == self.sortedEncapsulatedTableView.tableView) ? 20 : 0;
}


@end

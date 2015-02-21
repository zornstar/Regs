//
//  PublicInspectionViewController.m
//  Regs
//
//  Created by Matthew Zorn on 12/26/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "PublicInspectionViewController.h"
#import "RegulationsGovClient.h"
#import "DocketCell.h"
#import "RegsStyle.h"
#import <Reader/ReaderViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImage+Ext.h"

@interface PublicInspectionViewController () <UITableViewDataSource, UITableViewDelegate, ReaderViewControllerDelegate>

@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;
@property (nonatomic, strong) NSArray *entries;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UILabel *noConnectionLabel;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic) BOOL loaded;

@end

@implementation PublicInspectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.loaded = FALSE;
    self.title = @"Public Inspections";
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.encapsulatedTableView];
    [self.containerView addSubview:self.noConnectionLabel];
    self.encapsulatedTableView.hidden = YES;
    self.didSetupConstraints = NO;
    [self updateViewConstraints];
    [self load];

}

- (void) load {
    if([AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWiFi || [AFHTTPRequestOperationManager manager].reachabilityManager.isReachableViaWWAN) {
        __weak typeof(self) weakSelf = self;
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [[RegulationsGovClient sharedClient] getCurrentInspectionsSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            weakSelf.entries = responseObject;
            weakSelf.encapsulatedTableView.hidden = NO;
            [weakSelf.encapsulatedTableView.tableView reloadData];
            [weakSelf updateViewConstraints];
            weakSelf.loaded = TRUE;
            weakSelf.noConnectionLabel.hidden = YES;
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
        }];
    } else {
        self.noConnectionLabel.text = @"Check Internet Connection";
        [self updateViewConstraints];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    if(!self.loaded) [self load];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSDictionary *section = self.entries[indexPath.section];
    NSDictionary *entry = section[@"values"][indexPath.row];
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"PI %@.%@", entry[@"document_number"], @"pdf"]];
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
        
        [SVProgressHUD showErrorWithStatus:@"Error getting PDF"];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }];
    [operation start];
}

- (void) updateViewConstraints {
     
    [self.encapsulatedTableView setNeedsLayout];
    
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = TRUE;
        
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];
        
        [self.noConnectionLabel autoCenterInSuperview];
        
    }
    
    [super updateViewConstraints];
}

- (CGFloat) tableViewHeight {
    CGFloat h = 0;
    
    for(NSDictionary *section in self.entries) {
        h+=20;
        h+=[section[@"values"] count] * self.encapsulatedTableView.tableView.rowHeight;
    }
    
    if(h > self.containerView.frame.size.height-10) return 0;
    
    return h;
}

-(EncapsulatedTableView *) encapsulatedTableView {
    if(!_encapsulatedTableView) {
        _encapsulatedTableView = [[EncapsulatedTableView alloc] init];
        _encapsulatedTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _encapsulatedTableView.tableView.dataSource = self;
        _encapsulatedTableView.tableView.delegate = self;
        _encapsulatedTableView.tableView.rowHeight = 60.;
    }
    return _encapsulatedTableView;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *section = self.entries[indexPath.section];
    NSDictionary *entry = section[@"values"][indexPath.row];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.textLabel.font = [RegsStyle titleLabelFont];
        cell.textLabel.numberOfLines = 2;
        cell.detailTextLabel.font = [RegsStyle detailTextFont];
    }
    
    NSString *title = entry[@"title"];
    if(title.length == 0) {
        if(entry[@"toc_subject"] && entry[@"toc_doc"]) {
            title = [NSString stringWithFormat:@"%@ %@", entry[@"toc_subject"],entry[@"toc_doc"]];
        }
    }
    cell.textLabel.text = title;
    cell.detailTextLabel.text = entry[@"document_number"];
    
    if([entry[@"agencies"] count] > 0) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", cell.detailTextLabel.text, [self agencyString:entry[@"agencies"]]];
    }
    if([entry[@"type"] isEqualToString:@"Rule"]) {
        cell.imageView.image = [[UIImage imageNamed:@"note"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"Proposed Rule"]) {
        cell.imageView.image = [[UIImage imageNamed:@"note-write"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"Notice"]) {
        cell.imageView.image = [[UIImage imageNamed:@"man-influence"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else cell.imageView.image = nil;
    
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
        thv.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:10];
        thv.contentView.tintColor = [UIColor lightGrayColor];
        thv.textLabel.text = self.entries[section][@"date"];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.entries.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.entries[section][@"values"] count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (NSString *) agencyString:(NSArray *)agencies {
    
    NSString *str = @"";
    
    for(NSInteger i = 0; i < agencies.count; ++i) {
        NSDictionary *entry = agencies[i];
        if(i == 0) {
            str = entry[@"name"];
        } else {
            str = [str stringByAppendingString:[NSString stringWithFormat:@", %@", entry[@"name"]]];
        }
    }
    return str;
}


@end

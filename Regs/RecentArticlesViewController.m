//
//  PublicInspectionViewController.m
//  Regs
//
//  Created by Matthew Zorn on 12/26/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RecentArticlesViewController.h"
#import "RegulationsGovClient.h"
#import "DocketCell.h"
#import "RegsStyle.h"
#import <Reader/ReaderViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "UIImage+Ext.h"

@interface RecentArticlesViewController () <UITableViewDataSource, UITableViewDelegate, ReaderViewControllerDelegate>

@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end

@implementation RecentArticlesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitleView:self.name subtitle:@"Recent Articles"];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.encapsulatedTableView];
    
    self.didSetupConstraints = FALSE;
    // Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated {
    
    [self updateViewConstraints];
}


-(void) updateViewConstraints {
    
    
    [self.encapsulatedTableView setNeedsLayout];
    
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = TRUE;
        
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];

    }
    
    [super updateViewConstraints];
    
}

- (CGFloat) tableViewHeight {
    CGFloat h = 0;
    
    for(NSDictionary *section in self.entries) {
        h+=20;
        for(NSDictionary *entry in section[@"values"]) {
            h+=[self heightForEntry:entry];
        }
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
    }
    return _encapsulatedTableView;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocketCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *section = self.entries[indexPath.section];
    NSDictionary *entry = section[@"values"][indexPath.row];
    
    if(!cell) {
        cell = [[DocketCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    
    cell.titleLabel.text = entry[@"title"];
    cell.summaryLabel.text = entry[@"summary"];
    cell.idLabel.text = entry[@"document_number"];
    
    
    if([entry[@"type"] isEqualToString:@"Rule"]) {
        cell.iconView.image = [[UIImage imageNamed:@"note"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"Proposed Rule"]) {
        cell.iconView.image = [[UIImage imageNamed:@"note-write"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"Notice"]) {
        cell.iconView.image = [[UIImage imageNamed:@"man-influence"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else cell.iconView.image = nil;
    
    //[document objectForKey:@"summary"]
    //[document objectForKey:@"date"]
    //[document objectForKey:@"type"]
    //[document objectForKEy:@"comments_open"]
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    NSDictionary *section = self.entries[indexPath.section];
    NSDictionary *entry = section[@"values"][indexPath.row];
    
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@.%@", entry[@"document_number"], @"pdf"]];
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
        thv.textLabel.text = [self.dateFormatter stringFromDate: self.entries[section][@"date"]];
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
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.entries[indexPath.section][@"values"][indexPath.row];
    return [self heightForEntry:item];
}

-(CGFloat) heightForEntry:(NSDictionary *)item {
    return [item[@"summary"] length] > 0 ? 105 : 75;
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

//
//  DocketViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "DocketViewController.h"
#import "DocumentViewController.h"
#import "DocketCell.h"
#import "RegsClient.h"
#import "RegsStyle.h"
#import "UIImage+Ext.h"
#import "BookmarkManager.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface DocketViewController ()

@property (nonatomic, strong) DocketCell *staticCell;

@end

@implementation DocketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self bookmarkButton];
    [self.containerView addSubview:self.encapsulatedTableView];
    [self updateViewConstraints];
}


- (void) updateViewConstraints {
    
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = TRUE;
        
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:5.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10.0];
        [self.encapsulatedTableView autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:5.0];
        
    }
    
    [super updateViewConstraints];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat) tableViewHeight {
    CGFloat h = 0;
    
    for(NSDictionary *item in self.entries) {
        h+= [self heightForEntry:item];
        if(h > self.containerView.frame.size.height - 20) return 0;
    }
    
    return h;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView { return 1; }

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.entries.count;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocketCell *cell = (DocketCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *entry = self.entries[indexPath.row];
    
    if(!cell) {
        cell = [[DocketCell alloc] initWithReuseIdentifier:@"Cell"];
    }
    
    cell.titleLabel.text = entry[@"title"];
    cell.summaryLabel.text = entry[@"summary"];
    cell.dateLabel.text = entry[@"date"];
    cell.idLabel.text = entry[@"id"];
    
    
    if([entry[@"type"] isEqualToString:@"rule"]) {
        cell.iconView.image = [[UIImage imageNamed:@"note"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"proposed_rule"]) {
        cell.iconView.image = [[UIImage imageNamed:@"note-write"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if ([entry[@"type"] isEqualToString:@"notice"]) {
        cell.iconView.image = [[UIImage imageNamed:@"man-influence"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else cell.iconView.image = nil;
    
    //[cell updateConstraints];
    
    return cell;
}

- (NSArray *)entries {
    if(!_entries) {
        _entries = self.item[@"stats"][@"doc_info"][@"fr_docs"];
        
        for(NSMutableDictionary *entry in _entries) {
            NSString *title = entry[@"title"];
            title = [title stringByReplacingOccurrencesOfString:@"\\n+"
                                                     withString:@" "
                                                        options:NSRegularExpressionSearch
                                                          range:NSMakeRange(0, title.length)];
            [entry setObject:title forKey:@"title"];

        }
    }
    return _entries;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *entry = self.entries[indexPath.row];
    NSString *docID = entry[@"id"];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[RegsClient sharedClient] getDocument:docID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        DocumentViewController *nextController = [[DocumentViewController alloc] init];
        nextController.summary = entry[@"summary"];
        nextController.item = responseObject;
        nextController.hideDocket = YES;
        [self.navigationController pushViewController:nextController animated:YES];
        [self.encapsulatedTableView.tableView deselectRowAtIndexPath:indexPath animated:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
    }];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    return view;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.entries[indexPath.row];
    return [self heightForEntry:item];
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

-(UIBarButtonItem *) bookmarkButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark-small-mini"] style:UIBarButtonItemStylePlain target:self action:@selector(addBookmark:)];
}

-(void) addBookmark:(id)sender { [[BookmarkManager sharedManager] add:self.item as:BookmarkTypeDocket]; }
    
-(CGFloat) heightForEntry:(NSDictionary *)item {
    return [item[@"summary"] length] > 0 ? 105 : 75;
}



@end

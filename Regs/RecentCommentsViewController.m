//
//  RecentCommentsViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/29/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "RecentCommentsViewController.h"
#import "DocumentViewController.h"
#import "RegsClient.h"
#import "CommentCell.h"
#import <Reader/ReaderViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface RecentCommentsViewController () <ReaderViewControllerDelegate>

@end

@implementation RecentCommentsViewController

- (id) init {
    if(self = [super init]) {
        self.title = @"Recent Comments";
    }
    return self;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = (CommentCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if(!cell) {
        cell = [[CommentCell alloc] initWithReuseIdentifier:@"Cell"];
       
    }
    
    cell.iconView.image = [UIImage imageNamed:@"message-empty-mini"];
    cell.titleLabel.text = self.entries[indexPath.row][@"title"];
    cell.dateLabel.text = self.entries[indexPath.row][@"date"];
    //[cell updateConstraints];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.entries[indexPath.row];
    NSString *doc = [item[@"url"] lastPathComponent];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[RegsClient sharedClient] getDocument:doc success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DocumentViewController *nextController = [[DocumentViewController alloc] init];
        nextController.item = responseObject;
        [SVProgressHUD dismiss];
        [self.navigationController pushViewController:nextController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [tableView deselectRowAtIndexPath:indexPath animated:NO];
         [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
    }];
}

-(void)viewDidLoad {
    [super viewDidLoad];
    self.encapsulatedTableView.tableView.rowHeight = 45.;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.;
}

@end

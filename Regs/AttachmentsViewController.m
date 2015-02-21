//
//  AttachmentViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/29/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "AttachmentsViewController.h"
#import "RegsClient.h"
#import <Reader/ReaderViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface AttachmentsViewController () <UITableViewDataSource, UITableViewDelegate, ReaderViewControllerDelegate>

@end

@implementation AttachmentsViewController

- (void)viewDidLoad {
    self.title = @"Attachments";
    self.encapsulatedTableView.tableView.rowHeight = 45;
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
   
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:12];
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        cell.imageView.image = [UIImage imageNamed:@"paper-clip"];
    }
    cell.textLabel.text = self.entries[indexPath.row][@"title"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.entries[indexPath.row][@"views"][0];//?
    NSString *file = item[@"file_type"];
    if (![file isEqualToString:@"pdf"] && ![file isEqualToString:@"html"]) {
        return;
    }
    NSString *string = item[@"url"];
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@.%@", item[@"object_id"], @"pdf"]];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    [[RegsClient sharedClient] getDocumentURL:string toPath:tempPath success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        if(!responseObject) {
            [SVProgressHUD showErrorWithStatus:@"No document found." maskType:SVProgressHUDMaskTypeGradient];
        } else {
            
            ReaderDocument *readerDocument = [[ReaderDocument alloc] initWithFilePath:responseObject password:nil];
            ReaderViewController *modalViewController = [[ReaderViewController alloc] initWithReaderDocument:readerDocument];
            modalViewController.delegate = self;
            [self presentViewController:modalViewController animated:YES completion:nil];
            [SVProgressHUD dismiss];
        }
        
        
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Error loading document." maskType:SVProgressHUDMaskTypeGradient];
    }];
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
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

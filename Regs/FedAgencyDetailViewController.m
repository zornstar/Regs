//
//  DocumentViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "FedAgencyDetailViewController.h"
#import "RegulationsGovClient.h"
#import "RecentArticlesViewController.h"
#import "RegsStyle.h"
#import "EventsViewController.h"
#import "RecentCommentsViewController.h"
#import "AttachmentsViewController.h"
#import "UIImage+Ext.h"
#import "RegsStyle.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface FedAgencyDetailViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITableView *linksTableView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *links;

@end

@implementation FedAgencyDetailViewController

- (id) init {
    if(self = [super init]) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = NO;
    [self.scrollView addSubview:self.textView];
    [self.scrollView addSubview:self.linksTableView];
    [self setTitleView:self.item[@"name"] subtitle:nil];
    self.didSetupConstraints = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self updateViewConstraints];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self updateViewConstraints];
}

-(void) updateViewConstraints {
    
    if(!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self.textView autoPinEdgeToSuperviewEdge:ALEdgeTop];
        [self.textView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView withMultiplier:.95];
        [self.textView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.scrollView];
        
        [self.linksTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textView withOffset:5.0];
        [self.linksTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView withMultiplier:.95];
        [self.linksTableView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.scrollView];
        
        [self.linksTableView setNeedsLayout];
        [self.linksTableView layoutIfNeeded];
        [self.linksTableView autoSetDimension:ALDimensionHeight toSize:self.linksTableView.contentSize.height];
        
        [self.linksTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.scrollView withOffset:-5.];
        
        [self.scrollView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.containerView];
        [self.scrollView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.containerView];
        
        [self.scrollView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.containerView];
        [self.scrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.containerView];
        
    }
    [super updateViewConstraints];
}



-(CGFloat) linksHeight {
    CGFloat height = self.linksTableView.rowHeight * self.links.count;
    return height;
}

-(UITableView *) linksTableView {
    if(!_linksTableView) {
        _linksTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _linksTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _linksTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _linksTableView.dataSource = self;
        _linksTableView.delegate = self;
        _linksTableView.scrollEnabled = NO;
        _linksTableView.layer.borderWidth = 1;
        _linksTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _linksTableView.rowHeight = 50;
    }
    return _linksTableView;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.font = [RegsStyle titleLabelFont];
        cell.detailTextLabel.font = [RegsStyle detailTextFont];
    }
        
    if(indexPath.row == 0) {
        cell.textLabel.text = @"Recent Articles";
        cell.imageView.image = [[UIImage imageNamed:@"sticky-note"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Recent/Upcoming Events";
        cell.imageView.image = [[UIImage imageNamed:@"calendar"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"Subscribe to Agency Publications";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Receive e-mail updates for %@ publications on the Federal Register", self.item[@"short_name"]];
        cell.imageView.image = [[UIImage imageNamed:@"email-add"] imageWithColor:[RegsStyle darkBackgroundColor]];
    } else if (indexPath.row == 3) {
        cell.textLabel.text = @"Subscribe to Agency Public Inspection Notices";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Receive e-mail updates for %@ public inspections", self.item[@"short_name"]];
        cell.imageView.image = [[UIImage imageNamed:@"email-add"] imageWithColor:[RegsStyle darkBackgroundColor]];
    }
        
        return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row == 0) {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
         [[RegulationsGovClient sharedClient] getRecentArticles:self.item[@"recent_articles_url"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [tableView deselectRowAtIndexPath:indexPath animated:YES];
             if([responseObject count] == 0) {
                 [SVProgressHUD showErrorWithStatus:@"Error: No recent articles."];
                 [tableView deselectRowAtIndexPath:indexPath animated:NO];
             } else {
                 RecentArticlesViewController *nextController = [[RecentArticlesViewController alloc] init];
                 nextController.entries = responseObject;
                 nextController.name = self.item[@"name"];
                 [self.navigationController pushViewController:nextController animated:YES];	
                 [SVProgressHUD dismiss];
                 [tableView deselectRowAtIndexPath:indexPath animated:NO];
             }
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
             [SVProgressHUD showErrorWithStatus:@"Error"];
             [tableView deselectRowAtIndexPath:indexPath animated:NO];
         }];
        
    } else if (indexPath.row == 1) {
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [[RegulationsGovClient sharedClient] getAgencyEvents:self.item[@"agency_id"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD dismiss];
            if([responseObject count] > 0) {
                EventsViewController *nextController = [[EventsViewController alloc] init];
                nextController.events = responseObject;
                nextController.name = self.item[@"name"];
                [self.navigationController pushViewController:nextController animated:YES];
            } else {
                [SVProgressHUD showImage:[[UIImage imageNamed:@"calendar-mini"] imageWithColor:[UIColor lightGrayColor]] status:@"No Recent/Upcoming Events" maskType:SVProgressHUDMaskTypeGradient];
            }
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [SVProgressHUD showErrorWithStatus:@"Error" maskType:SVProgressHUDMaskTypeGradient];
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
        }];
    } else if (indexPath.row == 2) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe" message:@"Enter E-mail Address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
        alertView.tag = 2;
        alertView.delegate = self;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    } else if (indexPath.row == 3) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Subscribe" message:@"Enter E-mail Address:" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil] ;
        alertView.tag = 3;
        alertView.delegate = self;
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [alertView show];
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1) {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        NSString *email = [alertView textFieldAtIndex:0].text;
        [[RegulationsGovClient sharedClient] subscribeEmail:email toAgencyID:self.item[@"agency_id"] publicInspection:(alertView.tag == 2) success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Subscribed %@", email] maskType:SVProgressHUDMaskTypeGradient];
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Error subscribing %@", email] maskType:SVProgressHUDMaskTypeGradient];
        }];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


-(UITextView *)textView {
    if(!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width * .95, 0)];
        _textView.backgroundColor = [UIColor clearColor];
        UIFont *font = [UIFont fontWithName:[RegsStyle summaryTextFont].fontName size:13];
        _textView.font = font;
        _textView.textColor = [UIColor blackColor];
        _textView.textAlignment = NSTextAlignmentJustified;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.scrollEnabled = NO;
        _textView.text = self.item[@"description"];
    }
    return _textView;
}



@end

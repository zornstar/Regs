//
//  DocumentViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "DocumentViewController.h"
#import "RegsClient.h"
#import "RegsStyle.h"
#import "BookmarkManager.h"
#import "RecentCommentsViewController.h"
#import "AttachmentsViewController.h"
#import "UIImage+Ext.h"
#import <Reader/ReaderViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface DocumentViewController () <UITableViewDataSource, UITableViewDelegate, ReaderViewControllerDelegate>

@property (nonatomic, strong) UITableView *infoTableView;
@property (nonatomic, strong) UITableView *linksTableView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSLayoutConstraint *textConstraint;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) NSArray *links;

@end

@implementation DocumentViewController

- (id) init {
    if(self = [super init]) {
        self.hideDocket = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [self bookmarkButton];
    self.textView.text = self.summary;
    self.scrollView.scrollEnabled = YES;
    self.scrollView.bounces = NO;
    self.didSetupConstraints = NO;
    [self.scrollView addSubview:self.textView];
    [self.scrollView addSubview:self.infoTableView];
    [self.scrollView addSubview:self.linksTableView];
    [self setTitleView:[self.item[@"title"] stringByReplacingOccurrencesOfString:@"\\n+"
                                                                      withString:@" "
                                                                         options:NSRegularExpressionSearch
                                                                           range:NSMakeRange(0, [self.item[@"title"] length])] subtitle:nil];
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
        
        [self.infoTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.textView withOffset:5.0];
        [self.infoTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView withMultiplier:.95];
        [self.infoTableView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.scrollView];
        
        [self.infoTableView setNeedsLayout];
        [self.infoTableView layoutIfNeeded];
        [self.infoTableView autoSetDimension:ALDimensionHeight toSize:self.infoTableView.contentSize.height];
        
        [self.linksTableView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.infoTableView withOffset:5.0];
        [self.linksTableView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.scrollView withMultiplier:.95];
        [self.linksTableView autoAlignAxis:ALAxisVertical toSameAxisOfView:self.scrollView];
        
        [self.linksTableView setNeedsLayout];
        [self.linksTableView layoutIfNeeded];
        [self.linksTableView autoSetDimension:ALDimensionHeight toSize:self.linksTableView.contentSize.height];
        
        [self.linksTableView autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self.scrollView withOffset:-5];
        
        [self.scrollView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.containerView];
        [self.scrollView autoMatchDimension:ALDimensionHeight toDimension:ALDimensionHeight ofView:self.containerView];
        
        [self.scrollView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.containerView];
        [self.scrollView autoPinEdge:ALEdgeTop toEdge:ALEdgeTop ofView:self.containerView];
        
    }
    [super updateViewConstraints];
}


-(UITableView *) infoTableView {
    if(!_infoTableView) {
        _infoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _infoTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)];
        _infoTableView.translatesAutoresizingMaskIntoConstraints = NO;
        _infoTableView.dataSource = self;
        _infoTableView.delegate = self;
        _infoTableView.userInteractionEnabled = NO;
        _infoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _infoTableView.layer.borderWidth = 1;
        _infoTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
        _infoTableView.scrollEnabled = NO;
        _infoTableView.rowHeight = 28;
    }
    return _infoTableView;
}

-(CGFloat) infoHeight {
    NSInteger rows = 0;
    
    for(NSArray *sections in self.data) {
        rows += [sections[1] count];
    }
    
    return self.infoTableView.rowHeight * rows + self.data.count * [self tableView:self.infoTableView heightForHeaderInSection:0] + self.infoTableView.tableFooterView.frame.size.height;
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
        _linksTableView.rowHeight = 40;
    }
    return _linksTableView;
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
        thv.textLabel.text = self.data[section][0];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return tableView == self.infoTableView ? 20 : 0;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.infoTableView) {
        CGRect rect = cell.textLabel.frame;
        rect.size.width+=25;
        cell.textLabel.frame = rect;
        rect = cell.detailTextLabel.frame;
        rect.size.width-=25;
        rect.origin.x+=25;
        cell.detailTextLabel.frame = rect;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(tableView == self.infoTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"Cell"];
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.font = [RegsStyle titleLabelFont];
            cell.textLabel.textColor = [RegsStyle primaryTextColor];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.numberOfLines = 2;
            cell.detailTextLabel.font = [RegsStyle detailTextFont];
            cell.detailTextLabel.numberOfLines = 2;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        id key = self.data[indexPath.section][1][indexPath.row][0];
        id value = self.data[indexPath.section][1][indexPath.row][1];
        if([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
            cell.textLabel.text = self.data[indexPath.section][1][indexPath.row][0];
            cell.detailTextLabel.text = [self.data[indexPath.section][1][indexPath.row][1] stringByReplacingOccurrencesOfString:@"&ndash;" withString:@"-"];
            
            return cell;
        }
        else {
            CGRect frame = cell.frame;
            frame.size.height = 0;
            cell.frame = frame;
            return cell;
        }
        
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        
        if(!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
            cell.textLabel.font = [UIFont fontWithName:@"Lato-Regular" size:12];
        }
        
        NSDictionary *item = self.links[indexPath.row];
        cell.textLabel.text = item[@"title"];
        cell.imageView.image = [[UIImage imageNamed:item[@"icon"]] imageWithColor:[RegsStyle darkBackgroundColor]];
        
        return cell;
    }
    
    
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == self.linksTableView) {
        
        NSDictionary *item = self.links[indexPath.row];
        
        if([item[@"title"] isEqualToString:@"Document"]) {
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            
            NSString *tempPath = [NSTemporaryDirectory() stringByAppendingString:[NSString stringWithFormat:@"%@.%@", self.item[@"id"], @"pdf"]];
            [[RegsClient sharedClient] getDocumentURL:item[@"url"] toPath:tempPath success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if(!responseObject) {
                    [SVProgressHUD showErrorWithStatus:@"Error: No document."];
                    [self.linksTableView deselectRowAtIndexPath:indexPath animated:NO];
                } else {
                    
                    [SVProgressHUD dismiss];
                    ReaderDocument *readerDocument = [[ReaderDocument alloc] initWithFilePath:responseObject password:nil];
                    ReaderViewController *modalViewController = [[ReaderViewController alloc] initWithReaderDocument:readerDocument];
                    modalViewController.delegate = self;
                    [self presentViewController:modalViewController animated:YES completion:^{
                        
                        [self.linksTableView deselectRowAtIndexPath:indexPath animated:NO];
                    }];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Error"];
                [self.linksTableView deselectRowAtIndexPath:indexPath animated:NO];
            }];
            
        } else if([item[@"title"] isEqualToString:@"Docket"]) {
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            
            [[RegsClient sharedClient] get:item[@"url"] success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [SVProgressHUD dismiss];
                if(!responseObject) {
                    [SVProgressHUD showErrorWithStatus:@"Error: No docket."];
                } else {
                    [SVProgressHUD dismiss];
                    DocketViewController *nextController = [[DocketViewController alloc] init];
                    nextController.item = responseObject;
                    nextController.title = [item[@"url"] lastPathComponent];
                    [self.navigationController pushViewController:nextController animated:YES];
                    [self.linksTableView deselectRowAtIndexPath:indexPath animated:NO];
                }
                
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [SVProgressHUD showErrorWithStatus:@"Error"];
                
                
            }];
        } else if([item[@"title"] isEqualToString:@"Attachments"]) {
            AttachmentsViewController *nextController = [[AttachmentsViewController alloc] init];
            nextController.entries = self.item[@"attachments"];
            [self.navigationController pushViewController:nextController animated:YES];
            
            [self.linksTableView deselectRowAtIndexPath:indexPath animated:NO];
            
        } else if([item[@"title"] isEqualToString:@"Recent Comments"]) {
            RecentCommentsViewController *nextController = [[RecentCommentsViewController alloc] init];
            nextController.entries = self.item[@"comment_stats"][@"recent_comments"];
            [self.navigationController pushViewController:nextController animated:YES];
            
            [self.linksTableView deselectRowAtIndexPath:indexPath animated:NO];

        }
        
    }
}

-(void)dismissReaderViewController:(ReaderViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return tableView == self.infoTableView ? self.data.count : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableView == self.infoTableView ? [self.data[section][1] count] : self.links.count;
}


-(NSArray *)data {
    if(!_data) {
        _data = self.item[@"clean_details"];
    }
    return _data;
}

-(UITextView *)textView {
    if(!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width * .95, 0)];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [RegsStyle summaryTextFont];
        _textView.textColor = [UIColor blackColor];
        _textView.textAlignment = NSTextAlignmentJustified;
        _textView.translatesAutoresizingMaskIntoConstraints = NO;
        _textView.scrollEnabled = NO;
    }
    return _textView;
}

-(NSArray *)links {
    if(!_links) {
        NSMutableArray *links = [NSMutableArray array];
        if([self.item[@"views"] count] > 0) {
            [links addObject:@{
                              @"title":@"Document",
                              @"url":self.item[@"views"][0][@"url"],
                              @"icon":@"document"
                              }];
        }
        
        if (!self.hideDocket && self.item[@"docket"]) {
            [links addObject:@{
                               @"title":@"Docket",
                               @"url":self.item[@"docket"][@"url"],
                               @"icon":@"document-multiple"
                               }];
        }
        
        if ([self.item[@"comment_stats"][@"recent_comments"] count] > 0) {
            [links addObject:@{
                               @"title":@"Recent Comments",
                               @"icon":@"man-influence"
                               }];
        }
        
        if ([self.item[@"attachments"] count] > 0) {
            [links addObject:@{
                               @"title":@"Attachments",
                               @"icon":@"paper-clip"
                               }];
        }
        
        _links = links;
    }
    return _links;
}

- (NSString *)documentURL {
    NSArray *views = [self.item objectForKey:@"views"];
    return [[views firstObject] objectForKey:@"url"];
}


-(UIBarButtonItem *) bookmarkButton {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bookmark-small-mini"] style:UIBarButtonItemStylePlain target:self action:@selector(addBookmark:)];
}

-(void) addBookmark:(id)sender { [[BookmarkManager sharedManager] add:self.item as:BookmarkTypeDocument]; }


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

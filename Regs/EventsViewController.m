//
//  EventsViewController.m
//  Regs
//
//  Created by Matthew Zorn on 12/25/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "EventsViewController.h"
#import "RegsStyle.h"
#import "DocketCell.h"
#import "EncapsulatedTableView.h"

@interface EventsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) EncapsulatedTableView *encapsulatedTableView;

@end

@implementation EventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [RegsStyle primaryBackgroundColor];
    [self.view addSubview:self.containerView];
    [self.containerView addSubview:self.encapsulatedTableView];
    [self setTitleView:self.name subtitle:@"Recent/Upcoming Events"];
    [self updateViewConstraints];
    // Do any additional setup after loading the view.
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

- (void) dismiss:(id)sender {
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (CGFloat) tableViewHeight {
    CGFloat h = 0;
    
    for(NSDictionary *section in self.events) {
        h+=20;
        for(NSDictionary *event in section[@"values"]) {
            h+=[self heightForEntry:event];
        }
    }
    
    if(h > self.containerView.frame.size.height-10) return 0;
    
    return h;
}

-(CGFloat) heightForEntry:(NSDictionary *)item {
    
    CGFloat height = 50;
    
    CGSize constraint = CGSizeMake(self.encapsulatedTableView.tableView.frame.size.width, 20000);
    
    CGRect textRect = [item[@"description"] boundingRectWithSize:constraint
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:[RegsStyle detailTextFont]}
                                                          context:nil];
    
    height += textRect.size.height;
    
    textRect = [item[@"summary"] boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName:[RegsStyle titleLabelFont]}
                                               context:nil];
    height += textRect.size.height;
    return height;

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.events.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.events[section][@"values"] count];
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
        thv.textLabel.text = [self.dateFormatter stringFromDate:self.events[section][@"date"]];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    NSDictionary *entry = self.events[indexPath.section][@"values"][indexPath.row];
    
    if(!cell) {
        cell = [[DocketCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [RegsStyle titleLabelFont];
        cell.textLabel.numberOfLines = 0;
        cell.detailTextLabel.font = [RegsStyle detailTextFont];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentJustified;
    paragraph.lineBreakMode = NSLineBreakByTruncatingTail;
    
    cell.textLabel.text = entry[@"summary"];
    cell.detailTextLabel.text = entry[@"description"];
    
    //[document objectForKey:@"summary"]
    //[document objectForKey:@"date"]
    //[document objectForKey:@"type"]
    //[document objectForKEy:@"comments_open"]
    
    return cell;
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.encapsulatedTableView.tableView beginUpdates];
    [self.encapsulatedTableView.tableView endUpdates];
}

-(NSDateFormatter *)dateFormatter {
    if(!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormatter;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *entry = self.events[indexPath.section][@"values"][indexPath.row];
    return [self heightForEntry:entry];
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
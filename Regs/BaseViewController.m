//
//  BaseViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/27/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "BaseViewController.h"
#import "UIColor+Custom.h"
#import "RegsStyle.h"

@interface BaseViewController ()

@property (nonatomic, copy) NSString *cache_title;

@end

@implementation BaseViewController

- (id) init {
    if(self = [super init]) {
        self.didSetupConstraints = NO;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.containerView];
    self.edgesForExtendedLayout = UIRectEdgeLeft | UIRectEdgeRight;
    [self.containerView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL)animated {
    
    if(!self.cache_title) {
        self.cache_title = self.title;
    }
    
    self.title = self.cache_title;
}

-(UIView *)containerView {
    if(!_containerView) {
        _containerView = [[GradientView alloc] initWithFrame:self.view.frame];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _containerView.translatesAutoresizingMaskIntoConstraints = YES;
        UIColor *colorOne = [RegsStyle primaryBackgroundColor];
        UIColor *colorTwo = [RegsStyle secondaryBackgroundColor];
        _containerView.colors = @[colorOne, colorTwo];
    }
    return _containerView;
}

- (void) setTitleView:(NSString *)title subtitle:(NSString *)subtitle {
    
    if(subtitle.length == 0) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont fontWithName:@"Lato-Regular" size:18];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = title;
        label.textColor = [RegsStyle primaryBackgroundColor];
        label.numberOfLines = 2;
        label.minimumScaleFactor = .5;
        self.navigationItem.titleView = label;
        [label sizeToFit];
        label.adjustsFontSizeToFitWidth = YES;
    } else {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        NSAttributedString *text = [[NSAttributedString alloc] initWithString:title attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Regular" size:18]}];
        NSAttributedString *subtitleText = [[NSAttributedString alloc] initWithString:subtitle attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Lato-Regular" size:14]}];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [RegsStyle primaryBackgroundColor];
        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithAttributedString:text];
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [str appendAttributedString:subtitleText];
        self.navigationItem.titleView = label;
        label.attributedText = str;
        label.numberOfLines = 2;
        [label sizeToFit];
        label.adjustsFontSizeToFitWidth = YES;
        
    }
    
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

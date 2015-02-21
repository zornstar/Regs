//
//  HomeViewController.m
//  Regs
//
//  Created by Matthew Zorn on 11/12/14.
//  Copyright (c) 2014 Matthew Zorn. All rights reserved.
//

#import "HomeViewController.h"
#import "RegisterViewController.h"
#import "SearchViewController.h"
#import "PublicInspectionViewController.h"
#import "FederalAgencyViewController.h"
#import "BookmarkViewController.h"
#import "RegsNavigationController.h"
#import "AboutViewController.h"
#import "UIImage+Ext.h"
#import "RNFrostedSidebar.h"
#import "AppDelegate.h"
#import "RegsStyle.h"

@interface HomeViewController () <RNFrostedSidebarDelegate>

@property (nonatomic, strong) RNFrostedSidebar *sidebar;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSUInteger selectedIndex;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self sidebar:self.sidebar didTapItemAtIndex:0];
    [[UIApplication sharedApplication].windows.firstObject addGestureRecognizer:[self screenEdgePanGestureRecognizer]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(RNFrostedSidebar *)sidebar {
    if(!_sidebar) {
        NSArray *images = @[
                                [[UIImage imageNamed:@"newspaper"] imageWithColor:[RegsStyle primaryBackgroundColor]],
                                [[UIImage imageNamed:@"sticky-note"] imageWithColor:[RegsStyle primaryBackgroundColor]],
                                [[UIImage imageNamed:@"magnifying"] imageWithColor:[RegsStyle primaryBackgroundColor]],
                                [[UIImage imageNamed:@"government"] imageWithColor:[RegsStyle primaryBackgroundColor]],
                                [[UIImage imageNamed:@"bookmark-small-mini"] imageWithColor:[RegsStyle primaryBackgroundColor]],
                                [[UIImage imageNamed:@"info"] imageWithColor:[RegsStyle primaryBackgroundColor]]
                            ];
        NSArray *colors = @[
                                [RegsStyle primaryBackgroundColor],
                                [RegsStyle primaryBackgroundColor],
                                [RegsStyle primaryBackgroundColor],
                                [RegsStyle primaryBackgroundColor],
                                [RegsStyle primaryBackgroundColor],
                                [RegsStyle primaryBackgroundColor],

                                
                            ];//#d6f1f2
        
        _sidebar = [[RNFrostedSidebar alloc] initWithImages:images selectedIndices:[[NSIndexSet alloc] initWithIndex:0]  borderColors:colors];
        _sidebar.width = 120;
        _sidebar.delegate = self;
        _sidebar.showFromRight = YES;
        _sidebar.isSingleSelect = YES;
        _sidebar.itemBackgroundColor = [RegsStyle darkBackgroundColor];
        _sidebar.tintColor = [RegsStyle darkBackgroundColor];
    }
    return _sidebar;
}

-(NSArray *)viewControllers {
    if(!_viewControllers) {
        NSArray *vcs = @[ [[RegisterViewController alloc] init], [[PublicInspectionViewController alloc] init], [[SearchViewController alloc] init], [[FederalAgencyViewController alloc] init], [[BookmarkViewController alloc] init], [[AboutViewController alloc] init] ];
        NSMutableArray *_vcs = [NSMutableArray array];
        for(UIViewController *vc in vcs) {
            vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"select-circle-area"] style:UIBarButtonItemStylePlain target:self action:@selector(showSidebar:)];
            RegsNavigationController *nc = [[RegsNavigationController alloc] initWithRootViewController:vc];
            [_vcs addObject:nc];
        }
        
        _viewControllers = _vcs;
    }
    
    return _viewControllers;
}


- (void) showSidebar:(id)sender {
    
    if([sender isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        UIScreenEdgePanGestureRecognizer *gesture = (UIScreenEdgePanGestureRecognizer *)sender;
        if(gesture.state != UIGestureRecognizerStateBegan) return;
    }
    [self.sidebar showAnimated:YES];
}

- (void)sidebar:(RNFrostedSidebar *)sidebar didTapItemAtIndex:(NSUInteger)index {
    
    if([self.viewControllers indexOfObject:self.selectedViewController] == index) {
        [(UINavigationController *)self.selectedViewController popToRootViewControllerAnimated:NO];
    }
    
    if(self.selectedViewController) {
        
        [self.selectedViewController removeFromParentViewController];
        [self.selectedViewController.view removeFromSuperview];
        
    }
    
    self.selectedViewController = self.viewControllers[index];
    
    [self addChildViewController:self.selectedViewController];
    [self.view insertSubview:self.selectedViewController.view belowSubview:sidebar.view];
    
    [sidebar dismissAnimated:YES];
}

- (UIScreenEdgePanGestureRecognizer *) screenEdgePanGestureRecognizer {
    UIScreenEdgePanGestureRecognizer *gesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(showSidebar:)];
    gesture.edges = UIRectEdgeRight;
    return gesture;
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


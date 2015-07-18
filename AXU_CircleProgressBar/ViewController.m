//
//  ViewController.m
//  AXU_CircleProgressBar
//
//  Created by Andy Xu on 15/4/1.
//  Copyright (c) 2015年 Andy Xu. All rights reserved.
//

#import "ViewController.h"
#import "ArcProgressView.h"

@interface ViewController ()
@end

@implementation ViewController {
    ArcProgressView *progressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    progressView = [[ArcProgressView alloc] initWithDiameter:100.0f arcWidth:5.0f arcRadian:300.0f];
    [self.view addSubview:progressView];
    [progressView changeProgress:0.0f isAnimated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews {
    [progressView setCenter:self.view.center];
}

- (IBAction)btnAnimation_OnClicked:(id)sender {
    [progressView changeProgress:1.0f isAnimated:YES];
}

- (IBAction)btnReset_OnClicked:(id)sender {
    [progressView changeProgress:0.0f isAnimated:NO];
}

@end

//
//  ViewController.m
//  OpenGLESDemo01
//
//  Created by MAC on 2020/9/8.
//  Copyright © 2020 MAC. All rights reserved.
//

#import "ViewController.h"
#import "YQGLView.h"

@interface ViewController ()

@property (nonatomic, strong) YQGLView *glView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.glView = (YQGLView *)self.view;
}


@end

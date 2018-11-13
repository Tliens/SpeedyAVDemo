//
//  ViewController.m
//  VideoCamera
//
//  Created by Churchill Navigation on 2/17/16.
//  Copyright © 2016 Churchill Navigation. All rights reserved.
//

#import "ViewController.h"
#import "VideoPlayer.h"

@interface ViewController ()

@property (nonatomic, retain) IBOutlet UIView *videoView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [[VideoPlayer sharedManager] setView:_videoView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  ViewController.m
//  WaveTest
//
//  Created by JustinYang on 16/5/25.
//  Copyright © 2016年 JustinYang. All rights reserved.
//

#import "ViewController.h"
#import "WaveAnimationView.h"
@interface ViewController ()
@property (nonatomic,strong) WaveAnimationView *waveView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.waveView = [[WaveAnimationView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width/2.,
                                                                        200, self.view.bounds.size.width/2., 200)];
    self.waveView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.waveView];
    self.waveView.layer.masksToBounds = YES; 
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

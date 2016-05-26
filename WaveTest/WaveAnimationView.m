//
//  waveAnimationView.m
//  WaveTest
//
//  Created by JustinYang on 16/5/25.
//  Copyright © 2016年 JustinYang. All rights reserved.
//

#import "WaveAnimationView.h"

@interface WaveAnimationView ()
@property (nonatomic,strong) CAShapeLayer *curLayer;
@property (nonatomic,strong) NSTimer      *timer;

@property (nonatomic)       NSInteger     oldWaveCount;

//在这个线程中重新画图和给waveCount赋值
@property (nonatomic,strong) NSThread     *reDrawThread;


@end

@implementation WaveAnimationView
{
    dispatch_semaphore_t _sema;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.curLayer = [CAShapeLayer layer];
        self.curLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.curLayer.fillColor = nil;
        self.curLayer.lineDashPattern = @[@(frame.size.width-10),@10];
        self.curLayer.lineWidth = 3.;
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(-frame.size.width, frame.size.height/2.)];
        [path addLineToPoint:CGPointMake(frame.size.width, frame.size.height/2.)];
        self.curLayer.path = path.CGPath;
        [self.layer addSublayer:self.curLayer];
        [self animation];
        
        self.reDrawThread = [[NSThread alloc] initWithTarget:self selector:@selector(setUp) object:nil];
        [self.reDrawThread start];
       
    }
    return self;
}
-(void)setUp{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(draw:) userInfo:nil repeats:YES];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(generateData) userInfo:nil repeats:YES];
    _sema = dispatch_semaphore_create(1);
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:self.timer forMode:NSRunLoopCommonModes];
    [runLoop addTimer:timer forMode:NSRunLoopCommonModes];
    [runLoop run];
}
-(void)animation{
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.x";
    animation.byValue = @(self.frame.size.width);
    animation.duration = 5;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.removedOnCompletion = NO;
//    animation.fillMode = kCAFillModeForwards;
    animation.delegate = self;
    animation.repeatCount = NSIntegerMax;
    [self.curLayer addAnimation:animation forKey:@"animation"];
}
#define kHGap 20
-(void)draw:(NSTimer *)timer{
    dispatch_semaphore_wait(_sema, 60);
        UIBezierPath *path = [UIBezierPath bezierPath];
        self.curLayer.path = nil;
        if (self.waveCount == 0 && self.oldWaveCount == 0) {
            self.curLayer.lineDashPattern = @[@(self.frame.size.width-10),@10];
        }else{
            self.curLayer.lineDashPattern = nil;
        }
        if (self.waveCount == 0) {//画直线
            
            
            [path moveToPoint:CGPointMake(-self.frame.size.width, self.frame.size.height/2.)];
            [path addLineToPoint:CGPointMake(0, self.frame.size.height/2.)];
            
            
        }
        else{
            [path moveToPoint:CGPointMake(-self.frame.size.width, self.frame.size.height/2.)];
            NSInteger count = self.waveCount>=4?4:self.waveCount;
            CGFloat width = self.frame.size.width/8.;
            CGPoint point = CGPointMake((4-count)*2*width-self.frame.size.width,
                                        self.frame.size.height/2.);
            [path addLineToPoint:point];
            if (self.type == WaveTypeSine) {
                for (int i = 0; i < count*2; i++) {
                    CGPoint nextPoint = CGPointMake(point.x+width, point.y);
                    CGPoint ctrl = CGPointMake((point.x+nextPoint.x)/2., i%2==0?kHGap:(self.frame.size.height-kHGap));
                    [path addQuadCurveToPoint:nextPoint controlPoint:ctrl];
                    point = nextPoint;
                }
            }else if(self.type == WaveTypeSawtooth){
                for (int i = 0; i < count; i++){ //画剩下的波形
                    CGFloat perSeg = width*2/9.;
                    //锯齿波分为9端
                    CGPoint nextPoint = CGPointMake(point.x+perSeg, point.y);
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y-10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y+10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y-40)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y+40)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y-10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    point = nextPoint;
                    
                }
            }else{
                CGFloat duty = 30.;
                for (int i = 0; i < count; i++) {
                    
                    CGPoint nextPoint = CGPointMake(point.x+(2*width-duty)/2., point.y);
                    [path addLineToPoint:nextPoint];
                    
                    [path addLineToPoint:CGPointMake(nextPoint.x, 10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+duty, nextPoint.y);
                    [path addLineToPoint:CGPointMake(nextPoint.x, 10)];
                    
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+(2*width-duty)/2., nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    
                    point = nextPoint;
                }
            }
        }
        
        if (self.oldWaveCount == 0) {
            [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height/2.)];
        }else{
            [path moveToPoint:CGPointMake(0, self.frame.size.height/2.)];
            NSInteger count = self.oldWaveCount>=4?4:self.oldWaveCount;
            CGFloat width = self.frame.size.width/8.;
            CGPoint point = CGPointMake((4-count)*2*width,
                                        self.frame.size.height/2.);
            [path addLineToPoint:point];
            if (self.type == WaveTypeSine) {
                for (int i = 0; i < count*2; i++) {
                    CGPoint nextPoint = CGPointMake(point.x+width, point.y);
                    CGPoint ctrl = CGPointMake((point.x+nextPoint.x)/2., i%2==0?kHGap:(self.frame.size.height-kHGap));
                    [path addQuadCurveToPoint:nextPoint controlPoint:ctrl];
                    point = nextPoint;
                }
            }else if(self.type == WaveTypeSawtooth){
                for (int i = 0; i < count; i++){ //画剩下的波形
                    CGFloat perSeg = width*2/9.;
                    //锯齿波分为9端
                    CGPoint nextPoint = CGPointMake(point.x+perSeg, point.y);
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y-10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y+10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y-40)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y+40)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addQuadCurveToPoint:nextPoint controlPoint:CGPointMake((nextPoint.x-perSeg/2.), nextPoint.y-10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+perSeg, nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    point = nextPoint;
                }
                
            }else{
                CGFloat duty = 30.;
                for (int i = 0; i < count; i++) {
                    
                    CGPoint nextPoint = CGPointMake(point.x+(2*width-duty)/2., point.y);
                    [path addLineToPoint:nextPoint];
                    
                    [path addLineToPoint:CGPointMake(nextPoint.x, 10)];
                    
                    nextPoint = CGPointMake(nextPoint.x+duty, nextPoint.y);
                    [path addLineToPoint:CGPointMake(nextPoint.x, 10)];
                    
                    [path addLineToPoint:nextPoint];
                    
                    nextPoint = CGPointMake(nextPoint.x+(2*width-duty)/2., nextPoint.y);
                    [path addLineToPoint:nextPoint];
                    
                    point = nextPoint;
                }
            }
            
        }
        
        self.curLayer.path = path.CGPath;
        
        
        _oldWaveCount = _waveCount;
        _waveCount = 0;
    
    dispatch_semaphore_signal(_sema);
    
}

-(void)generateData{
    //产生输入测试
    if (arc4random()%10 < 5) {
        self.waveCount = 0 ;
    }else{
        self.waveCount = arc4random()%6;
    }
}
-(void)setWaveCount:(NSInteger)waveCount{
    [self performSelector:@selector(setWaveCountOnThread:) onThread:self.reDrawThread withObject:@(waveCount) waitUntilDone:YES];
}
-(void)setWaveCountOnThread:(id)count{
    dispatch_semaphore_wait(_sema, 60);
    _waveCount = 3;//[(NSNumber *)count integerValue];
    dispatch_semaphore_signal(_sema);
}

//先给外部提供停止函数？
-(void)dealloc{
    [self.reDrawThread cancel];
}
-(void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"xxx");
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.curLayer.path = nil;
}
@end

//
//  waveAnimationView.h
//  WaveTest
//
//  Created by JustinYang on 16/5/25.
//  Copyright © 2016年 JustinYang. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSInteger,WaveType) {
    WaveTypeSine,
    WaveTypeSawtooth,
    WaveTypeSquare
};

@interface WaveAnimationView : UIView
@property (nonatomic) NSInteger waveCount;
@property (nonatomic) WaveType type;
/**
 *  默认白色
 */
@property (nonatomic,strong) UIColor    *drawColor;

/**
 *  默认3
 */
@property (nonatomic)        CGFloat    lineWidth;

-(void)startAnimation;
/**
 *  必须调用它，才能保证view被销毁 如在VC的dealloc方法中调用它，
 */
-(void)stopAnimation;
@end

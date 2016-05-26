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
@end

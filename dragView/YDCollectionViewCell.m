//
//  YDCollectionViewCell.m
//  dragView
//
//  Created by yuandiLiao on 2017/5/26.
//  Copyright © 2017年 yuandiLiao. All rights reserved.
//

#import "YDCollectionViewCell.h"



@implementation YDCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    
    if (self = [super initWithFrame:frame]) {
        self.label = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.label];
        self.label.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}
-(void)starAnimation:(BOOL)animaiton
{
    if (animaiton) {
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //抖动的话添加一个旋转角度给他就好
        basicAnimation.fromValue = @(-M_PI_4/14);
        basicAnimation.toValue = @(M_PI_4/14);
        basicAnimation.duration = 0.08;
        basicAnimation.repeatCount = MAXFLOAT;
        basicAnimation.autoreverses = YES;
        [self.layer addAnimation:basicAnimation forKey:nil];

    }else{
        
        [self.layer addAnimation:[CAAnimation animation] forKey:nil];
    }
    
}

@end

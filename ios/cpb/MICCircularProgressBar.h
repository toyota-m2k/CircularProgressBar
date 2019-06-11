//
//  MICCircleProgressBar.h
//  AnotherWorld
//
//  Created by @toyota-m2k on 2019/03/06.
//  Copyright © 2019年 @toyota-m2k. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MICCircularProgressBar : UIView

@property (nonatomic) NSInteger progress;

@property (nonatomic) bool showText;
@property (nonatomic) UIColor* ringBaseColor;
@property (nonatomic) UIColor* progressColor;
@property (nonatomic) UIColor* insideRingColor;
@property (nonatomic) UIColor* textColor;
@property (nonatomic) CGFloat ringThicknessRatio;
@property (nonatomic,readonly) CGFloat lineWidth;

@end

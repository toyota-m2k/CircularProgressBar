//
//  MMJCircleProgressBar.h
//  AnotherWorld
//
//  Created by Mitsuki Toyota on 2019/03/06.
//  Copyright © 2019年 Mitsuki Toyota. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMJCircleProgressBar : UIView

@property (nonatomic) double progress;

@property (nonatomic) bool showText;
@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) UIColor* lineBgColor;
@property (nonatomic) UIColor* lineFgColor;
@property (nonatomic) UIColor* insideColor;
@property (nonatomic) UIColor* textColor;

@end

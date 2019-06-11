//
//  ViewController.m
//  cpb
//
//  Created by @toyota-m2k on 2019/06/10.
//  Copyright © 2019 @toyota-m2k. All rights reserved.
//

#import "ViewController.h"
#import "MICUiSimpleLayoutView.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "MICUiStackLayout.h"
#import "MICCircularProgressBar.h"
#import "MICUiColorUtil.h"

@interface ViewController ()
@end

@implementation ViewController {
    MICUiStackLayout* _layouter;
    NSInteger _progress;
    MICCircularProgressBar* _bar1;
    MICCircularProgressBar* _bar2;
    MICCircularProgressBar* _bar3;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    let parent = self.view;
    MICRect parentRect(parent.bounds);
    let layouter = [[MICUiStackLayout alloc] initWithOrientation:MICUiVertical alignment:MICUiAlignExCENTER];
    let container = [[MICUiSimpleLayoutView alloc] initWithFrame:parentRect andLayouter:layouter];
    
    _bar1 = [[MICCircularProgressBar alloc] initWithFrame:MICRect(100, 100)];
    [layouter addChild:_bar1];
    [layouter addSpacer:10];

    _bar2 = [[MICCircularProgressBar alloc] initWithFrame:MICRect(100, 100)];
    _bar2.ringThicknessRatio = 0.1;
    _bar2.textColor = UIColor.blackColor;
    _bar2.insideRingColor = UIColor.whiteColor;
    _bar2.ringBaseColor = MICUiColorRGB(0xFFC0C0);
    _bar2.progressColor = UIColor.redColor;
    [layouter addChild:_bar2];
    [layouter addSpacer:10];

    _bar3 = [[MICCircularProgressBar alloc] initWithFrame:MICRect(100, 100)];
    _bar3.ringThicknessRatio = 1;
    [layouter addChild:_bar3];
    [layouter addSpacer:10];

    
    let button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Next" forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:self action:@selector(onNext:) forControlEvents:UIControlEventTouchUpInside];
    [layouter addChild:button];
    
    [container sizeToFit];
    [layouter updateLayout:false onCompleted:nil];
    
    MICRect rc(container.frame);
    rc.moveCenter(parentRect.center());
    container.frame = rc;
    
    [parent addSubview:container];
    _layouter = layouter;
    _progress = 0;
}

- (void) onNext:(id)button {
    if(_progress>=100) {
        _progress = 0;
    } else {
        _progress = MIN(100, _progress+7);
    }
    _bar1.progress = _progress;
    _bar2.progress = _progress;
    _bar3.progress = _progress;
}

@end

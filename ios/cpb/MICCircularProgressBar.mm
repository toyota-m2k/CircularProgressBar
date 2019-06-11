//
//  MICCircularProgressBar.m
//
//  Created by @toyota-m2k on 2019/03/06.
//  Copyright © 2019年 @toyota-m2k. All rights reserved.
//

#import "MICCircularProgressBar.h"
#import "MICVar.h"
#import "MICUiRectUtil.h"
#import "MICUiColorUtil.h"
#import "MICCGContext.h"

#define MIC_DEF_RING_BG_COLOR   MICUiColorRGB256(180,180,180)
#define MIC_DEF_RING_FG_COLOR   MICUiColorRGB256(0,122,255)
#define MIC_DEF_CENTER_COLOR    MICUiColorARGB256(150,0,0,0)
#define MIC_DEF_TEXT_COLOR      UIColor.whiteColor

@interface MICRingFgLayer : CALayer
@end

@implementation  MICRingFgLayer {
    __weak MICCircularProgressBar* _owner;
}
- (instancetype)initWithOwner:(MICCircularProgressBar*)owner {
    self = [super init];
    if(self) {
        _owner = owner;
        [self updateDimmension];
    }
    return self;
}

- (void) updateDimmension {
    MICCircularProgressBar* owner = _owner;
    if(nil!=owner) {
        MICRect rc(owner.frame);
        self.frame = MICRect(rc.size);
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)rctx {
    MICCGContext ctx(rctx,false);
    MICCircularProgressBar* owner = _owner;
    if(nil==owner) {
        return;
    }
    MICRect rc(self.frame.size);
    ctx.clearRect(rc);
    rc.deflate(owner.lineWidth);
    
    double progress = MAX(MIN(((double)owner.progress)/100,0.9999),0);
    double rad = (2*M_PI) * progress - M_PI_2;
    
    MICCGContext::Path path(ctx);
    path.addArc(rc.center().x, rc.center().y, MIN(rc.height(),rc.width())/2 , -M_PI_2, rad, false);
    ctx.setLineWidth(owner.lineWidth);
    ctx.setStrokeColor(owner.progressColor);
    ctx.strokePath();
}
@end

@implementation MICCircularProgressBar {
    CALayer* _progressLayer;
//    CGFloat _lineWidth;
    CGFloat _ringThicknessRatio;
    MICRingFgLayer* _fgLayer;
    UILabel* _textView;
    CGFloat _refSize;
    bool _needsLayout;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(nil!=self) {
        self.backgroundColor = UIColor.clearColor;
        _needsLayout = true;
        _progress = 0;
        _showText = true;
        //_lineWidth = MAX(frame.size.height*0.1, 4);
        _ringThicknessRatio = 0.2;
        _ringBaseColor = MIC_DEF_RING_BG_COLOR;
        _progressColor = MIC_DEF_RING_FG_COLOR;
        _insideRingColor = MIC_DEF_CENTER_COLOR;
        _textColor = MIC_DEF_TEXT_COLOR;
        _fgLayer = [[MICRingFgLayer alloc] initWithOwner:self];
        _fgLayer.frame = MICRect(frame.size);

        _refSize = 0;
        _textView = [[UILabel alloc] init];
        _textView.backgroundColor = UIColor.clearColor;
        _textView.textColor = _textColor;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.hidden = true;
        [self.layer addSublayer:_fgLayer];
        [self addSubview:_textView];
        [self updateDimmension];
    }
    return self;
}

- (void) updateDimmension {
    if(!_needsLayout) {
        return;
    }
    MICRect rcFrame(self.frame.size);
    _needsLayout = false;
    if(nil!=_textView) {
        _textView.hidden = true;
        if(_showText) {
            _textView.text = @"100%";
            if(_refSize==0) {
                var font = [UIFont boldSystemFontOfSize:12];
                _textView.font = font;
                [_textView sizeToFit];
                MICRect rcText(_textView.frame);
                _refSize = sqrt(pow(rcText.width(),2)+pow(rcText.height(),2));
            }
            
            CGFloat diam = MIN(rcFrame.width(),rcFrame.height()) - self.lineWidth*2;
            CGFloat fontSize = 12.0 * diam / _refSize;
            _textView.font = [UIFont boldSystemFontOfSize:fontSize];
            [_textView sizeToFit];
            MICRect rcText(_textView.frame);
            rcText.moveCenter(rcFrame.center());
            _textView.frame = rcText;
            [self updateTextProgress];
            _textView.hidden = false;
        }
    }
    
    if(nil!=_fgLayer) {
        _fgLayer.frame = rcFrame;
        [_fgLayer updateDimmension];
    }
}

- (CGFloat) lineWidth {
    return MIN(self.frame.size.height,self.frame.size.width) * _ringThicknessRatio / 2.0;
}

- (void)setRingThicknessRatio:(CGFloat)ratio {
    ratio = MIN(100,MAX(0,ratio));
    if(_ringThicknessRatio!=ratio) {
        _ringThicknessRatio = ratio;
        _needsLayout = true;
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    _needsLayout = true;
}

- (void)setNeedsLayout {
    [super setNeedsLayout];
    [self updateDimmension];
}

- (void)setShowText:(bool)showText {
    _showText = showText;
    if(showText) {
        [self updateDimmension];
    } else {
        _textView.hidden = true;
    }
}

- (void) setTextColor:(UIColor *)color {
    if(color!=_textColor) {
        _textColor = color;
        _textView.textColor = _textColor;
    }
}

- (void)updateTextProgress {
    _textView.text = [NSString stringWithFormat:@"%ld%%", (long)_progress];
}

- (void)setProgress:(NSInteger)progress {
    if(_progress != progress) {
        _progress = progress;
        [self updateTextProgress];
        [_fgLayer setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    MICRect rc(rect);
    MICCGContext ctx;
   
    rc.deflate(self.lineWidth);
    ctx.setFillColor(_insideRingColor);
    ctx.setStrokeColor(_ringBaseColor);
    ctx.setLineWidth(self.lineWidth);
    ctx.fillEllipseInRect(rc);
    ctx.strokeEllipseInRect(rc);
}

@end

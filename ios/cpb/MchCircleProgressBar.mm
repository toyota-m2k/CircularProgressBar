//
//  MMJCircleProgressBar.m
//  AnotherWorld
//
//  Created by Mitsuki Toyota on 2019/03/06.
//  Copyright © 2019年 Mitsuki Toyota. All rights reserved.
//

#import "MMJCircleProgressBar.h"
#import "MMJCGContext.h"
#import "MMJVar.h"
#import "MMJUiRectUtil.h"
#import "MMJUiColorUtil.h"

#define MMJ_DEF_RING_BG_COLOR   MMJUiColorRGB256(180,180,180)
#define MMJ_DEF_RING_FG_COLOR   MMJUiColorRGB256(0,122,255)
#define MMJ_DEF_CENTER_COLOR    MMJUiColorARGB256(150,0,0,0)
#define MMJ_DEF_TEXT_COLOR      UIColor.whiteColor

@interface MMJRingFgLayer : CALayer
@end

@implementation  MMJRingFgLayer {
    __weak MMJCircleProgressBar* _owner;
}
- (instancetype)initWithOwner:(MMJCircleProgressBar*)owner {
    self = [super init];
    if(self) {
        _owner = owner;
        [self updateDimmension];
    }
    return self;
}

- (void) updateDimmension {
    MMJCircleProgressBar* owner = _owner;
    if(nil!=owner) {
        MMJRect rc(owner.frame);
        self.frame = MMJRect(rc.size);
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)rctx {
    MMJCGContext ctx(rctx,false);
    MMJCircleProgressBar* owner = _owner;
    if(nil==owner) {
        return;
    }
    MMJRect rc(self.frame.size);
    ctx.clearRect(rc);
    rc.deflate(owner.lineWidth);
    
    double progress = MAX(MIN(owner.progress,0.999),0);
    double rad = (2*M_PI) * progress - M_PI_2;
    
    MMJCGContext::Path path(ctx);
    path.addArc(rc.center().x, rc.center().y, MIN(rc.height(),rc.width())/2 , -M_PI_2, rad, false);
    ctx.setLineWidth(owner.lineWidth);
    ctx.setStrokeColor(owner.lineFgColor);
    ctx.strokePath();
}
@end

@implementation MMJCircleProgressBar {
    CALayer* _progressLayer;
    CGFloat _lineWidth;
    MMJRingFgLayer* _fgLayer;
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
        _lineWidth = MAX(frame.size.height*0.1, 4);
        _lineBgColor = MMJ_DEF_RING_BG_COLOR;
        _lineFgColor = MMJ_DEF_RING_FG_COLOR;
        _insideColor = MMJ_DEF_CENTER_COLOR;
        _textColor = MMJ_DEF_TEXT_COLOR;
        _fgLayer = [[MMJRingFgLayer alloc] initWithOwner:self];
        _fgLayer.frame = MMJRect(frame.size);

        _refSize = 0;
        _textView = [[UILabel alloc] init];
        _textView.backgroundColor = UIColor.clearColor;
        _textView.textColor = _textColor;
        _textView.textAlignment = NSTextAlignmentCenter;
        _textView.hidden = true;
        [self addSubview:_textView];
        [self.layer addSublayer:_fgLayer];
        [self updateDimmension];
    }
    return self;
}

- (void) updateDimmension {
    if(!_needsLayout) {
        return;
    }
    MMJRect rcFrame(self.frame.size);
    _needsLayout = false;
    if(nil!=_textView) {
        _textView.hidden = true;
        if(_showText) {
            _textView.text = @"100%";
            if(_refSize==0) {
                var font = [UIFont boldSystemFontOfSize:12];
                _textView.font = font;
                [_textView sizeToFit];
                MMJRect rcText(_textView.frame);
                _refSize = sqrt(pow(rcText.width(),2)+pow(rcText.height(),2));
            }
            
            CGFloat diam = MIN(rcFrame.width(),rcFrame.height()) - _lineWidth*2;
            CGFloat fontSize = 12.0 * diam / _refSize;
            _textView.font = [UIFont boldSystemFontOfSize:fontSize];
            [_textView sizeToFit];
            MMJRect rcText(_textView.frame);
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

- (void)setLineWidth:(CGFloat)lineWidth {
    _lineWidth = lineWidth;
    _needsLayout = true;
    [self updateDimmension];
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

- (void)updateTextProgress {
    _textView.text = [NSString stringWithFormat:@"%d%%", (int)(_progress*100)];
}

- (void)setProgress:(double)progress {
    if(_progress != progress) {
        _progress = progress;
        [self updateTextProgress];
        [_fgLayer setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    MMJRect rc(rect);
    MMJCGContext ctx;
   
    rc.deflate(_lineWidth);
    ctx.setFillColor(_insideColor);
    ctx.setStrokeColor(_lineBgColor);
    ctx.setLineWidth(_lineWidth);
    ctx.fillEllipseInRect(rc);
    ctx.strokeEllipseInRect(rc);
}

@end

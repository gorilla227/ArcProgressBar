//
//  ArcProgressView.m
//  AXU_CircleProgressBar
//
//  Created by Andy Xu on 15/4/1.
//  Copyright (c) 2015年 Andy Xu. All rights reserved.
//

#import "ArcProgressView.h"

@implementation ArcProgressView {
    CGFloat arcDiameter;
    CGFloat arcWidth;
    CGFloat arcAngle;
    CAShapeLayer *progressBarBackgroundLayer;
    CAShapeLayer *progressBarLayer;
    UILabel *labelProgress;
    CATransition *transition;
    NSInteger progressNumber;
    NSInteger targetProgress;
    BOOL isAscendProgress;
}
@synthesize currentProgress, progressBarBackgroundColor;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithDiameter:(CGFloat)diameter arcWidth:(CGFloat)width arcRadian:(CGFloat)angle {
    self = [super initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    if (self) {
        arcDiameter = diameter;
        arcWidth = width;
        arcAngle = angle;
        
        [self addObserver:self forKeyPath:@"progressBarBackgroundColor" options:NSKeyValueObservingOptionInitial context:nil];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.center radius:(arcDiameter - arcWidth)/2 startAngle:degressToRadians(-90 - arcAngle / 2) endAngle:degressToRadians(arcAngle / 2 - 90) clockwise:YES];
        
        //Draw Background
        if (!progressBarBackgroundColor) {
            progressBarBackgroundColor = [UIColor grayColor];
        }
        progressBarBackgroundLayer = [CAShapeLayer layer];
        [progressBarBackgroundLayer setFrame:self.bounds];
        [progressBarBackgroundLayer setFillColor:[UIColor clearColor].CGColor];
        [progressBarBackgroundLayer setStrokeColor:progressBarBackgroundColor.CGColor];
        [progressBarBackgroundLayer setOpacity:0.25f];
        [progressBarBackgroundLayer setLineCap:kCALineCapRound];
        [progressBarBackgroundLayer setLineWidth:arcWidth];
        [progressBarBackgroundLayer setPath:path.CGPath];
        [self.layer addSublayer:progressBarBackgroundLayer];
        
        //Draw Gradient Layer
        CALayer *gradientLayer = [CALayer layer];
        [gradientLayer setFrame:progressBarBackgroundLayer.bounds];
        CAGradientLayer *leftGradientLayer = [CAGradientLayer layer];
        [leftGradientLayer setFrame:CGRectMake(0, 0, arcDiameter / 2, arcDiameter)];
        [leftGradientLayer setColors:@[(id)[UIColor yellowColor].CGColor, (id)[UIColor redColor].CGColor]];
        [leftGradientLayer setLocations:@[@0, @0.8]];
        CAGradientLayer *rightGradientLayer = [CAGradientLayer layer];
        [rightGradientLayer setFrame:CGRectMake(arcDiameter / 2, 0, arcDiameter / 2, arcDiameter)];
        [rightGradientLayer setColors:@[(id)[UIColor yellowColor].CGColor, (id)[UIColor blueColor].CGColor]];
        [rightGradientLayer setLocations:@[@0, @0.8]];
        [gradientLayer addSublayer:leftGradientLayer];
        [gradientLayer addSublayer:rightGradientLayer];
        
        //Draw ProgressBar Layer
        progressBarLayer = [CAShapeLayer layer];
        [progressBarLayer setFrame:progressBarBackgroundLayer.bounds];
        [progressBarLayer setFillColor:[UIColor clearColor].CGColor];
        [progressBarLayer setStrokeColor:[UIColor blackColor].CGColor];
        [progressBarLayer setLineCap:kCALineCapRound];
        [progressBarLayer setLineWidth:arcWidth];
        [progressBarLayer setPath:path.CGPath];
        [progressBarLayer setStrokeEnd:0.0f];
        [gradientLayer setMask:progressBarLayer];
        [self.layer addSublayer:gradientLayer];
        
        //Label Initialization
        labelProgress = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, (arcDiameter - arcWidth) / sqrtf(2), (arcDiameter - arcWidth) / sqrtf(2))];
        [labelProgress setCenter:self.center];
        [labelProgress setText:[NSString stringWithFormat:@"%.f%%", currentProgress * 100]];
        [labelProgress setAdjustsFontSizeToFitWidth:YES];
        [labelProgress setTextAlignment:NSTextAlignmentCenter];
        [labelProgress setFont:[UIFont systemFontOfSize:25.0f]];
        [labelProgress setLineBreakMode:NSLineBreakByClipping];
        [labelProgress setNumberOfLines:1];
        [labelProgress setMinimumScaleFactor:0.5];
        [self addSubview:labelProgress];
        
        //Label Animation Initialization
        transition = [CATransition animation];
        [transition setDelegate:self];
        [transition setDuration:kAnimationDuration];
        [transition setType:kCATransitionFade];
        [transition setRemovedOnCompletion:YES];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"progressBarBackgroundColor"]) {
        [progressBarBackgroundLayer setStrokeColor:progressBarBackgroundColor.CGColor];
    }
}

- (void)changeProgress:(CGFloat)progress isAnimated:(BOOL)animated {
    if (progress < 0) {
        progress = 0;
    }
    else if (progress > 1) {
        progress = 1;
    }

    if (progress != progressBarLayer.strokeEnd) {
        if (animated) {
            progressNumber = progressBarLayer.strokeEnd * 100;
            targetProgress = progress * 100;
            isAscendProgress = (targetProgress > progressNumber)?YES:NO;
            
            [labelProgress.layer addAnimation:transition forKey:nil];
            [CATransaction begin];
            [CATransaction setDisableActions:NO];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [CATransaction setAnimationDuration:kAnimationDuration];
            [progressBarLayer setStrokeEnd:isAscendProgress?progressBarLayer.strokeEnd+0.01:progressBarLayer.strokeEnd-0.01];
            [CATransaction commit];
        }
        else {
            [labelProgress setText:[NSString stringWithFormat:@"%.f%%", progress * 100]];
//            [progressBarLayer setStrokeEnd:progress];
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [CATransaction setAnimationDuration:kAnimationDuration];
            [progressBarLayer setStrokeEnd:progress];
            [CATransaction commit];
        }
        
    }
}

- (CGFloat)currentProgress {
    return progressBarLayer.strokeEnd;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        if (progressNumber != targetProgress) {
            [labelProgress.layer addAnimation:transition forKey:nil];
            [labelProgress setText:[NSString stringWithFormat:@"%lu%%", isAscendProgress?++progressNumber:--progressNumber]];
            [CATransaction begin];
            [CATransaction setDisableActions:NO];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
            [CATransaction setAnimationDuration:kAnimationDuration];
            [progressBarLayer setStrokeEnd:isAscendProgress?progressBarLayer.strokeEnd+0.01:progressBarLayer.strokeEnd-0.01];
            [CATransaction commit];
        }
    }
}

@end

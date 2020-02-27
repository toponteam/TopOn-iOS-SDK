//
//  ATMyOfferProgressView.m
//  AnyThinkSDK
//
//  Created by Topon on 2019/9/26.
//  Copyright © 2019 Martin Lau. All rights reserved.
//

#import "ATMyOfferProgressView.h"

@interface ATMyOfferProgressView()

@property(nonatomic,strong)UILabel *label;

@end
@implementation ATMyOfferProgressView

-(void)drawRect:(CGRect)rect {
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    UIBezierPath *path0 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                         radius:self.frame.size.width/2
                                                     startAngle:-M_PI_2
                                                       endAngle:M_PI_2 * 3 clockwise:YES];
    CGContextAddPath(contextRef, path0.CGPath);
    CGContextFillPath(contextRef);
    CGContextSetRGBFillColor(contextRef, 50.0/255.0, 50.0/255.0, 50.0/255.0, 0.8);
    CGContextStrokePath(contextRef);
    
    CGContextRef contextRef1 = UIGraphicsGetCurrentContext();
    UIBezierPath *path1 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                         radius:self.frame.size.width/2 - 1.5
                                                     startAngle:-M_PI_2
                                                       endAngle:M_PI_2 * 3 clockwise:YES];
    CGContextAddPath(contextRef1,path1.CGPath);
    CGContextSetRGBStrokeColor(contextRef1, 50.0/255.0, 50.0/255.0, 50.0/255.0, 1);
    CGContextSetLineWidth(contextRef1, 3);
    CGContextStrokePath(contextRef1);
    
    CGContextRef contextRef2 = UIGraphicsGetCurrentContext();
    UIBezierPath *path2 = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)
                                                         radius:self.frame.size.width/2 - 1.5
                                                     startAngle:-M_PI_2
                                                       endAngle:_progress/_signProgress * M_PI * 2 - M_PI_2 clockwise:YES];
    CGContextAddPath(contextRef2,path2.CGPath);
    CGContextSetStrokeColorWithColor(contextRef2, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(contextRef2, 3);
    CGContextStrokePath(contextRef2);
    
}

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpSubViews];
        
    }
    return self;
}

-(void)setUpSubViews {
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _label.textColor = [UIColor whiteColor];
    _label.font = [UIFont systemFontOfSize:13];
    _label.textAlignment = 1;
    _label.layer.zPosition = 3;
    _label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

-(void)upDateCircleProgress:(CGFloat) progress {
    self.label.text = [NSString stringWithFormat:@"%.0f",self.signProgress - progress + 1];
    self.progress = progress;
    [self setNeedsDisplay];
}



@end

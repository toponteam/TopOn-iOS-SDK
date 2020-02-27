//
//  MTAutolayoutCategories.m
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 24/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import "MTAutolayoutCategories.h"

@implementation UIView(Autolayout)
+(instancetype) autolayoutView {
    UIView *view = [[self alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

- (NSArray<__kindof NSLayoutConstraint *> *)addConstraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *, id> *)views {
    NSArray<__kindof NSLayoutConstraint*>* constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:opts metrics:metrics views:views];
    [self addConstraints:constraints];
    return constraints;
}

-(NSLayoutConstraint*)addConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c {
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view1 attribute:attr1 relatedBy:relation toItem:view2 attribute:attr2 multiplier:multiplier constant:c];
    [self addConstraint:constraint];
    return constraint;
}
@end

@implementation UILabel(Autolayout)
+(instancetype) autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment)textAlignment {
    UILabel *label = [UILabel autolayoutView];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    return label;
}

+(instancetype) autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor {
    return [self autolayoutLabelFont:font textColor:textColor textAlignment:NSTextAlignmentLeft];
}
@end

@implementation UIButton(Autolayout)
+(instancetype) autolayoutButtonWithType:(UIButtonType)type {
    UIButton *button = [UIButton buttonWithType:type];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    return button;
}
@end

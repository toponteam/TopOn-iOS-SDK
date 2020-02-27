//
//  MTAutolayoutCategories.h
//  AnyThinkSDKDemo
//
//  Created by Martin Lau on 24/04/2018.
//  Copyright © 2018 Martin Lau. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView(Autolayout)
+(instancetype) autolayoutView;
- (NSArray<__kindof NSLayoutConstraint *> *)addConstraintsWithVisualFormat:(NSString *)format options:(NSLayoutFormatOptions)opts metrics:(NSDictionary<NSString *,id> *)metrics views:(NSDictionary<NSString *, id> *)views;
-(NSLayoutConstraint*)addConstraintWithItem:(id)view1 attribute:(NSLayoutAttribute)attr1 relatedBy:(NSLayoutRelation)relation toItem:(id)view2 attribute:(NSLayoutAttribute)attr2 multiplier:(CGFloat)multiplier constant:(CGFloat)c;
@end

@interface UILabel(Autolayout)
+(instancetype) autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor textAlignment:(NSTextAlignment)textAlignment;
/**
 * textAlignment defaults to NSTextAlignmentLeft
 */
+(instancetype) autolayoutLabelFont:(UIFont*)font textColor:(UIColor*)textColor;
@end

@interface UIButton(Autolayout)
+(instancetype) autolayoutButtonWithType:(UIButtonType)type;
@end

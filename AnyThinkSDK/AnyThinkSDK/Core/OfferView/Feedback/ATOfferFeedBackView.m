//
//  ATOfferFeedBackView.m
//  AnyThinkSDK
//
//  Created by Jason on 2021/1/11.
//  Copyright © 2021 AnyThink. All rights reserved.
//

#import "ATOfferFeedBackView.h"
#import "Utilities.h"
#import "UIColor+KAKit.h"

#define FeedBackTextBlue [UIColor colorWithRed:34/255.0 green:101/255.0 blue:1 alpha:1.0]
#define FeedBackTextBlack [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]
#define FeedBackBgGray [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1.0]

@interface ATOfferFeedBackView ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *suggestionTip;
@property (weak, nonatomic) IBOutlet UILabel *reportTip;
@property (weak, nonatomic) IBOutlet UILabel *abnormalTip;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewConstrait;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrait;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *closeImgView;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property(nonatomic, strong) NSMutableArray<UIButton *> *btns;
@property(nonatomic) NSString *placeholder;
@end

@implementation ATOfferFeedBackView



- (NSString *)localizedStringWithTag:(NSInteger)tag {
    BOOL mandarin = [Utilities isMandarin];
    switch (tag) {
        case 1:
            return mandarin ? @"广告卡顿" : @"Video Freeze";
        case 2:
            return mandarin ? @"黑白屏" : @"Show Failed";
        case 3:
            return mandarin ? @"无法关闭" : @"Can't Colse";
        case 4:
            return mandarin ? @"诱导点击" : @"Induce Click";
        case 5:
            return mandarin ? @"违法违规" : @"Illegal";
        case 6:
            return mandarin ? @"虚假欺诈" : @"Fraud Ads";
        case 7:
            return mandarin ? @"内容抄袭" : @"Plagiarism";
        case 8:
            return mandarin ? @"内容低俗" : @"Vulgar porn";
        case 9:
            return mandarin ? @"不感兴趣" : @"Boring";
        default:
            break;
    }
    return nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.textView.delegate = self;
    self.btns = [NSMutableArray arrayWithCapacity:9];
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[UIButton class]] &&
            subview.tag) {
            UIButton *btn = (UIButton *)subview;
            [self.btns addObject:btn];
            [btn setTitle:[self localizedStringWithTag:subview.tag] forState:UIControlStateNormal];
            [btn setTitle:[self localizedStringWithTag:subview.tag] forState:UIControlStateSelected];
            btn.titleLabel.text = [self localizedStringWithTag:subview.tag];
            
        }
    }
    BOOL mandarin = [Utilities isMandarin];
    self.closeImgView.image = [UIImage anythink_imageWithName:@"feedback_close"];
    self.placeholder = mandarin ? @"请先输入建议内容！建议内容为100个字以内" : @"Please enter the suggestion first! Suggestion is within 100 words";
    [self.submitBtn setTitle:mandarin ? @"提交":@"Submit" forState:UIControlStateNormal];
    self.abnormalTip.text = mandarin ? @"异常广告" : @"Abnormal";
    self.reportTip.text = mandarin ? @"举报广告" : @"Report";
    self.suggestionTip.text = mandarin ? @"其他建议" : @"Suggestion";

    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
        self.topConstrait.constant = 32;
        self.textViewConstrait.constant = 64;
    }
    
}

// MARK:- actions
- (IBAction)submit:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(feedbackView:didSelectItemAtIndex:extraMsg:)]) {
        [self.delegate feedbackView:self didSelectItemAtIndex:0 extraMsg:self.textView.text];
    }
    
    [self dismiss];
}

- (IBAction)itemClick:(UIButton *)sender {
    
    for (UIButton *btn in self.btns) {
        btn.selected = btn == sender;
        [btn setBackgroundColor: btn.isSelected ? FeedBackTextBlue : FeedBackBgGray];
        if (btn.isSelected) {
            self.submitBtn.titleLabel.textColor = [UIColor whiteColor];
            [self.submitBtn setBackgroundColor:FeedBackTextBlue];
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(feedbackView:didSelectItemAtIndex:extraMsg:)]) {
        [self.delegate feedbackView:self didSelectItemAtIndex:sender.tag extraMsg:self.textView.text];
    }
    
    [self dismiss];
//    if (self.submitBtn.isEnabled == NO) {
//        self.submitBtn.enabled = YES;
//    }
}

// MARK:- methods
- (void)showTips {
    
}

// MARK:- methods claimed in .h
+ (instancetype)create {
//    return [[NSBundle mainBundle] loadNibNamed:@"ATOfferFeedBackView" owner:nil options:nil].firstObject;

    NSString *path = [[NSBundle mainBundle] pathForResource:@"AnyThinkSDK" ofType:@"bundle"];
    return [[NSBundle bundleWithPath:path] loadNibNamed:@"ATOfferFeedBackView" owner:nil options:nil].firstObject;
}

- (void)dismiss {
    
    [self endEditing:YES];
    [UIView animateWithDuration:0.3f animations:^{
        
        self.superview.alpha = 0;
    }completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            [self.superview removeFromSuperview];
        }
    } ];
    if ([self.delegate respondsToSelector:@selector(feedbackViewWillDismiss:)]) {
        [self.delegate feedbackViewWillDismiss:self];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self endEditing:YES];
}

- (IBAction)closeAct:(UITapGestureRecognizer *)sender {
    [self dismiss];
}

- (void)showInView:(UIView *)kSuperView {
    
    if (kSuperView == nil) {
        return;
    }
//    CGFloat offset_x = (CGRectGetWidth(kSuperView.frame) - CGRectGetWidth(self.frame))/2;
//    self.frame = CGRectMake(offset_x, offset_y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    if ([UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIDeviceOrientationLandscapeRight) {
        CGSize size = [self systemLayoutSizeFittingSize:CGSizeMake(self.frame.size.width, 999)];
        CGRect frame = self.frame;
        frame.size.height = size.height;
        self.frame = frame;
    }
    UIView *bgView = [[UIView alloc]initWithFrame:kSuperView.frame];
    bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [kSuperView addSubview:bgView];
    self.center = bgView.center;
    [bgView addSubview:self];
}

// MARK:- textview delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:self.placeholder]) {
        textView.textColor = [UIColor colorWithHexString:@"333333"];
        textView.text = @"";
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    self.submitBtn.enabled = textView.text.length != 0;

    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    if (textView.text.length == 0) {
        textView.textColor = [UIColor colorWithHexString:@"999999"];
        textView.text = self.placeholder;
        self.submitBtn.backgroundColor = [[UIColor colorWithHexString:@"2265FF"]colorWithAlphaComponent:0.6];
        [self.submitBtn setTitleColor:[[UIColor whiteColor]colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
        self.submitBtn.enabled = NO;
    }else if ([textView.text isEqualToString:self.placeholder] == NO) {
        textView.textColor = [UIColor colorWithHexString:@"333333"];
        self.submitBtn.backgroundColor = [UIColor colorWithHexString:@"2265FF"];
        [self.submitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.submitBtn.enabled = YES;
    }
    return YES;
}

@end

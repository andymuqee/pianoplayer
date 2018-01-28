//
//  GuideView1.m
//  pinaoplayer
//
//  Created by andy on 2018/1/15.
//  Copyright © 2018年 boyun. All rights reserved.
//

#import "GuideView1.h"

@implementation GuideView1


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.label.text = @"fff";
    [self.label setBounds:CGRectMake(10, 10, 100, 20)];
    [self addSubview:self.label];
}


@end

//
//  ScanView.m
//  CodeScan
//
//  Created by tian on 16/7/22.
//  Copyright © 2016年 windtersharp. All rights reserved.
//

#import "ScanView.h"

@interface ScanView ()

@property (nonatomic,strong) CAGradientLayer *colorLayer;

@end

@implementation ScanView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self creatScanner];
    }
    return self;
}

#pragma mark - UI
- (void)creatScanner{
  [self.layer addSublayer:self.colorLayer];
  [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(loopScan:) userInfo:nil repeats:YES];

}

- (void)loopScan:(NSTimer *)timer{
    static  CGFloat locationChange = 0;
    [CATransaction begin];
   [CATransaction setDisableActions:YES];
    if (locationChange <= 1.3) {
        self.colorLayer.locations = @[@( -0.3 + locationChange),@(0.0 + locationChange),@(0.0 + locationChange)];
        locationChange += 0.05;
    } else {

        locationChange = 0.0;
    }
    [CATransaction commit];

}


#pragma mark - DrawRect
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    //获取绘图上下文（画布）
    CGContextRef context = UIGraphicsGetCurrentContext();
    //背景
    CGContextSetRGBFillColor(context, 40/ 255.0, 40 / 255.0, 40 / 255.0, 0.2);
    CGContextFillRect(context, rect);
    //扫描框
    CGRect scanRect = CGRectMake(CGRectGetMidX(self.bounds) - 120, CGRectGetMidY(self.bounds) - 120, 240, 240);
    CGContextClearRect(context, scanRect); //去除背景
    CGContextStrokeRect(context, scanRect); //绘制矩形
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 1); //RGB颜色
    CGContextSetLineWidth(context, 1.0); //线宽
    CGContextAddRect(context, scanRect);//添加画布上
    CGContextStrokePath(context); //开始绘制
    //四个边角（优先处理y方向）
    CGContextSetRGBStrokeColor(context, 83 /255.0, 239/255.0, 111/255.0, 1);
    //左上角
    CGPoint pointLeftTopA[] = {CGPointMake(CGRectGetMinX(scanRect), CGRectGetMinY(scanRect)),
                               CGPointMake(CGRectGetMinX(scanRect), CGRectGetMinY(scanRect) + 15)
                              };
    CGPoint pointLeftTopB[] = {CGPointMake(CGRectGetMinX(scanRect), CGRectGetMinY(scanRect)),
                               CGPointMake(CGRectGetMinX(scanRect) + 15, CGRectGetMinY(scanRect))
                              };
    CGContextAddLines(context, pointLeftTopA, 2);
    CGContextAddLines(context, pointLeftTopB, 2);
    //左下角
    CGPoint pointLeftBottomA[] = {CGPointMake(CGRectGetMinX(scanRect), CGRectGetMaxY(scanRect)),
                                  CGPointMake(CGRectGetMinX(scanRect), CGRectGetMaxY(scanRect) -15)
                                };
    CGPoint pointLeftBottomB[] = {CGPointMake(CGRectGetMinX(scanRect), CGRectGetMaxY(scanRect)),
                                 CGPointMake(CGRectGetMinX(scanRect) + 15, CGRectGetMaxY(scanRect))
                                 };
    CGContextAddLines(context, pointLeftBottomA, 2);
    CGContextAddLines(context, pointLeftBottomB, 2);
    //右上角
    CGPoint pointRightTopA[] = {CGPointMake(CGRectGetMaxX(scanRect), CGRectGetMinY(scanRect)),
                                CGPointMake(CGRectGetMaxX(scanRect), CGRectGetMinY(scanRect) + 15)
                                };
    CGPoint pointRightTopB[] = {CGPointMake(CGRectGetMaxX(scanRect), CGRectGetMinY(scanRect)),
                                CGPointMake(CGRectGetMaxX(scanRect) - 15, CGRectGetMinY(scanRect))
                                };
    CGContextAddLines(context, pointRightTopA, 2);
    CGContextAddLines(context, pointRightTopB, 2);
    //右下角
    CGPoint pointRightBottomA[] = {CGPointMake(CGRectGetMaxX(scanRect), CGRectGetMaxY(scanRect)),
                                    CGPointMake(CGRectGetMaxX(scanRect), CGRectGetMaxY(scanRect) -15)
                                  };
    CGPoint pointRightBottomB[] = {CGPointMake(CGRectGetMaxX(scanRect), CGRectGetMaxY(scanRect)),
                                    CGPointMake(CGRectGetMaxX(scanRect) - 15, CGRectGetMaxY(scanRect))
                                  };

    CGContextAddLines(context, pointRightBottomA, 2);
    CGContextAddLines(context, pointRightBottomB, 2);
    CGContextStrokePath(context);
    //文字说明
    NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:14], NSFontAttributeName,
                                                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    
    [@"将二维码/条码放入框内,即可自动扫描" drawAtPoint:CGPointMake(CGRectGetMinX(scanRect) + 5, CGRectGetMaxY(scanRect) + 10)
                                   withAttributes:attrs];
    
    
}

#pragma mark - Getter
- (CAGradientLayer *)colorLayer{
    if (_colorLayer == nil) {
        _colorLayer = [CAGradientLayer layer];
        CGRect scanRect = CGRectMake(CGRectGetMidX(self.bounds) - 120, CGRectGetMidY(self.bounds) - 120, 240, 240);
        _colorLayer.frame = scanRect;
        _colorLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                               (__bridge id)[UIColor whiteColor].CGColor,
                              (__bridge id)[UIColor clearColor].CGColor
                              ];
        _colorLayer.locations  = @[@(0.0),@(0.0),@(0.0)];
        _colorLayer.startPoint = CGPointMake(0, 0);
        _colorLayer.endPoint   = CGPointMake(0, 1);

    }
    return _colorLayer;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

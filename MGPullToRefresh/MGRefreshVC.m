//
//  ViewController.m
//  MGPullToRefresh
//
//  Created by mango on 2017/5/24.
//  Copyright © 2017年 mango. All rights reserved.
//

#import "MGRefreshVC.h"
#import "UIViewExt.h"
#import "MGCell.h"

@interface MGRefreshVC ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)CAShapeLayer *shapeLayer;
@property(nonatomic, weak)UITableView *tableView;
@property(nonatomic, strong)CAShapeLayer *circleLayer;
@end

@implementation MGRefreshVC

static NSString * const kCellID = @"kCellID";

#pragma mark - accessor
-(CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:169/255.0 alpha:1].CGColor;
    }
    return _shapeLayer;
}

-(CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _circleLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [tableView setContentInset:UIEdgeInsetsMake(100, 0, 0, 0)];
    [tableView setContentOffset:CGPointMake(0, 0)];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [tableView registerNib:[UINib nibWithNibName:@"MGCell" bundle:nil] forCellReuseIdentifier:kCellID];
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view.layer insertSublayer:self.shapeLayer atIndex:0];
    [self.shapeLayer addSublayer:self.circleLayer];
    [self p_initCircle];
    
    
}

#pragma mark - private method
-(void)p_initCircle {
    self.circleLayer.frame = CGRectMake(0, 0, self.view.width, 100);
    self.circleLayer.fillColor = nil;
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleLayer.lineWidth = 2.0;
    
    CGPoint center = CGPointMake(self.view.center.x, 50);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.view.center.x, 35)];
    [path addArcWithCenter:center radius:15 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    CGFloat r1 = 17.0;
    CGFloat r2 = 22.0;
    for (int i = 0; i < 8 ; i++) {
        CGPoint pointStart = CGPointMake(center.x + sin((M_PI * 2.0 / 8 * i)) * r1, center.y - cos((M_PI * 2.0 / 8 * i)) * r1);
        CGPoint pointEnd = CGPointMake(center.x + sin((M_PI * 2.0 / 8 * i)) * r2, center.y - cos((M_PI * 2.0 / 8 * i)) * r2);
        [path moveToPoint:pointStart];
        [path addLineToPoint:pointEnd];
    }
    
    self.circleLayer.path = path.CGPath;
}

-(void)p_rise {
    self.tableView.scrollEnabled = NO;
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.duration = 0.15;
    anim.toValue = @(M_PI / 4.0);
    anim.repeatCount = MAXFLOAT;
    [self.circleLayer addAnimation:anim forKey:nil];
    
}

-(void)p_stop {
    self.tableView.scrollEnabled = YES;
    [self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
    [self.circleLayer removeAllAnimations];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:kCellID forIndexPath:indexPath];
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = -scrollView.contentOffset.y;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.view.width, 0)];
    if (height <= 100) {
        [path addLineToPoint:CGPointMake(self.view.width, height)];
        [path addLineToPoint:CGPointMake(0, height)];
        self.circleLayer.strokeEnd = height / 100.0;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.affineTransform = CGAffineTransformIdentity;
        [CATransaction commit];
    }else{
        self.circleLayer.strokeEnd = 1.0;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.affineTransform = CGAffineTransformMakeRotation(-(M_PI / 720 * height - 100));
        [CATransaction commit];
        [path addLineToPoint:CGPointMake(self.view.width, 100)];
        [path addQuadCurveToPoint:CGPointMake(0, 100) controlPoint:CGPointMake(self.view.center.x, height)];
    }
    
    [path closePath];
    self.shapeLayer.path = path.CGPath;
    
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -100) {
        [scrollView setContentOffset:CGPointMake(0, -100) animated:YES];
    }else if(scrollView.contentOffset.y < 0) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == -100) {
        self.circleLayer.affineTransform = CGAffineTransformIdentity;
        [self p_rise];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self p_stop];
        });
    }
}
@end


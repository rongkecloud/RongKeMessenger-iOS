//
//  DownloadIndicator.h
//  RongKeMessenger
//
//  Created by 陈朝阳 on 16/2/24.
//  Copyright © 2016年 西安融科通信技术有限公司. All rights reserved.
//

#import "DownloadIndicator.h"

@interface DownloadIndicator()

// this contains list of paths to be animated through
@property(nonatomic, strong) NSMutableArray *pathsMutableArray;
// the shaper layers used for display
@property(nonatomic, strong) CAShapeLayer *indicateShapeLayer;
@property(nonatomic, strong) CAShapeLayer *coverLayer;
// this is the layer used for animation
@property(nonatomic, strong) CAShapeLayer *animatingLayer;
// the last updatedPath
@property(nonatomic, strong) UIBezierPath *lastUpdatedPath;

// the type of indicator
@property(nonatomic, assign) RMIndicatorType type;
// this applies to the covering stroke (default: 2)
@property(nonatomic, assign) CGFloat lastSourceAngle;
// this the animation duration (default: 0.5)
@property(nonatomic, assign) CGFloat animationDuration;

@end

@implementation DownloadIndicator

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = kRMFilledIndicator;
        [self initAttributes];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame type:(RMIndicatorType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.type = type;
        [self initAttributes];
    }
    return self;
}
// 初始化下载的view
- (void)initDownloadViewWithType:(int)indicatorType
{
    self.type = indicatorType;
    [self initAttributes];
}

- (void)initAttributes
{
    // first set the radius percent attribute
    if(self.type == kRMClosedIndicator)
    {
        self.radiusPercent = 0.5;
        self.coverLayer = [CAShapeLayer layer];
        self.animatingLayer = self.coverLayer;
        self.isStickShop = NO;

        // set the fill color
        self.fillColor = [UIColor clearColor];
        self.strokeColor = [UIColor whiteColor];
        //self.closedIndicatorBackgroundStrokeColor = [UIColor colorWithRed:57/255.0 green:177/255.0 blue:0 alpha:1];
        //self.coverWidth = 2.0;
        
        //[self addDisplayLabel];
    }
    else
    {
        if(self.type == kRMFilledIndicator)
        {
            // only indicateShapeLayer
            self.indicateShapeLayer = [CAShapeLayer layer];
            self.animatingLayer = self.indicateShapeLayer;
            self.radiusPercent = 0.5;
           // self.coverWidth = 2.0;
        }
        else
        {
            // indicateShapeLayer and coverLayer
            self.indicateShapeLayer = [CAShapeLayer layer];
            self.coverLayer = [CAShapeLayer layer];
            self.animatingLayer = self.indicateShapeLayer;
            //self.coverWidth = 2.0;
            self.radiusPercent = 0.4;
        }
        
        // set the fill color
        self.fillColor = [UIColor whiteColor];
        self.strokeColor = [UIColor whiteColor];
        self.closedIndicatorBackgroundStrokeColor = [UIColor clearColor];
    }
    
    self.animatingLayer.frame = self.bounds;
    [self.layer addSublayer:self.animatingLayer];
    
    // path array
    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    self.pathsMutableArray = mutableArray;
    
    // animation duration
    self.animationDuration = 0.5;
}

- (void)loadIndicator
{
    // set the initial Path
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    UIBezierPath *initialPath = [UIBezierPath bezierPath]; //empty path
    
    if(self.type == kRMClosedIndicator)
    {
        [initialPath addArcWithCenter:center radius:(MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))) startAngle:degreeToRadian(-90) endAngle:degreeToRadian(-90) clockwise:YES]; //add the arc
    }
    else
    {
        if(self.type == kRMMixedIndictor)
        {
            [self setNeedsDisplay];
        }
        CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2) * self.radiusPercent;
        [initialPath addArcWithCenter:center radius:radius startAngle:degreeToRadian(-90) endAngle:degreeToRadian(-90) clockwise:YES]; //add the arc
    }
    
    self.animatingLayer.path = initialPath.CGPath;
    self.animatingLayer.strokeColor = self.strokeColor.CGColor;
    self.animatingLayer.fillColor = self.fillColor.CGColor;
    self.animatingLayer.lineWidth = self.coverWidth;
    self.lastSourceAngle = degreeToRadian(-90);
}

#pragma mark -
#pragma mark Helper Methods
- (NSArray *)keyframePathsWithDuration:(CGFloat) duration sourceStartAngle:(CGFloat)sourceStartAngle sourceEndAngle:(CGFloat)sourceEndAngle destinationStartAngle:(CGFloat)destinationStartAngle destinationEndAngle:(CGFloat)destinationEndAngle centerPoint:(CGPoint)centerPoint size:(CGSize)size sourceRadiusPercent:(CGFloat)sourceRadiusPercent destinationRadiusPercent:(CGFloat)destinationRadiusPercent type:(RMIndicatorType)type
{
    NSUInteger frameCount = ceil(duration * 60);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:frameCount + 1];
    for (int frame = 0; frame <= frameCount; frame++)
    {
        CGFloat startAngle = sourceStartAngle + (((destinationStartAngle - sourceStartAngle) * frame) / frameCount);
        CGFloat endAngle = sourceEndAngle + (((destinationEndAngle - sourceEndAngle) * frame) / frameCount);
        CGFloat radiusPercent = sourceRadiusPercent + (((destinationRadiusPercent - sourceRadiusPercent) * frame) / frameCount);
        CGFloat radius = (MIN(size.width, size.height) * radiusPercent) - self.coverWidth;
        
        [array addObject:(id)([self slicePathWithStartAngle:startAngle endAngle:endAngle centerPoint:centerPoint radius:radius type:type].CGPath)];
    }
    
    return [NSArray arrayWithArray:array];
}

- (UIBezierPath *)slicePathWithStartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle centerPoint:(CGPoint)centerPoint radius:(CGFloat)radius type:(RMIndicatorType)type
{
    BOOL clockwise = startAngle < endAngle;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if(type == kRMClosedIndicator)
    {
        [path addArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
    }
    else
    {
        [path moveToPoint:centerPoint];
        [path addArcWithCenter:centerPoint radius:radius startAngle:startAngle endAngle:endAngle clockwise:clockwise];
        [path closePath];
    }
    return path;
}

- (void)drawRect:(CGRect)rect
{
    if(self.type == kRMMixedIndictor)
    {
        CGFloat radius = (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))/2) - self.coverWidth;
        
        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        UIBezierPath *coverPath = [UIBezierPath bezierPath]; //empty path
        [coverPath setLineWidth:self.coverWidth];
        [coverPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]; //add the arc
        [self.strokeColor set];
        [coverPath stroke];
    }
    else if (self.type == kRMClosedIndicator)
    {
        CGFloat radius = 0;
        if (self.isStickShop)
            radius = (self.bounds.size.width / 2) + 1  - self.coverWidth;
        else
            radius = (self.bounds.size.width / 2)  - self.coverWidth;

        CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
        UIBezierPath *coverPath = [UIBezierPath bezierPath]; //empty path
        [coverPath setLineWidth:self.coverWidth];
        [coverPath addArcWithCenter:center radius:radius startAngle:0 endAngle:2*M_PI clockwise:YES]; //add the arc
        [self.closedIndicatorBackgroundStrokeColor set];
        [coverPath setLineWidth:self.radiusWidth];
        [coverPath stroke];
    }
}

#pragma mark - update indicator
- (void)updateWithTotalBytes:(CGFloat)bytes downloadedBytes:(CGFloat)downloadedBytes
{
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    self.lastUpdatedPath = [UIBezierPath bezierPathWithCGPath:self.animatingLayer.path];
    
    [self.pathsMutableArray removeAllObjects];
    
    CGFloat destinationAngle = [self destinationAngleForRatio:(downloadedBytes/bytes)];
    [self.pathsMutableArray addObjectsFromArray:[self keyframePathsWithDuration:self.animationDuration sourceStartAngle:degreeToRadian(-90) sourceEndAngle:self.lastSourceAngle destinationStartAngle:degreeToRadian(-90) destinationEndAngle:destinationAngle centerPoint:center size:CGSizeMake(self.bounds.size.width, self.bounds.size.width) sourceRadiusPercent:self.radiusPercent destinationRadiusPercent:self.radiusPercent type:self.type]];
    
    self.animatingLayer.path = (__bridge CGPathRef)((id)self.pathsMutableArray[(self.pathsMutableArray.count -1)]);
    self.lastSourceAngle = destinationAngle;
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    [pathAnimation setValues:self.pathsMutableArray];
    [pathAnimation setDuration:self.animationDuration];
    [pathAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [pathAnimation setRemovedOnCompletion:YES];
    [self.animatingLayer addAnimation:pathAnimation forKey:@"path"];
    
    //[self.displayLabel updateValue:downloadedBytes/bytes];
}

- (CGFloat)destinationAngleForRatio:(CGFloat)ratio
{
    return (degreeToRadian((360*ratio) - 90));
}

float degreeToRadian(float degree)
{
    return ((degree * M_PI)/180.0f);
}

#pragma mark -
#pragma mark Setter Methods

- (void)setRadiusPercent:(CGFloat)radiusPercent
{
    if(self.type == kRMClosedIndicator)
    {
        _radiusPercent = 0.5;
        return;
    }
    
    if(radiusPercent > 0.5 || radiusPercent < 0)
        return;
    else
        _radiusPercent = radiusPercent;
        
}

- (void)setIndicatorAnimationDuration:(CGFloat)duration
{
    self.animationDuration = duration;
}

@end

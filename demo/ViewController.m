//
//  ViewController.m
//  demo
//
//  Created by admin on 2020/8/6.
//  Copyright © 2020 admin. All rights reserved.
//

#import "ViewController.h"
#import "BlockModel.h"




#define BLOCK_WIDTH 50
@interface ViewController ()

@end

@implementation ViewController
{
    NSMutableArray * mBlockArray;
//    NSMutableArray * mPointArray;
    NSMutableArray * mSelectBlockArray;
    NSMutableArray * mdataArray;
    UIView * mView;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    mBlockArray = [NSMutableArray new];
    mSelectBlockArray = [NSMutableArray new];
    mdataArray = [NSMutableArray new];
    
    mdataArray = [self createData];
    
    

//    [self createUI];
    
    UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(300, 100, 30,30)];
    button.backgroundColor = [UIColor brownColor];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    UIButton * left = [[UIButton alloc]initWithFrame:CGRectMake(self.view.centerX - 15 - 50, kSHeight - 150, 50,30)];
    left.backgroundColor = [UIColor brownColor];
    [left addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:left];
    
    
    UIButton * right = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMaxX(left.frame)+30, left.y, 50,30)];
   right.backgroundColor = [UIColor brownColor];
   [right addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
   [self.view addSubview:right];
    
    UIButton * top = [[UIButton alloc]initWithFrame:CGRectMake(kSWidth - 100, left.y - 50 , 30,50)];
    top.centerX = self.view.centerX;
    top.backgroundColor = [UIColor brownColor];
    [top addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:top];
    
    
    UIButton * bottom = [[UIButton alloc]initWithFrame:CGRectMake(top.x, CGRectGetMaxY(top.frame)+30, 30,50)];
    bottom.backgroundColor = [UIColor brownColor];
    [bottom addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottom];
    
}
- (void)buttonClick
{
    [mSelectBlockArray removeAllObjects];
    [mdataArray removeAllObjects];
    [mBlockArray removeAllObjects];
    mdataArray = [self createData];
    [mView removeFromSuperview];
    [self createUI];
}
- (NSMutableArray *)createData
{
    
    NSMutableArray * array = [NSMutableArray new];
    
    if (1) {
        for (int i=0; i<3; i++) {
           for (int j=0; j<3; j++) {
               
               [array addObject:NSStringFromCGPoint(CGPointMake(100+BLOCK_WIDTH*i, 100+BLOCK_WIDTH*j))];
           }
        }
    }
    else{
        
        [array addObject:NSStringFromCGPoint(CGPointMake(100, 100))];
        [array addObject:NSStringFromCGPoint(CGPointMake(100, 100+BLOCK_WIDTH))];
        [array addObject:NSStringFromCGPoint(CGPointMake(100, 100+BLOCK_WIDTH*2))];
        [array addObject:NSStringFromCGPoint(CGPointMake(100+BLOCK_WIDTH, 100+BLOCK_WIDTH*2))];
        [array addObject:NSStringFromCGPoint(CGPointMake(100+BLOCK_WIDTH*2, 100+BLOCK_WIDTH*2))];
    }
    
    
    return array;
}
- (void)createUI{
    
    mView = [[UIView alloc]initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 300)];
    mView.tag = 100;
    [self.view addSubview:mView];
    
    for (int i=0; i<mdataArray.count; i++) {
               
        BlockModel * block = [self getLayerWithPoint:CGPointFromString(mdataArray[i])];
        [mView.layer addSublayer:block.layer];
        [mBlockArray addObject:block];
               
    }
   
}

- (BlockModel *)getLayerWithPoint:(CGPoint)point
{
    UIBezierPath * path = [UIBezierPath bezierPathWithRect:CGRectMake(point.x,point.y, BLOCK_WIDTH, BLOCK_WIDTH)];
    
    CAShapeLayer * layer = [[CAShapeLayer alloc]init];
    layer.path = path.CGPath;
    layer.strokeColor = [UIColor redColor].CGColor;
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.lineWidth = 1;
    
    BlockModel * block = [BlockModel new];
    block.layer = layer;
    block.point = point;
    
    return block;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:mView];
    
    for (int i=0; i<mBlockArray.count; i++) {

        BlockModel * block = mBlockArray[i];
        CGPoint layerPoint = block.point;

        BlockModel * touchBlock = [BlockModel new];
        touchBlock.point = point;
        
        if ([self judgeInsideBlock:block judgeBlock:touchBlock]) {
            
            CAShapeLayer * layer = block.layer;
            layer.fillColor = [UIColor greenColor].CGColor;
            if (![mSelectBlockArray containsObject:block]) {
                [mSelectBlockArray addObject:block];
            }
        }
    }
 
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint point = [touch locationInView:mView];
   
   for (int i=0; i<mBlockArray.count; i++) {

       BlockModel * block = mBlockArray[i];
       CGPoint layerPoint = block.point;

       BlockModel * touchBlock = [BlockModel new];
       touchBlock.point = point;
       
       
       // 点击位置是否在方块里
       if ([self judgeInsideBlock:block judgeBlock:touchBlock]) {
           
           CAShapeLayer * layer = block.layer;
           
           // 之前已经滑过
           if ([mSelectBlockArray containsObject:block] && [mSelectBlockArray lastObject]!=block) {
              NSInteger count = [mSelectBlockArray indexOfObject:block];
               NSMutableArray * array = mSelectBlockArray.mutableCopy;
               [mSelectBlockArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                   BlockModel * selectBlock = mSelectBlockArray[idx];
                   if (idx>count) {
                       selectBlock.layer.fillColor = [UIColor whiteColor].CGColor;
                       [mSelectBlockArray removeObject:selectBlock];

                   }
                   // 
               }];
           }
           // 是否相邻
           else if (![self judgeContinueBlock:touchBlock] && mSelectBlockArray.count > 0){
               NSLog(@" -- test --");
           }
           else{
               layer.fillColor = [UIColor greenColor].CGColor;
               if (![mSelectBlockArray containsObject:block]) {
                   [mSelectBlockArray addObject:block];
               }
           }
           
       }
   }
}
-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
//    if (mSelectBlockArray.count == mBlockArray.count) {
//        UIAlertView * view = [[UIAlertView alloc]initWithTitle:nil message:@"成功" delegate:nil cancelButtonTitle:@"qued" otherButtonTitles: nil];
//        [view show];
//    }
//    else{
        [mSelectBlockArray removeAllObjects];
        for (BlockModel * model in mBlockArray) {
            model.layer.fillColor = [UIColor whiteColor].CGColor;
            
        }
//    }
    
}
- (BOOL)judgeContinueBlock:(BlockModel *)block
{
    BlockModel * lastModel = [mSelectBlockArray lastObject];
    
    BlockModel * leftBlock = [BlockModel new];
    leftBlock.point = CGPointMake(lastModel.point.x - BLOCK_WIDTH, lastModel.point.y);
    
    BlockModel * topBlock = [BlockModel new];
    topBlock.point = CGPointMake(lastModel.point.x, lastModel.point.y - BLOCK_WIDTH);
    
    BlockModel * rightBlock = [BlockModel new];
    rightBlock.point = CGPointMake(lastModel.point.x + BLOCK_WIDTH, lastModel.point.y);
    
    BlockModel * bottomBlock = [BlockModel new];
    bottomBlock.point = CGPointMake(lastModel.point.x , lastModel.point.y+ BLOCK_WIDTH);
    
    BOOL a = [self judgeInsideBlock:block judgeBlock:leftBlock];
    BOOL b = [self judgeInsideBlock:block judgeBlock:topBlock];
    BOOL c = [self judgeInsideBlock:block judgeBlock:rightBlock];
    BOOL d = [self judgeInsideBlock:block judgeBlock:bottomBlock];

    
    if ([self judgeInsideBlock:leftBlock judgeBlock:block] ||
        [self judgeInsideBlock:topBlock judgeBlock:block] ||
        [self judgeInsideBlock:rightBlock judgeBlock:block] ||
        [self judgeInsideBlock:bottomBlock judgeBlock:block]) {
        return YES;
    }
    
    return NO;
}
- (BOOL)judgeInsideBlock:(BlockModel *)block judgeBlock:(BlockModel*)judgeBlock
{
    if (judgeBlock.point.x>block.point.x &&
        judgeBlock.point.y>block.point.y &&
        judgeBlock.point.x<block.point.x+BLOCK_WIDTH &&
        judgeBlock.point.y<block.point.y+BLOCK_WIDTH) {
        
        return YES;
    }
    
    return NO;
}
@end

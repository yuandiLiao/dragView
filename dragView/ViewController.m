//
//  ViewController.m
//  dragView
//
//  Created by yuandiLiao on 16/8/22.
//  Copyright © 2016年 yuandiLiao. All rights reserved.
//

#import "ViewController.h"
#import "YDCollectionViewCell.h"

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)NSMutableArray *array;
@property (nonatomic,strong)NSMutableArray *numArray;
@property (nonatomic,strong) YDCollectionViewCell *cell ;
@property (nonatomic,strong)UIView *tempMoveCell;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,strong)NSIndexPath *moveIndexPath;
@property (nonatomic,assign)CGPoint lastPoint;

@property (nonatomic,assign)BOOL isBegin;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.collectionView];
    self.isBegin = NO;
    self.array = [[NSMutableArray alloc] init];
    self.numArray = [[NSMutableArray alloc] init];
    
    NSMutableArray *firstSectionArray =[[NSMutableArray alloc] initWithArray:@[@"勇士",@"马刺",@"火箭",@"快船",@"爵士",@"开拓",@"灰熊"]];
    
    NSMutableArray *secondSectionArray =[[NSMutableArray alloc] initWithArray:@[@"骑士",@"凯尔",@"老鹰",@"奇才",@"步行",@"魔术",@"公牛",@"热火"]];

    [self.numArray addObject:firstSectionArray];
    [self.numArray addObject:secondSectionArray];

}
-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.sectionInset = UIEdgeInsetsMake(10,10, 10, 10);
        layout.itemSize = CGSizeMake(70, 70);
        _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        UILongPressGestureRecognizer *pan = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_collectionView addGestureRecognizer:pan];
    
        [_collectionView registerClass:[YDCollectionViewCell class] forCellWithReuseIdentifier:@"YDCollectionViewCell"];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView"];
    }
    return _collectionView;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.numArray.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *array = self.numArray[section];
    return array.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    YDCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YDCollectionViewCell" forIndexPath:indexPath];
    NSArray *array = self.numArray[indexPath.section];
    cell.label.text = array[indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    [cell starAnimation:self.isBegin];
    cell.layer.cornerRadius = 10;
    [cell.layer masksToBounds];
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGSize size = CGSizeMake(self.view.frame.size.width, 60);
    return size;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionReusableView" forIndexPath:indexPath];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 100, 30)];
    //复用的时候移除子视图
    for (UIView *view in [headerView subviews]) {
        [view removeFromSuperview];
    }

    if (indexPath.section == 0) {
        label.text = @"西部";
    }else{
        label.text = @"东部";
    }
    label.textColor = [UIColor whiteColor];
    [headerView addSubview:label];
    return headerView;
}


-(void)pan:(UILongPressGestureRecognizer *)pan
{
    //判断手势状态
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{

            self.isBegin = YES;
            [self.collectionView reloadData];
            [self.collectionView performBatchUpdates:^{
                
            } completion:^(BOOL finished) {
                //判断手势落点位置是否在路径上
                self.indexPath = [self.collectionView indexPathForItemAtPoint:[pan locationOfTouch:0 inView:pan.view]];
                //得到该路径上的cell
                self.cell = (YDCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.indexPath];
                //截图cell，得到一个view
                self.tempMoveCell = [self.cell snapshotViewAfterScreenUpdates:NO];
                self.tempMoveCell.frame = self.cell.frame;
                
                 [self.collectionView addSubview:self.tempMoveCell];
                self.cell.hidden = YES;
                //记录当前手指位置
                _lastPoint = [pan locationOfTouch:0 inView:pan.view];
                }];
            }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //偏移量
            CGFloat tranX = [pan locationOfTouch:0 inView:pan.view].x - _lastPoint.x;
            CGFloat tranY = [pan locationOfTouch:0 inView:pan.view].y - _lastPoint.y;
            
            //更新cell位置
            _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
             //记录当前手指位置
            _lastPoint = [pan locationOfTouch:0 inView:pan.view];
            
            for (UICollectionViewCell *cell in [self.collectionView visibleCells]) {
                //剔除隐藏的cell
                if ([self.collectionView indexPathForCell:cell] == self.indexPath) {
                    continue;
                }
                //计算中心，如果相交一半就移动
                CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
                CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
                if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f){
                    self.moveIndexPath = [self.collectionView indexPathForCell:cell];
                    //更新数据源（移动前必须更新数据源）
                    [self updateDataSource];
                    //移动cell
                    [self.collectionView moveItemAtIndexPath:self.indexPath toIndexPath:self.moveIndexPath];
                   //设置移动后的起始indexPath
                    self.indexPath = self.moveIndexPath;
                    break;
                }
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [self.collectionView performBatchUpdates:^{
                
            } completion:^(BOOL finished) {
                self.cell  = (YDCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.indexPath];
                [UIView animateWithDuration:0.1 animations:^{
                    _tempMoveCell.center = self.cell.center;
                } completion:^(BOOL finished) {
                    [_tempMoveCell removeFromSuperview];
                    self.cell.hidden = NO;
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.isBegin = NO;
                        [self.collectionView reloadData];
                    });
                }];

            }];
        }
            break;
        default:
            break;
    }
}
-(void)updateDataSource
{
    //取出源item数据
    id objc =  [[self.numArray objectAtIndex:self.indexPath.section] objectAtIndex:self.indexPath.row];
    //从资源数组中移除该数据,不能直接删除某个数据，因为有可能有相同的数据，一下子删除了多个数据源，造成clash
    //    [[self.numArray objectAtIndex:self.indexPath.section] removeObject:objc];
    
    //删除指定位置的数据，这样就只删除一个，不会重复删除
    
    [[self.numArray objectAtIndex:self.indexPath.section] removeObjectAtIndex:self.indexPath.row];
    //将数据插入到资源数组中的目标位置上
    [[self.numArray objectAtIndex:self.moveIndexPath.section] insertObject:objc atIndex:self.moveIndexPath.row];
}

#pragma iOS9后

//-(void)pan:(UILongPressGestureRecognizer *)pan
//{
//    //判断手势状态
//    switch (pan.state) {
//        case UIGestureRecognizerStateBegan:{
//            //判断手势落点位置是否在路径上
//            self.indexPath = [self.collectionView indexPathForItemAtPoint:[pan locationOfTouch:0 inView:pan.view]];
//            //开始移动cell
//            [self.collectionView beginInteractiveMovementForItemAtIndexPath:self.indexPath];
//        }
//            break;
//        case UIGestureRecognizerStateChanged:
//        {
//            //更新cell的位置
//            [self.collectionView updateInteractiveMovementTargetPosition:[pan locationInView:self.collectionView]];
//            
//        }
//            break;
//        case UIGestureRecognizerStateEnded:
//        {
//            //结束
//            [self.collectionView endInteractiveMovement];
//            
//        }
//            
//            break;
//        default:
//            //取消
//            [self.collectionView cancelInteractiveMovement];
//            break;
//    }
//}

//-(BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}
//- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath NS_AVAILABLE_IOS(9_0)
//{
//    //取出源item数据
//    id objc =  [[self.numArray objectAtIndex:sourceIndexPath.section] objectAtIndex:sourceIndexPath.row];
//       //删除指定位置的数据，这样就只删除一个，不会重复删除
//    
//    [[self.numArray objectAtIndex:sourceIndexPath.section] removeObjectAtIndex:sourceIndexPath.row];
//    //    //将数据插入到资源数组中的目标位置上
//    [[self.numArray objectAtIndex:destinationIndexPath.section] insertObject:objc atIndex:destinationIndexPath.row];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

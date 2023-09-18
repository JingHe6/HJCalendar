//
//  ViewController.m
//  HJCalendar
//
//  Created by 何静 on 2023/9/17.
//

#import "HJCalendar.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
@interface HJCalendar ()
@property (nonatomic,strong) UIView *subView;
@property (nonatomic,strong) NSArray *weeks;//周一～周日
@property (nonatomic,strong) NSArray *days;//每月的天数
@property (nonatomic,strong) UILabel *dateLabel;//显示日期
@property (nonatomic,strong) NSCalendar *calendar;
@property (nonatomic,strong) NSDateComponents *components;//表示今天的要素
@property (nonatomic,strong) NSDateComponents *selComponents;//表示选中要素
@property (nonatomic,strong) UIButton *selectedDayBtn;//选中的某天

@end

@implementation HJCalendar

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addsubViews];
    
    self.calendar = [NSCalendar currentCalendar];
//    self.calendar.firstWeekday = 5;
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    self.components = [self.calendar components:unit fromDate:[NSDate date]];
    self.selComponents = [self.calendar components:unit fromDate:[NSDate date]];
    [self updateCalendar];
        // Do any additional setup after loading the view.
}
#pragma mark - 初始化控件
- (void)addsubViews {
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 150, 30)];
    [leftBtn setTitle:@"上一月" forState:UIControlStateNormal];
    [leftBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(upMonth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftBtn];
    
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-150, 20, 150, 30)];
    [rightBtn setTitle:@"下一月" forState:UIControlStateNormal];
    [rightBtn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(nextMonth) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 30)];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.dateLabel = label;
    
    CGFloat label_w = SCREEN_WIDTH/7;
    for (int i=0; i<self.weeks.count; i++) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(label_w*i, 70, label_w, 30)];
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
        label.text = self.weeks[i];
    }
    
    self.subView = [[UIView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 30*6)];
    [self.view addSubview:self.subView];
}
#pragma mark - 上一个月
- (void)upMonth {
    if (self.selComponents.month == 1) {
        self.selComponents.month = 12;
        self.selComponents.year--;
    } else {
        self.selComponents.month--;
    }
    [self updateCalendar];
}
#pragma mark - 下一个月
- (void)nextMonth {
    if (self.selComponents.month == 12) {
        self.selComponents.month = 1;
        self.selComponents.year++;
    } else {
        self.selComponents.month++;
    }
    [self updateCalendar];
}
#pragma mark - 更新日历
- (void)updateCalendar {
    self.dateLabel.text = [NSString stringWithFormat:@"%ld-%02ld",self.selComponents.year,self.selComponents.month];
    //获取当月1号是周几，用来计算1号的显示位置
    NSDate *date = [self.calendar dateFromComponents:self.selComponents];
    date = [NSDate dateWithTimeInterval:8*60*60 sinceDate:date];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSDateComponents *selComponents = [self.calendar components:unit fromDate:date];
    selComponents.day = 1;
    NSDate *date2 = [self.calendar dateFromComponents:selComponents];
    NSDateComponents *selComponents2 = [self.calendar components:unit fromDate:date2];
    NSInteger week = selComponents2.weekday;//某月1号是周几周，日1 周一2 周六7
    //获取当月有多少天
    NSInteger days = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
    for (UILabel *label in self.subView.subviews) {
        [label removeFromSuperview];
    }
    //上个月的最后一天，即selComponents的前一天
    NSDate *yesterday = [NSDate dateWithTimeInterval:-16*60*60 sinceDate:[self.calendar dateFromComponents:selComponents2]];
    NSDateComponents *components = [self.calendar components:unit fromDate:yesterday];
    NSInteger lastDay = components.day;//上个月最后一天
    lastDay = lastDay-week+2;//第一个btn显示的天
    //下个月第一天
    NSInteger firstDay = 1;
    
    CGFloat btn_w = SCREEN_WIDTH/7;
    for (int i=0; i<42; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(btn_w*(i%7), 30*(i/7), btn_w, 30)];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.tag = i;
        [btn addTarget:self action:@selector(selectDay:) forControlEvents:UIControlEventTouchUpInside];
        [self.subView addSubview:btn];
        
        if (i<week-1) {//上个月月底的几天
            btn.userInteractionEnabled = NO;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn setTitle:[NSString stringWithFormat:@"%ld",lastDay++] forState:UIControlStateNormal];
        } else if (i >= days+week-1) {//下个月月初的几天
            btn.userInteractionEnabled = NO;
            [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [btn setTitle:[NSString stringWithFormat:@"%ld",firstDay++] forState:UIControlStateNormal];
        } else {//本月日期
            btn.userInteractionEnabled = YES;
            if (self.components.year == self.selComponents.year && self.components.month == self.selComponents.month && self.components.day == i+2-week) {
                //今天
                btn.selected = YES;
                [self selectDayState:self.selectedDayBtn];
                [self selectDayState:btn];
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            }  else {
                btn.selected = NO;
                [self selectDayState:btn];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            }
            [btn setTitle:[NSString stringWithFormat:@"%ld",i+2-week] forState:UIControlStateNormal];
        }
    }
}
#pragma mark - 点击某一天事件
- (void)selectDay:(UIButton *)sender {
    if (self.selectedDayBtn) {
        if (self.components.year == self.selComponents.year &&
            self.components.month == self.selComponents.month &&
            self.selectedDayBtn.currentTitle.intValue == self.components.day) {
            //是今天
            self.selectedDayBtn.selected = YES;
        } else {
            self.selectedDayBtn.selected = NO;
        }
        [self selectDayState:self.selectedDayBtn];
    }
    
    self.selComponents.day = sender.currentTitle.integerValue;
    if (self.components.year == self.selComponents.year &&
        self.components.month == self.selComponents.month &&
        self.components.day == self.selComponents.day) {
        //是今天
        sender.selected = YES;
    } else {
        sender.selected = !sender.selected;
    }
    [self selectDayState:sender];
    
    self.selectedDayBtn = sender;
}
#pragma mark - 是否选中状态
- (void)selectDayState:(UIButton *)sender {
    if (sender.isSelected) {
        sender.layer.cornerRadius = sender.frame.size.height/2;
        sender.layer.borderColor = UIColor.blueColor.CGColor;
        sender.layer.borderWidth = 1;
        
    } else {
        sender.layer.cornerRadius = 0;
        sender.layer.borderColor = self.subView.backgroundColor.CGColor;
        sender.layer.borderWidth = 0;
    }
}

- (NSArray *)weeks {
    if (!_weeks) {
        _weeks = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    }
    return _weeks;
}

@end


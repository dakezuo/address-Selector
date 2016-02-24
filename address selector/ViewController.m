//
//  ViewController.m
//  address selector
//
//  Created by Dakezuo on 16/2/23.
//  Copyright © 2016年 dianhun. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong)UIButton *button;
@property (nonatomic, strong)UILabel *label;
@property (nonatomic, strong)NSDictionary *dict;//省-市-区
@property (nonatomic, strong)NSArray *provinces;//省
@property (nonatomic, strong)NSArray *citys;//市
@property (nonatomic, strong)NSArray *districts;//区
@property (nonatomic, strong)UIPickerView *picker;//选择器
@property (nonatomic, strong)UIView *pickerBG;//选择器底
@property (nonatomic, strong)NSString *provinceTitle;
@property (nonatomic, strong)NSString *cityTitle;
@property (nonatomic, strong)NSString *districtsTitle;

@end

@implementation ViewController

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        _button.backgroundColor = [UIColor greenColor];
        _button.frame = CGRectMake(100, 200, 100, 50);
        [_button addTarget:self action:@selector(chooseArea:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, 280, 50)];
        _label.layer.borderColor = [UIColor blackColor].CGColor;
        _label.layer.borderWidth = 1.0f;
    }
    return _label;
}

- (UIView *)pickerBG {
    if (!_pickerBG) {
        CGRect viewRect = self.view.frame;
        CGFloat toolBarHeight = 40.0f;
        _pickerBG = [[UIView alloc] initWithFrame:CGRectMake(0, viewRect.size.height, viewRect.size.width, viewRect.size.height / 3 + toolBarHeight)];
        _pickerBG.backgroundColor = [UIColor whiteColor];
        UIToolbar *doneToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f,_pickerBG.frame.size.width, toolBarHeight)];
        
        UIBarButtonItem *finishItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(finishedAction:)];
        
        [finishItem setTintColor:[UIColor blackColor]];
        [doneToolbar setItems:[NSArray arrayWithObjects:finishItem, nil] animated:NO];
        [_pickerBG addSubview:doneToolbar];
        self.picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, toolBarHeight, _pickerBG.frame.size.width, _pickerBG.frame.size.height - toolBarHeight)];
        self.picker.dataSource = self;
        self.picker.delegate = self;
        [_pickerBG addSubview:self.picker];
    }
    return _pickerBG;
}

- (NSDictionary *)dict {
    if (!_dict) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *plistPath = [bundle pathForResource:@"area" ofType:@"plist"];
        _dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    return _dict;
}

- (NSArray *)provinces {
    if (!_provinces) {
        NSMutableArray *arr1 = [NSMutableArray array];
        NSArray *keys1 = [self.dict allKeys];
        NSArray *sortedKeys1 = [self compareKeys:keys1];
        for (NSString *key2 in sortedKeys1) {
            NSDictionary *dic2 = [self.dict objectForKey:key2];
            NSArray *keys2 = [dic2 allKeys];
            for (NSString *key3 in keys2) {
                [arr1 addObject:key3];
            }
        }
        _provinces = [NSArray arrayWithArray:arr1];
    }
    return _provinces;
}

- (NSArray *)compareKeys:(NSArray *)keys {
    NSArray *array = [keys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSString *a = (NSString *)obj1;
        NSString *b = (NSString *)obj2;
        int aNum = [a intValue];
        int bNum = [b intValue];
        
        if (aNum > bNum) {
            return NSOrderedDescending;
        }
        else if (aNum < bNum){
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    return array;
}

//刷新市
- (void)refrshOfCitysWithProvincsKey:(NSString *)provincesKey {
    int count = 0;
    NSMutableArray *arr1 = [NSMutableArray array];
    NSArray *keys1 = [self.dict allKeys];
    for (NSString *key2 in keys1) {
        NSDictionary *dic2 = [self.dict objectForKey:key2];
        NSDictionary *dic3 = [dic2 objectForKey:provincesKey];
        if (dic3.count > 0) {
            count++;
        }
        NSArray *keys3 = [dic3 allKeys];
        NSArray *sortedKeys3 = [self compareKeys:keys3];
        for (NSString *key4 in sortedKeys3) {
            NSDictionary *dic4 = [dic3 objectForKey:key4];
            NSArray *keys4 = [dic4 allKeys];
           // NSArray *keys4 = [key4 sortedArrayUsingSelector:@selector(compare:)];
            for (NSString *key5 in keys4) {
                [arr1 addObject:key5];
            }
        }
    }
    //NSLog(@"//////%@",arr1);
    if (count > 0) {
        self.citys = [NSArray arrayWithArray:arr1];
    } else {
        self.citys = @[];
    }
    

}

//刷新区
- (void)refrshOfDistrictsWithProvincsKey:(NSString *)provincesKey
                                CitysKey:(NSString *)citysKey {

    if ([citysKey isEqualToString:@""]) {
        self.districts = @[];
        return;
    }
    int count1 = 0;
    int count2 = 0;
    NSMutableArray *arr1 = [NSMutableArray array];
    NSArray *keys1 = [self.dict allKeys];
    for (NSString *key2 in keys1) {
        NSDictionary *dic2 = [self.dict objectForKey:key2];
        NSDictionary *dic3 = [dic2 objectForKey:provincesKey];
        NSArray *keys3 = [dic3 allKeys];
        if (dic3.count > 0) {
            count1++;
        }
        for (NSString *key4 in keys3) {
            NSDictionary *dic4 = [dic3 objectForKey:key4];
            NSArray *arr5 = [dic4 objectForKey:citysKey];
            if (arr5.count > 0) {
                count2++;
            }
            for (NSString *str in arr5) {
                [arr1 addObject:str];
            }
        }
    }
    if (count1 > 0 && count2 > 0) {
        self.districts = [NSArray arrayWithArray:arr1];
    } else {
        self.districts = @[];
    }
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view addSubview:self.button];
    [self.view addSubview:self.label];
}
//选择地区
- (void)chooseArea:(UIButton *)sender {
    self.provinceTitle = @"北京市";
    self.cityTitle = @"北京市";
    self.districtsTitle = @"东城区";
    CGFloat toolBarHeight = 40.0f;
    if (self.pickerBG != nil) {
        [self.pickerBG removeFromSuperview];
        self.pickerBG = nil;
    }
    [self.view addSubview:self.pickerBG];
    [UIView animateWithDuration:0.33 animations:^{
        self.pickerBG.frame = CGRectMake(0, self.view.bounds.size.height * 2 / 3 - toolBarHeight, self.view.frame.size.width, self.view.frame.size.height / 3 + toolBarHeight);
    }];
}
//完成选择
- (void)finishedAction:(id)sender
{
    __weak ViewController *weakSelf = self;
    [UIView animateWithDuration:0.33 animations:^{
        weakSelf.pickerBG.frame = CGRectMake(0, weakSelf.view.bounds.size.height, weakSelf.view.bounds.size.width, 0);
    } completion:^(BOOL finished) {
        [weakSelf.pickerBG removeFromSuperview];
        weakSelf.pickerBG = nil;
        NSString *str = @"";
        if ([self.provinceTitle isEqualToString:self.cityTitle] && [self.cityTitle isEqualToString:self.districtsTitle]) {
            str = self.provinceTitle;
        } else if ([self.provinceTitle isEqualToString:self.cityTitle]) {
            str = [self.provinceTitle stringByAppendingString:self.districtsTitle];
        } else if ([self.cityTitle isEqualToString:self.districtsTitle]) {
            str = [self.provinceTitle stringByAppendingString:self.cityTitle];
        } else {
            str = [[self.provinceTitle stringByAppendingString:self.cityTitle] stringByAppendingString:self.districtsTitle];

        }
        self.label.text = str;
    }];
}
//字体大小
- (CGFloat)fontWithString:(NSString *)string {
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 3;
    CGFloat font = 0;
    for (int i = 17; i > 0; i--) {
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:i]};
        CGSize rect = [string sizeWithAttributes:attributes];
        if (rect.width <= width) {
            font = (CGFloat)i;
            break;
        }
    }
    return font;
}


#pragma mark pickerViewDelegate

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinces.count;
    }else if (component == 1) {
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provincesKey = self.provinces[rowProvince];
        [self refrshOfCitysWithProvincsKey:provincesKey];
        if ([self.citys count] <= 0) {
            return 1;
        } else {
            return self.citys.count;
        }
        
    } else {
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provincesKey = self.provinces[rowProvince];
        [self refrshOfCitysWithProvincsKey:provincesKey];
        NSInteger rowCity = [pickerView selectedRowInComponent:1];
        NSString *citysKey = self.citys[rowCity];
        [self refrshOfDistrictsWithProvincsKey:provincesKey CitysKey:citysKey];
        if ([self.districts count] <= 0) {
            return 1;
        } else {
            return self.districts.count;
        }
    }
}
/*
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        return self.provinces[row];
    } else if (component == 1) {
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provincesKey = self.provinces[rowProvince];
        [self refrshOfCitysWithProvincsKey:provincesKey];
        return self.citys[row];
    } else {
        NSInteger rowProvince = [pickerView selectedRowInComponent:0];
        NSString *provincesKey = self.provinces[rowProvince];
        [self refrshOfCitysWithProvincsKey:provincesKey];
        NSInteger rowCity = [pickerView selectedRowInComponent:1];
        NSString *citysKey = self.citys[rowCity];
        [self refrshOfDistrictsWithProvincsKey:provincesKey CitysKey:citysKey];
        return self.districts[row];
    }
}
*/

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width / 3;
    UILabel *myView = nil;
    if (component == 0) {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.text = self.provinces[row];
        myView.font = [UIFont systemFontOfSize:[self fontWithString:myView.text]];         //用label来设置字体大小
        myView.backgroundColor = [UIColor clearColor];
    }else if (component == 1){
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 30)];
        myView.text = [self.citys count] ? self.citys[row] : @"";
        myView.textAlignment = NSTextAlignmentCenter;
        myView.font = [UIFont systemFontOfSize:[self fontWithString:myView.text]];
        myView.backgroundColor = [UIColor clearColor];
        if ([self.citys count] <= 0) {
            myView.userInteractionEnabled = NO;
        } else {
            myView.userInteractionEnabled = YES;
        }
    } else {
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 30)];
        myView.text = [self.districts count] ? self.districts[row] : @"";
        myView.textAlignment = NSTextAlignmentCenter;
        myView.font = [UIFont systemFontOfSize:[self fontWithString:myView.text]];
        myView.backgroundColor = [UIColor clearColor];
        if ([self.districts count] <= 0) {
            myView.userInteractionEnabled = NO;
        } else {
            myView.userInteractionEnabled = YES;
        }
    }
    
    return myView;
    
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        [pickerView reloadComponent:1];
        [pickerView reloadComponent:2];
    }
    if (component == 1) {
        [pickerView reloadComponent:2];
    }
    NSInteger rowProvince = [pickerView selectedRowInComponent:0];
    NSString *provincesKey = self.provinces[rowProvince];
    [self refrshOfCitysWithProvincsKey:provincesKey];
    NSInteger rowCity = [pickerView selectedRowInComponent:1];
    NSString *citysKey = self.citys[rowCity];
    [self refrshOfDistrictsWithProvincsKey:provincesKey CitysKey:citysKey];
    NSInteger rowDistricts = [pickerView selectedRowInComponent:2];
    NSString *districtsKey = self.districts[rowDistricts];
    self.provinceTitle = provincesKey;
    self.cityTitle = citysKey;
    self.districtsTitle = districtsKey;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

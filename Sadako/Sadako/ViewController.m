//
//  ViewController.m
//  Sadako
//
//  Created by GuYi on 2017/6/11.
//  Copyright © 2017年 GuYi. All rights reserved.
//

#import "ViewController.h"
#import "SadakoServer.h"
#import "LogMiddleWare.h"

@interface ViewController ()
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, strong) UIButton *rightItemButton;
@end

static NSString * const tableViewId = @"tableviewReuserIdentifier";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightItemButton];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:tableViewId];
    NSLog(@"view did load");
}

- (void)rightItemBtnAction :(UIButton *)sender {
    NSString *text = [sender titleForState:UIControlStateNormal];
    if ([text isEqualToString:@"开启服务"]) {
        [[SadakoServer sharedInstance] registerMiddleware:[LogMiddleWare class]];
        [[SadakoServer sharedInstance] switchClientType:CLI];
        [[SadakoServer sharedInstance] startServer];
        [sender setTitle:@"关闭服务" forState:UIControlStateNormal];
    }
    else{
        [[SadakoServer sharedInstance] stopServer];
        [sender setTitle:@"开启服务" forState:UIControlStateNormal];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableViewId];
    cell.textLabel.text = self.data[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectRowAtIndexPath index:%@",indexPath);
}


- (UIButton *)rightItemButton {
    if (!_rightItemButton) {
        _rightItemButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [_rightItemButton setTitle:@"开启服务" forState:UIControlStateNormal];
        [_rightItemButton addTarget:self action:@selector(rightItemBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightItemButton.frame = CGRectMake(0, 0, 80, 30);
    }
    return _rightItemButton;
}

- (NSArray *)data {
    if (!_data) {
        _data = @[@"第1行",@"第2行",@"第3行",@"第4行",@"第5行",@"第6行",@"第7行",@"第8行",@"第9行",@"第10行",@"第11行",@"第12行"];
    }
    return _data;
}

@end

//
//  ViewController.m
//  SMTableView
//
//  Created by 傅志阳 on 7/17/15.
//  Copyright (c) 2015 傅志阳. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet SMTableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.datasource = self;
    self.tableView.delegate = self;
    
    [self.tableView registerClass:[SMTableViewCell class] forIdentifier:@"SMCell"];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.tableView reloadData];
}


- (NSInteger)numberOfRowsInTableView:(SMTableView *)tableView {
    return 20;
}

- (CGFloat)tableView:(SMTableView *)tableView heightForRow:(NSInteger)row {
    return row % 2 ? 150 : 200;
}

- (SMTableViewCell *)tableView:(SMTableView *)tableView cellForRow:(NSInteger)row {
    SMTableViewCell *cell = [tableView dequeueCellForIdentifier:@"SMCell"];
    
    cell.backgroundColor = row % 2 ? [UIColor redColor] : [UIColor greenColor];
    
    return cell;
}

@end

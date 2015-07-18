//
//  SMTableView.h
//  SMTableView
//
//  Created by 傅志阳 on 7/17/15.
//  Copyright (c) 2015 傅志阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SMTableView;
@class SMTableViewCell;

@protocol SMTableViewDataSource <NSObject>

- (NSInteger)numberOfRowsInTableView:(SMTableView *)tableView;

@end

@protocol SMTableViewDelegate <NSObject, UIScrollViewDelegate>

- (CGFloat)tableView:(SMTableView *)tableView heightForRow:(NSInteger)row;
- (SMTableViewCell *)tableView:(SMTableView *)tableView cellForRow:(NSInteger)row;

@end

@interface SMTableViewCell : UIView

@property (nonatomic, copy, readonly) NSString *reuseIdentifier;

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end

@interface SMTableView : UIScrollView

@property (nonatomic, weak) id<SMTableViewDataSource> datasource;
@property (nonatomic, weak) id<SMTableViewDelegate> delegate;

- (void)registerClass:(Class)cellClass forIdentifier:(NSString *)identifier;
- (SMTableViewCell *)dequeueCellForIdentifier:(NSString *)identifier;
- (void)reloadData;

@end

//
//  SMTableView.m
//  SMTableView
//
//  Created by 傅志阳 on 7/17/15.
//  Copyright (c) 2015 傅志阳. All rights reserved.
//

#import "SMTableView.h"
#import "objc/runtime.h"

@implementation SMTableViewCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super init];
    if (self) {
        _reuseIdentifier = reuseIdentifier;
    }
    return self;
}

@end

const char kRecyclingCellIndexKey;

@interface SMTableView()

@property (nonatomic, strong) NSMutableDictionary *cellClasses;
@property (nonatomic, strong) NSMutableDictionary *recycleCells;
@property (nonatomic, assign) NSRange renderRange;

@end

@implementation SMTableView

@dynamic delegate;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup {
    _cellClasses  = [[NSMutableDictionary alloc] init];
    _recycleCells = [[NSMutableDictionary alloc] init];
}

- (void)registerClass:(Class)cellClass forIdentifier:(NSString *)identifier {
    [self.cellClasses setObject:cellClass forKey:identifier];
    [self.recycleCells setObject:[[NSMutableSet alloc] init] forKey:identifier];
}

- (SMTableViewCell *)dequeueCellForIdentifier:(NSString *)identifier {
    SMTableViewCell *cell = [((NSMutableSet *)self.recycleCells[identifier]) anyObject];
    if (!cell) {
        cell = [[(Class)self.cellClasses[identifier] alloc] initWithReuseIdentifier: identifier];
    }
    else {
        [(NSMutableSet *)self.recycleCells[identifier] removeObject:cell];
    }
    
    return cell;
}

- (void)reloadData {
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // update contentSize
    self.renderRange = [self computeVisibleRange];
    self.contentSize = [self computeContentSize];
    
    CGFloat startY = [self computePosYForRow:self.renderRange.location];
    
    for (NSInteger i = self.renderRange.location; i < NSMaxRange(self.renderRange); ++i) {
        CGFloat cellHeight = [self.delegate tableView:self heightForRow:i];
        SMTableViewCell *cell = [self.delegate tableView:self cellForRow:i];
        cell.frame = CGRectMake(0, startY, self.frame.size.width, cellHeight);
        
        objc_setAssociatedObject(cell, &kRecyclingCellIndexKey, @(i), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        [self addSubview:cell];
        
        startY += cellHeight;
    }
    
}

- (CGFloat)computePosYForRow:(NSInteger)row {
    CGFloat startY = 0;
    for (NSInteger i = 0; i < row; ++i) {
        CGFloat cellHeight = [self.delegate tableView:self heightForRow:i];
        
        startY += cellHeight;
    }
    
    return startY;
}

- (CGSize)computeContentSize {
    CGFloat contentHeight = 0;
    NSInteger count = [self.datasource numberOfRowsInTableView:self];
    for (NSInteger i = 0; i < count; ++i) {
        CGFloat cellHeight = [self.delegate tableView:self heightForRow:i];
        
        contentHeight += cellHeight;
    }
    
    return CGSizeMake(self.frame.size.width, contentHeight);
}

- (NSRange)computeVisibleRange {
    CGFloat contentHeight = 0;
    NSInteger startRow = -1;
    NSInteger endRow = -1;
    CGFloat startY = fabs(self.contentOffset.y);
    CGFloat endY = startY + self.frame.size.height;
    NSInteger count = [self.datasource numberOfRowsInTableView:self];
    for (NSInteger i = 0; i < count; ++i) {
        CGFloat cellHeight = [self.delegate tableView:self heightForRow:i];
        
        contentHeight += cellHeight;
        
        if (startRow == -1 && contentHeight > startY) {
            startRow = i;
        }
        if (endRow == -1 && contentHeight >= endY) {
            endRow = i;
        }
    }
    
    return NSMakeRange(startRow, endRow - startRow + 1);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSRange visibleRange = [self computeVisibleRange];
    
    if (!NSEqualRanges(visibleRange, self.renderRange)) {
        for (NSInteger i = self.renderRange.location; i < NSMaxRange(self.renderRange); ++i) {
            if (!NSLocationInRange(i, visibleRange)) {
                [self recycleCell:i];
            }
        }
        
        for (NSInteger i = visibleRange.location; i < NSMaxRange(visibleRange); ++i) {
            if (!NSLocationInRange(i, self.renderRange)) {
                [self renderCell:i];
            }
        }
        
        self.renderRange = visibleRange;
    }
}

- (void)recycleCell:(NSInteger)row {
    for (SMTableViewCell *cell in self.subviews) {
        NSNumber *num = objc_getAssociatedObject(cell, &kRecyclingCellIndexKey);
        if (row == [num integerValue]) {
            [self.recycleCells[cell.reuseIdentifier] addObject:cell];
            [cell removeFromSuperview];
        }
    }
}

- (void)renderCell:(NSInteger)row {
    SMTableViewCell *cell = [self.delegate tableView:self cellForRow:row];
    
    cell.frame = CGRectMake(0, [self computePosYForRow:row], self.frame.size.width, [self.delegate tableView:self heightForRow:row]);
    
    [self addSubview:cell];
    
    objc_setAssociatedObject(cell, &kRecyclingCellIndexKey, @(row), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end

# SMTableView
简单展示TableViewCell重用机制

源自一次技术面试，面试中没有说清实现细节，下来后自己实现了一遍。

对于 UITableView 和 UICollectionView, 其重要的特点是 Cell 可定制, 可重用. 为了达到这一点, Cocoa 框架使用了 DataSource 来实现, 而开启整个调用的方法就是 reloadData. 如果要自己来实现一个类似的类, 也可以借鉴这样的思路, 通过实现 reloadData, 首先获取到 numberOfSections, 再依次遍历每个 section 来获取到 numberOfRows, 这部分数据做缓存, 在下一次调用 reloadData 前都不会做变更. 紧接着应该获取当前 view 的 bounds 以及作为 Cell superview 的 scrollView 的 contentOffset, 接下来遍历 heightForCell, 并作缓存, 直到叠加的 height 大于等于 scrollView 的 contentOffset.y + view.bounds.size.height 或者遍历到了最后一个 cell, 这时你就知道当前要显示的第一个 cell 和 最后一个 cell 的 index. 接下来要做的重用 cell 部分的逻辑, 这里因为每个 cell 都有一个 identifier, 所以自定义的 view 应该会有一个 registerCellClass 类似的方法, 来建立 idenfifier 和 Cell class 的关联, 这样当调用 DataSource 的方法时，外部传入 identifierString 时，便可以知道要初始化或重用哪个 Cell, 并返回回去. 所以内部会有一个 NSDictionary 来做这样的缓存, 当 view 的 dequeueReusableCellForIdentifier: 被调用时, 会先去这个字典中查找对应的一个 NSMutableSet 的集合，如果存在，则通过 anyObject 尝试取得一个可用的 cell, 如果没有, 则创建, 反过来，当一个 cell 移出屏幕后, 应该将其放入这个 set 中, 以备之后重用时使用.

//
//  CollectionView.swift
//  CollectionView-simplify-business
//
//  Created by 孙继刚 on 2017/10/12.
//  Copyright © 2017年 孙继刚. All rights reserved.
//
// # 很贴心的预留了前缀`KTJ`，方便全文件替换 在实际使用中，可以去除下面的别名
typealias ListItemDefaultProtocol = KTJListItemDefaultProtocol
typealias CollectionViewSection = KTJCollectionViewSection
typealias CollectionView = KTJCollectionView

import UIKit
import CHTCollectionViewWaterfallLayout

protocol KTJListItemProtocol {
    var identifa: String { get }
    var newItem: AnyObject { get }
    var registClass: AnyClass { get }
    func fillModel(item: AnyObject)
}

protocol KTJListItemDefaultProtocol: KTJListItemProtocol {
    associatedtype ItemType: UIView
    func fillModel(view: ItemType)
}

extension KTJListItemDefaultProtocol {
    var identifa: String { return  NSStringFromClass(ItemType.self)}
    var newItem: AnyObject { return ItemType() }
    var registClass: AnyClass { return ItemType.self }
    func fillModel(item: AnyObject) {
        if let reusableView = item as? ItemType {
            fillModel(view: reusableView)
        }
    }
}

class KTJCollectionViewSection: NSObject {

    /// section的唯一标识符，此处交给数据初始化设置，默认为""<==>无
    var identifier = ""

    /// 该section上左下右的边距
    var sectionInset = UIEdgeInsets.zero

    /// 列数，默认为1
    var columnCount: Int?

    /// 该section列的最小距离
    var minimumColumnSpacing = 0.0

    /// 该swction行的最小距离
    var minimumInteritemSpacing = 0.0

    var header: KTJListItemProtocol?

    var items: [KTJListItemProtocol]?

    var footer: KTJListItemProtocol?
}

/// 只有部分可用。具体更新参看 class KTJCollectionView
protocol KTJCollectionViewDelegate: NSObjectProtocol {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
}

extension KTJCollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) { }
}

/// 携带格式化好数据源瀑布流
class KTJCollectionView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate, CHTCollectionViewDelegateWaterfallLayout {

    weak var allDelegate: KTJCollectionViewDelegate?

    /// 数据源
    var sections = [KTJCollectionViewSection]() {
        didSet {
            for section in sections {
                if let header = section.header {
                    self.register(header.registClass,
                                  forSupplementaryViewOfKind: CHTCollectionElementKindSectionHeader,
                                  withReuseIdentifier: header.identifa)
                }
                if let footer = section.footer {
                    self.register(footer.registClass,
                                  forSupplementaryViewOfKind: CHTCollectionElementKindSectionFooter,
                                  withReuseIdentifier: footer.identifa)
                }
                if let items = section.items {
                    for item in items {
                        self.register(item.registClass, forCellWithReuseIdentifier: item.identifa)
                    }
                }
            }
            self.reloadData()
        }
    }

    private var viewCache = NSCache<AnyObject, AnyObject>()

    convenience init() {
        let layout = CHTCollectionViewWaterfallLayout()
        layout.sectionInset = UIEdgeInsets.zero
        layout.minimumColumnSpacing = 0
        layout.minimumInteritemSpacing = 0
        self.init(frame: CGRect.zero, collectionViewLayout: layout)
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setup()
    }

    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        setup()
    }

    /// 基础配置
    private func setup() {
        self.delegate = self
        self.dataSource = self
    }

    // MARK: - UICollectionViewDataSource

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, columnCountForSection section: Int) -> Int {
        var columnCount = 0
        if section < sections.count {
            columnCount = sections[section].columnCount ?? 1
        }
        return columnCount
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var items = 0
        if section < sections.count {
            items = sections[section].items?.count ?? 0
        }
        return items
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        var returnCell: UICollectionViewCell?

        if indexPath.section < sections.count,
            indexPath.row < (sections[indexPath.section].items?.count ?? 0),
            let item = sections[indexPath.section].items?[indexPath.row] {

            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: item.identifa,
                                                          for: indexPath)
            item.fillModel(item: cell)
            cell.sizeToFit()
            returnCell = cell
        }

        return returnCell ?? UICollectionViewCell.init()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        var returnView: UICollectionReusableView?
        var item: KTJListItemProtocol?

        if  indexPath.section < sections.count {
            if kind == CHTCollectionElementKindSectionHeader {
                item = sections[indexPath.section].header
            } else if kind == CHTCollectionElementKindSectionFooter {
                item = sections[indexPath.section].footer
            }
        }

        if let item = item {
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                         withReuseIdentifier: item.identifa,
                                                                         for: indexPath)
            item.fillModel(item: view)
            returnView = view
        }

        return returnView ?? UICollectionReusableView.init()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.allDelegate?.collectionView(self, didSelectItemAt: indexPath)
    }

    // MARK: - CHTCollectionViewDelegateWaterfallLayout
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, sizeForItemAt indexPath: IndexPath!) -> CGSize {

        var returnSize: CGSize?

        if indexPath.section < sections.count,
            indexPath.row < (sections[indexPath.section].items?.count ?? 0),
            let item = sections[indexPath.section].items?[indexPath.row] {

            if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
                as? UICollectionViewCell {

                let section = sections[indexPath.section]
                if let columnCount = section.columnCount,
                    columnCount > 1 {
                    var width = collectionView.bounds.width
                            - section.sectionInset.left
                            - section.sectionInset.right
                            - CGFloat(columnCount-1) * CGFloat(section.minimumColumnSpacing)
                    width /= CGFloat(columnCount)
                    cell.frame = CGRect(x: 0, y: 0, width: width, height: collectionView.bounds.height)
                } else {
                    cell.frame = CGRect(x: 0,
                                        y: 0,
                                        width: collectionView.bounds.width
                                            - section.sectionInset.left
                                            - section.sectionInset.right,
                                        height: collectionView.bounds.height)
                }
                item.fillModel(item: cell)
                cell.sizeToFit()
                returnSize = cell.frame.size
                viewCache.setObject(cell, forKey: item.identifa as AnyObject)
            }
        }

        return returnSize ?? CGSize.zero
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForHeaderInSection section: Int) -> CGFloat {

        var returnFloat: CGFloat?

        if section < sections.count,
            let item = sections[section].header {

            if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
                as? UIView {

                cell.frame = collectionView.bounds
                item.fillModel(item: cell)
                cell.sizeToFit()
                returnFloat = cell.frame.height
                viewCache.setObject(cell, forKey: item.identifa as AnyObject)
            }
        }

        return returnFloat ?? 0
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, heightForFooterInSection section: Int) -> CGFloat {

        var returnFloat: CGFloat?

        if section < sections.count,
            let item = sections[section].footer {

            if let cell = (viewCache.object(forKey: item.identifa as AnyObject) ?? item.newItem)
                as? UIView {

                cell.frame = collectionView.bounds
                item.fillModel(item: cell)
                cell.sizeToFit()
                returnFloat = cell.frame.height
                viewCache.setObject(cell, forKey: item.identifa as AnyObject)
            }
        }

        return returnFloat ?? 0
    }

    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, insetForSectionAt section: Int) -> UIEdgeInsets {

        if section < sections.count {
            return sections[section].sectionInset
        }

        return UIEdgeInsets.zero
    }
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumColumnSpacingForSectionAt section: Int) -> CGFloat {

        if section < sections.count {
            return CGFloat(sections[section].minimumColumnSpacing)
        }

        return  0
    }
    func collectionView(_ collectionView: UICollectionView!, layout collectionViewLayout: UICollectionViewLayout!, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        if section < sections.count {
            return CGFloat(sections[section].minimumInteritemSpacing)
        }

        return  0
    }

}

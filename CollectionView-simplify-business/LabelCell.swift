//
//  LabelCell.swift
//  CollectionView-simplify-business
//
//  Created by 孙继刚 on 2017/10/12.
//  Copyright © 2017年 孙继刚. All rights reserved.
//

import UIKit

class LabelCell: UICollectionViewCell {

    let info = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    /// 设置相关变量并添加至contentView
    func setup() {
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 1/UIScreen.main.scale
        contentView.addSubview(info)
    }
    /// 此方法需要根据size.width返回height，不管用autolayout还是frame。
    /// 当然，如果使用autolayout你可以采用[UITableView-FDTemplateLayoutCell](https://github.com/forkingdog/UITableView-FDTemplateLayoutCell/blob/master/Classes/UITableView%2BFDTemplateLayoutCell.m#L238-#L251)中的这种方案进行返回。
    override func sizeThatFits(_ size: CGSize) -> CGSize {

        info.sizeToFit()
        info.frame.origin.y = 10
        info.frame.origin.x = 5

        return CGSize(width: size.width, height: info.frame.maxY + info.frame.minY)
    }
}

extension LabelCell {
    class Model: ListItemDefaultProtocol {

        var info: String?

        /// 将model中的属性设置给cell
        ///
        /// - Parameter view: 所绑定的对应的Cell
        func fillModel(view: LabelCell) {
            view.info.text = info
        }
    }
}

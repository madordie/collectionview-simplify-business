//
//  ViewController.swift
//  CollectionView-simplify-business
//
//  Created by 孙继刚 on 2017/10/12.
//  Copyright © 2017年 孙继刚. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var list: CollectionView!
    let model = Model()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        list.frame = view.bounds
        list.backgroundColor = UIColor.white
        list.sections = model.get()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    class Model {
        func get() -> [CollectionViewSection] {
            var info = [String]()
            for i in 0..<20 {
                info.append("\(i)")
            }
            return format(list: info)
        }
        func format(list: [String]) -> [CollectionViewSection] {
            let section1 = CollectionViewSection()
            section1.columnCount = 3
            section1.items = list.map({ (v) -> LabelCell.Model in
                let cell = LabelCell.Model()
                cell.info = "section1: " + v
                return cell
            })
            let section2 = CollectionViewSection()
            section2.items = list.map({ (v) -> LabelCell.Model in
                let cell = LabelCell.Model()
                cell.info = "section2: " + v
                return cell
            })
            return [section1, section2]
        }
    }
}

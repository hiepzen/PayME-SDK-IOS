//
//  ViewController.swift
//  One Time Code
//
//  Created by Kyle Lee on 5/25/19.
//  Copyright © 2019 Kilo Loco. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
extension ViewController: PanModalPresentable {

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent    //ステータスバーの色
    }

    var panScrollable: UIScrollView? {
        return nil
    }

    var longFormHeight: PanModalHeight {
        return .contentHeight(150)  //ニョキっとメニューの高さ
    }

    var anchorModalToLongForm: Bool {
        return false
    }
}

//
//  MemberViewController.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/18.
//

import UIKit

class MemberViewController: UIViewController {
    var logout: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func tappedLogout() {
        logout?()
    }
}

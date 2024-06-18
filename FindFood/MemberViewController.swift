//
//  MemberViewController.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/18.
//

import UIKit

final class MemberViewController: UIViewController {
    var logout: (() -> Void)?
    var member: User

    init?(coder: NSCoder, member: User) {
        self.member = member
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func tappedLogout() {
        logout?()
    }
}

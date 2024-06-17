//
//  MainTabBarController.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/14.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let loginVC = viewController as? LoginViewController {
            let googleLoginVM = LoginViewModel(delegate: loginVC, provider: GSAuthProvider(presentViewController: loginVC))
            let facebookLoginVC = LoginViewModel(delegate: loginVC, provider: FBAuthProvider())
            loginVC.googleLogin = {
                googleLoginVM.login()
            }
            loginVC.facebookLogin = {
                facebookLoginVC.login()
            }
        }
    }
}

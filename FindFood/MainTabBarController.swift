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
        if let nav = viewController as? UINavigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let loginVC = storyboard.instantiateViewController(identifier: String(describing: LoginViewController.self)) as LoginViewController
            let googleProvider = GSAuthProvider(presentViewController: loginVC)
            let facebookProvider = FBAuthProvider()
            let googleLoginVM = LoginViewModel(delegate: loginVC, provider: googleProvider)
            let facebookLoginVM = LoginViewModel(delegate: loginVC, provider: facebookProvider)
            loginVC.googleLogin = {
                googleLoginVM.login()
            }
            loginVC.facebookLogin = {
                facebookLoginVM.login()
            }
            loginVC.showMemberVC = { user in
                let memberVC = storyboard.instantiateViewController(identifier: String(describing: MemberViewController.self)) { creator in
                    let vc = MemberViewController(coder: creator, member: user)
                    return vc
                } as MemberViewController
                memberVC.modalPresentationStyle = .fullScreen
                memberVC.logout = {
                    switch user.loginType {
                    case .google:
                        googleProvider.logoutUser()
                    case .facebook:
                        facebookProvider.logoutUser()
                    }
                    nav.popViewController(animated: true)
                }
                nav.pushViewController(memberVC, animated: true)
            }
            nav.setNavigationBarHidden(true, animated: false)
            nav.setViewControllers([loginVC], animated: false)
        }
    }
}

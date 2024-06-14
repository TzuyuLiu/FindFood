//
//  LoginViewController.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import UIKit

class LoginViewController: UIViewController {
    var googleLogin: (() -> Void)?
    var facebookLogin: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func tappedGoogleLogin() {
        googleLogin?()
    }
}

extension LoginViewController: LoginViewModelDelegate {
    func didCreateUser(_ user: User) {
        print("user:\(user)")
    }

    func didReceiveErrorMessage(_ error: AuthProviderError) {
        let alert = UIAlertController(title: "登入失敗", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: false)
    }
}


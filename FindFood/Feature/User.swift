//
//  User.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import UIKit

enum LoginType: String {
    case google
    case facebook
}

struct User {
    let name: String
    let image: URL?
    let idToken: String
    let loginType: LoginType // 用來判斷是用什麼軟體登入

    init(name: String, image: URL?, idToken: String, loginType: LoginType) {
        self.name = name
        self.image = image
        self.idToken = idToken
        self.loginType = loginType
    }
}

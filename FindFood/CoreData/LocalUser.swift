//
//  LocalUser.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/28.
//

import Foundation

enum LocalLoginType: String, Equatable {
    case google
    case facebook
}

public struct LocalUser: Equatable {
    let name: String
    let image: URL?
    let idToken: String
    let loginType: LocalLoginType // 用來判斷是用什麼軟體登入

    init(name: String, image: URL?, idToken: String, loginType: LocalLoginType) {
        self.name = name
        self.image = image
        self.idToken = idToken
        self.loginType = loginType
    }
}

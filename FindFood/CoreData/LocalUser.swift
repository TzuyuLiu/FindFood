//
//  LocalUser.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/28.
//

import Foundation

public enum LocalLoginType: String, Equatable {
    case google
    case facebook
}

// 用來消除模組間的強耦合(UserStore 對上 User)
public struct LocalUser: Equatable {
    let name: String
    let image: URL?
    let idToken: String
    let loginType: LocalLoginType // 用來判斷是用什麼軟體登入

    // 其他 module 會產生 FeedLoader，因此其他 module 也會使用到
    public init(name: String, image: URL?, idToken: String, loginType: LocalLoginType) {
        self.name = name
        self.image = image
        self.idToken = idToken
        self.loginType = loginType
    }
}

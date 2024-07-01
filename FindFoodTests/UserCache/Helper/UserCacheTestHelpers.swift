//
//  UserCacheTestHelpers.swift
//  FindFoodTests
//
//  Created by 劉子瑜-20001220 on 2024/7/1.
//

import Foundation
@testable import FindFood

func makeUser() -> User {
    return User(name: "Andy",
                image: nil,
                idToken: "12345",
                loginType: .facebook)
}

func makeLocalUser() -> LocalUser {
    return LocalUser(name: "Andy",
                image: nil,
                idToken: "12345",
                loginType: .facebook)
}

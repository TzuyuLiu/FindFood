//
//  UserCacheTestHelpers.swift
//  FindFoodTests
//
//  Created by 劉子瑜-20001220 on 2024/7/1.
//

import Foundation
@testable import FindFood

func userA() -> User {
    return User(name: "Andy",
                image: nil,
                idToken: "12345",
                loginType: .facebook)
}

func localUserA() -> LocalUser {
    return LocalUser(name: "Andy",
                image: nil,
                idToken: "12345",
                loginType: .facebook)
}

func localUserB() -> LocalUser {
    return LocalUser(name: "Andy",
                image: nil,
                idToken: "59210",
                loginType: .google)
}

func anyError() -> NSError {
    return NSError(domain: "An Error", code: 0)
}

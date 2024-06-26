//
//  AuthProvider.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import Foundation

enum AuthProviderError: Error {
    case cannotGetUserInfo
    case convertDataFail
    case custom(reason: Error)
}

protocol AuthProvider {
    typealias Result = Swift.Result<User, AuthProviderError>

    func fetchUser(completion: @escaping(Result) -> Void)
}

//
//  UserLoader.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/28.
//

import Foundation

public enum LoadUserResult {
    case success(User?)
    case failure(Error)
}

public protocol UserLoader {
    func load(completion: @escaping (LoadUserResult) -> Void)
}


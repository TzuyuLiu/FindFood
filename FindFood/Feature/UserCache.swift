//
//  UserCache.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/19.
//

import Foundation

protocol UserCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [User], completion: @escaping (Result) -> Void)
}

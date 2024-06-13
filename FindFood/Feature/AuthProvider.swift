//
//  AuthProvider.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import Foundation

protocol AuthProvider {
    typealias Result = Swift.Result<User, Error>
    
    func fetchUser(completion: @escaping(Result) -> Void)
    func logoutUser()
}

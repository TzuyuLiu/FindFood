//
//  UserStore.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/27.
//

import Foundation

public enum RetrieveStoredUserResult {
    case empty
    case found(User)
    case failure(Error)
}

protocol UserStore {
    var user: User? { get }
    typealias SaveCompletions = (Error?) -> Void
    typealias DeleteCompletions = (Error?) -> Void
    typealias RetrieveCompletions = (RetrieveStoredUserResult) -> Void

    func save(_ user: User, completion: @escaping SaveCompletions)
    func deleteUser(completion: @escaping DeleteCompletions)
    func retrieve(completion: @escaping RetrieveCompletions)
}


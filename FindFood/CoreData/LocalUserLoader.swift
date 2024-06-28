//
//  LocalUserLoader.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/27.
//

import Foundation

class LocalUserLoader {
    private let store: UserStore

    typealias SaveResult = Error?
    typealias DeleteResult = Error?
    typealias LoadResult = LoadUserResult

    init(store: UserStore) {
        self.store = store
    }
}

extension LocalUserLoader {
    func login(_ result: Result<User, Error>, completion: @escaping (SaveResult) -> Void) {
        switch result {
        case .success(let user):
            store.save(user) { [weak self] error in
                guard let self = self else { return }
                completion(error)
            }
        case .failure(let failure):
            completion(failure)
        }
    }

    func logout(completion: @escaping (DeleteResult) -> Void) throws {
        guard store.user != nil else {
            throw NSError(domain: "Doesn't have a user.", code: 998)
        }

        store.deleteUser(completion: completion)
    }
}

extension LocalUserLoader: UserLoader {
    func load(completion: @escaping (LoadUserResult) -> Void) {
        store.retrieve { result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case .empty:
                completion(.success(nil))
            case let .found(user):
                completion(.success(user))
            }
        }
    }
}

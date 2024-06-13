//
//  LoginViewModel.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/13.
//

import Foundation

protocol LoginViewModelDelegate: AnyObject {
    func didCreateUser(_ user: User)
    func didReceiveErrorMessage(_ error: AuthProviderError)
}

class LoginViewModel {
    weak var delegate: LoginViewModelDelegate?
    let provider: AuthProvider

    init(delegate: LoginViewModelDelegate, provider: AuthProvider) {
        self.delegate = delegate
        self.provider = provider
    }

    func login() {
        provider.fetchUser { [weak self] result in
            switch result {
            case .success(let user):
                self?.delegate?.didCreateUser(user)
            case .failure(let error):
                self?.delegate?.didReceiveErrorMessage(error)
            }
        }
    }
}

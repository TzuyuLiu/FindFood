//
//  FBAuthProvider.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/17.
//

import Foundation
import FBSDKLoginKit

final class FBAuthProvider: AuthProvider, LogoutProvider {
    
    func fetchUser(completion: @escaping (AuthProvider.Result) -> Void) {
        let loginManager = LoginManager()

        loginManager.logIn(permissions: ["email", "public_profile"], from: nil) { (result, error) in
            guard error == nil else {
                completion(.failure(.custom(reason: error!)))
                return
            }

            let request = GraphRequest(graphPath: "me", parameters: ["fields": "id, email, name, picture"])

            request.start { _, result, error in
                guard let result = result as? [String: Any] else {
                    completion(.failure(.convertDataFail))
                    return
                }
                guard error == nil else {
                    completion(.failure(.custom(reason: error!)))
                    return
                }

                let mapper = FacebookUserMapper(result)
                let decodeResult = mapper.result

                switch decodeResult {
                case .success(let data):
                    completion(.success(data.user))
                case .failure(let failure):
                    completion(.failure(.custom(reason: failure)))
                }
            }
        }
    }

    func logoutUser() {
        let loginManager = LoginManager()
        loginManager.logOut()
    }
}

func convertDictionaryToJSON(_ dictionary: [String: Any]) -> Data? {
   guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
      print("Something is wrong while converting dictionary to JSON data.")
      return nil
   }

   return jsonData
}

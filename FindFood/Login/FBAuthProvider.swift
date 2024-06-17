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
                guard let result = result as? [String: Any],
                      let json = convertDictionaryToJSON(result) else {
                    completion(.failure(.convertDataFail))
                    return
                }
                guard error == nil else {
                    completion(.failure(.custom(reason: error!)))
                    return
                }

                let decoder = JSONDecoder()
                let decodeResult = Swift.Result{ try decoder.decode(FacebookUserMapper.Root.self, from: json) }

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

final class FacebookUserMapper {
    private init() { }
    struct Root: Decodable {
        let name: String?
        let id: String
        let picture: Picture

        var user: User {
            return User(name: self.name ?? "", image: self.picture.data?.url, idToken: self.id)
        }
    }

    struct Picture: Decodable {
        var data: PicData?
        struct PicData: Decodable {
            let url: URL?
            let height: Int?
            
            enum CodingKeys: String, CodingKey {
                case url
                case height
            }
            
            init(from decoder: Decoder) throws {
                let values = try decoder.container(keyedBy: CodingKeys.self)
                height = try? values.decodeIfPresent(Int.self, forKey: .height)
                let urlString = (try? values.decodeIfPresent(String.self, forKey: .url)) ?? ""
                url = URL(string: urlString)
            }
        }
    }
}

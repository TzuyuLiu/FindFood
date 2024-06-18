//
//  FacebookUserMapper.swift
//  FindFood
//
//  Created by 劉子瑜-20001220 on 2024/6/18.
//

import Foundation

final class FacebookUserMapper {
    private let data: Data?

    init(_ dictionary: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted) else {
           print("Something is wrong while converting dictionary to JSON data.")
            data = nil
            return
        }
        data = jsonData
    }

    var result: Result<FacebookUserMapper.Root, Error> {
        guard let data = data else { return .failure(NSError(domain: "Data is nil", code: 999)) }
        let decoder = JSONDecoder()
        return Swift.Result{ try decoder.decode(FacebookUserMapper.Root.self, from: data) }
    }

    struct Root: Decodable {
        let name: String?
        let id: String
        let picture: Picture

        var user: User {
            return User(name: self.name ?? "", image: self.picture.data?.url, idToken: self.id, loginType: .facebook)
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

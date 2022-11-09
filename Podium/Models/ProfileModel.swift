//
//  ProfileModel.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation

struct ProfileModel: Equatable, Identifiable {
  var id: String
}

extension ProfileModel: Codable {
  init(dictionary: [String: Any]) throws {
    self = try JSONDecoder().decode(
      ProfileModel.self,
      from: JSONSerialization.data(withJSONObject: dictionary)
    )
  }
  
  func encoded() -> Data? {
    let encoder = JSONEncoder()
    return try? encoder.encode(self)
  }
}

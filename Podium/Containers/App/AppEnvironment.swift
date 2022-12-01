//
//  AppEnvironment.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation

struct AppEnvironment {
  let api = API()
  let localStorage = UserDefaults.standard
  var privacyUrl = "https://podium.town/privacy"
  var termsUrl = "https://podium.town/terms"
}

//
//  AppError.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation

enum AppError: Error, Codable {
  case general
  case profileNotExists
  case usernameTaken
}

extension AppError: LocalizedError {
  public var errorDescription: String? {
    switch self {
    case .profileNotExists:
      return "Profile not found"
      
    case .usernameTaken:
      return "Username taken"
      
    case .general:
      return "Generic error"
    }
  }
}

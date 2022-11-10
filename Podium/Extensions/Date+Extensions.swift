//
//  Date+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import Foundation

extension Date {
  var millisecondsSince1970: Int64 {
    Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }
  
  func timeAgoDisplay() -> String {
    let formatter = RelativeDateTimeFormatter()
    formatter.unitsStyle = .full
    return formatter.localizedString(for: self, relativeTo: Date())
  }
}

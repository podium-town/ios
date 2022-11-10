//
//  String+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 10/11/2022.
//

import UIKit

extension String {
  func base64ToImage() -> UIImage? {
    if let data = Data(base64Encoded: self) {
      return UIImage(data: data)
    } else {
      return nil
    }
  }
}

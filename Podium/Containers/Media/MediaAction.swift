//
//  MediaAction.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import ComposableArchitecture
import Foundation

enum MediaAction {
  case loadImage(fileId: String)
  case didLoadImage(TaskResult<(String, Data)>)
}

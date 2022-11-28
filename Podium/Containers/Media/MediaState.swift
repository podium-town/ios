//
//  MediaState.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import Foundation

struct MediaState: Equatable {
  var post: PostProfileModel
  var loadedImages: [String: Data]?
}

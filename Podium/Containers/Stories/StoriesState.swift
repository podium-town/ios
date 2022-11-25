//
//  StoriesState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation
import UIKit

struct StoriesState: Equatable {
  var profile: ProfileModel
  var loadedMedia: [String: Data] = [:]
  var stories: [String: [StoryModel]]
  var currentProfile: String?
  var currentStory: StoryModel?
  var profilesIterator: IndexingIterator<[Array<String>.Element]>?
  var storiesIterator: IndexingIterator<[Array<StoryModel>.Element]>?
  var urls: [String] = []
  var isPickerPresented = false
  var images: [UIImage] = []
}

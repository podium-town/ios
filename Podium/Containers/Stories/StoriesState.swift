//
//  StoriesState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import Foundation
import UIKit

struct StoriesState: Equatable {
  var isSelf: Bool { profile.id == currentProfile }
  var profile: ProfileModel
  var loadedMedia: [String: Data] = [:]
  var stories: [String: [StoryProfileModel]]
  var profiles: [ProfileModel] = []
  var currentProfile: String?
  var currentStory: StoryProfileModel?
  var profilesIterator: BidirectionalIterator<[String], Array<String>.Index>?
  var storiesIterator: BidirectionalIterator<[StoryProfileModel], Array<StoryProfileModel>.Index>?
  var urls: [StoryUrlModel] = []
  var isPickerPresented = false
  var images: [UIImage] = []
  var isLoading = false
  var bannerData: BannerData?
  var pendingRequestId: String?
}

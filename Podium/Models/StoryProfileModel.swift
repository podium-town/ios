//
//  StoryProfileModel.swift
//  Podium
//
//  Created by Michael Jach on 27/11/2022.
//

struct StoryProfileModel: Equatable, Identifiable {
  var id: String { story.id }
  var story: StoryModel
  var profile: ProfileModel
}

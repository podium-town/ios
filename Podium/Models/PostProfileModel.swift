//
//  PostProfileModel.swift
//  Podium
//
//  Created by Michael Jach on 27/11/2022.
//

struct PostProfileModel: Equatable, Identifiable {
  var id: String
  var post: PostModel
  var profile: ProfileModel
}

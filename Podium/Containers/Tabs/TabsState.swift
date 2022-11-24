//
//  TabsState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

struct TabsState: Equatable {
  var profile: ProfileModel
  var isMenuOpen = false
  
  // View States
  var homeState: HomeState
  var profileState: ProfileState
  var addState: AddState
  var exploreState: ExploreState
}

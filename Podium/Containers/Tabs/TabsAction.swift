//
//  TabsAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

enum TabsAction {
  case initialize
  
  // View Actions
  case home(HomeAction)
  case profile(ProfileAction)
  case add(AddAction)
}

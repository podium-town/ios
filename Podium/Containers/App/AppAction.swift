//
//  AppAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

enum AppAction {
  case initialize
  
  // View Actions
  case login(LoginAction)
  case tabs(TabsAction)
}

//
//  HomeAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

enum HomeAction {
  case initialize
  case presentStories(isPresented: Bool)
  case presentThread(isPresented: Bool)
  
  // View Actions
  case stories(StoriesAction)
  case thread(ThreadAction)
}

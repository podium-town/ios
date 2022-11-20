//
//  TabsView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct TabsView: View {
  let store: Store<TabsState, TabsAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TabView {
        HomeView(store: store.scope(
          state: \.homeState,
          action: TabsAction.home
        ))
        .tabItem {
          Image("home")
            .resizable()
            .frame(width: 26, height: 26, alignment: .center)
        }
        
        ExploreView(store: store.scope(
          state: \.exploreState,
          action: TabsAction.explore
        ))
          .tabItem {
            Image("search")
              .resizable()
              .frame(width: 26, height: 26, alignment: .center)
          }
        
        Text("⌛ Coming soon...")
          .fontWeight(.medium)
          .foregroundColor(.gray)
          .tabItem {
            Image("messages")
              .resizable()
              .frame(width: 26, height: 26, alignment: .center)
          }
        
        NavigationView {
          ProfileView(store: store.scope(
            state: \.profileState,
            action: TabsAction.profile
          ))
        }
          .tabItem {
            Image("profile")
              .resizable()
              .frame(width: 26, height: 26, alignment: .center)
          }
      }
      .tabViewStyle(
        backgroundColor: Color("ColorBackground")
      )
      .onAppear {
        viewStore.send(.getPosts)
      }
    }
  }
}

struct TabsView_Previews: PreviewProvider {
  static var previews: some View {
    TabsView(store: Store(
      initialState: TabsState(
        profile: Mocks.profile,
        homeState: HomeState(
          profile: Mocks.profile,
          posts: [Mocks.post]
        ),
        profileState: ProfileState(
          profile: Mocks.profile
        ),
        addState: AddState(
          profile: Mocks.profile
        ),
        exploreState: ExploreState(
          profile: Mocks.profile
        )
      ),
      reducer: tabsReducer,
      environment: AppEnvironment()
    ))
  }
}

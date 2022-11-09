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
        IfLetStore(
          store.scope(
            state: \.home,
            action: TabsAction.home
          ),
          then: HomeView.init(store:)
        )
        .tabItem {
          Image("home")
            .resizable()
            .frame(width: 26, height: 26, alignment: .center)
        }
        
        Text("search")
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
        
        Text("Profile")
          .tabItem {
            Image("profile")
              .resizable()
              .frame(width: 26, height: 26, alignment: .center)
          }
        
        Text("Add")
          .tabItem {
            Image("add")
              .resizable()
              .frame(width: 26, height: 26, alignment: .center)
          }
      }
      .tabViewStyle(
        backgroundColor: Color("ColorBackground")
      )
      .onAppear {
        viewStore.send(.initialize)
      }
    }
  }
}

struct TabsView_Previews: PreviewProvider {
  static var previews: some View {
    TabsView(store: Store(
      initialState: TabsState(),
      reducer: tabsReducer,
      environment: AppEnvironment()
    ))
  }
}

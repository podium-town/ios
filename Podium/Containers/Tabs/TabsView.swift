//
//  TabsView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct TabsView: View {
  @Environment(\.scenePhase) private var scenePhase
  
  let store: StoreOf<Tabs>
  
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
        .navigationViewStyle(StackNavigationViewStyle())
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
        viewStore.send(.initialize)
        viewStore.send(.getProfile)
        API.listenPosts(ids: viewStore.profile.following.filter({ !viewStore.profile.blockedProfiles.contains($0) })) { posts in
          DispatchQueue.main.async {
            viewStore.send(.addPosts(posts: posts))
          }
        }
        API.listenStories(ids: viewStore.profile.following.filter({ !viewStore.profile.blockedProfiles.contains($0) }), profileId: viewStore.profile.id) { (st, storiesToRemove) in
          DispatchQueue.main.async {
            let (stories, urls, profiles) = st
            viewStore.send(.addStories(stories: stories, urls: urls, profiles: profiles))
            viewStore.send(.removeStories(stories: storiesToRemove))
          }
        }
      }
      .onChange(of: scenePhase) { newPhase in
        if newPhase == .active {
          viewStore.send(.getPosts)
        }
      }
      .overlay {
        if viewStore.isMenuOpen {
          Color.white.opacity(0.001)
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
              viewStore.send(.onMenuClose)
            }
            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .global)
              .onEnded { value in
                viewStore.send(.onMenuClose)
              }
            )
        }
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
          profile: Mocks.profile
        ),
        profileState: ProfileState(
          fromProfile: Mocks.profile,
          profile: Mocks.profile
        ),
        exploreState: ExploreState(
          profile: Mocks.profile
        )
      ),
      reducer: Tabs()
    ))
  }
}

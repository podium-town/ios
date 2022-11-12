//
//  ExploreView.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct ExploreView: View {
  let store: Store<ExploreState, ExploreAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        ScrollView {
          LazyVStack(pinnedViews: [.sectionHeaders]) {
            Section(header: SearchBar(searchQuery: viewStore.binding(
              get: \.searchQuery,
              send: ExploreAction.searchQueryChanged
            ), onClear: {
              viewStore.send(.clearSearch)
            })
              .padding(.vertical, 8)
              .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
              .background(Color("ColorBackground"))
            ) {
              VStack(alignment: .leading) {
                HStack {
                  VStack {
                    HStack {
                      Spacer()
                      Text("Peding")
                      Spacer()
                    }
                  }
                  .frame(height: 120)
                  .background(
                    RoundedRectangle(cornerRadius: 13)
                      .foregroundColor(Color("ColorLightAccent"))
                  )
                  
                  Spacer()
                  
                  VStack {
                    HStack {
                      Spacer()
                      Text("Peding")
                      Spacer()
                    }
                  }
                  .frame(height: 120)
                  .background(
                    RoundedRectangle(cornerRadius: 13)
                      .foregroundColor(Color("ColorLightAccent"))
                  )
                  
                  Spacer()
                  
                  VStack {
                    HStack {
                      Spacer()
                      Text("Peding")
                      Spacer()
                    }
                  }
                  .frame(height: 120)
                  .background(
                    RoundedRectangle(cornerRadius: 13)
                      .foregroundColor(Color("ColorLightAccent"))
                  )
                }
                
                Text("🌎 Global")
                  .fontWeight(.semibold)
                  .padding(.top, 18)
                
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack {
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                    
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                    
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                    
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                    
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                    
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                    
                    Text("asdsada")
                      .padding(.horizontal)
                      .padding(.vertical, 10)
                      .background(
                        RoundedRectangle(cornerRadius: 24)
                          .foregroundColor(.gray)
                      )
                  }
                }
                
                Text("🤗 Profiles")
                  .fontWeight(.semibold)
                  .padding(.top, 18)
                
                ForEach(viewStore.profiles) { profile in
                  NavigationLink(destination: Text("Hi")) {
                    ExploreProfile(
                      profile: profile,
                      disabled: .constant(viewStore.pendingFollowRequests.contains(profile.id)),
                      isFollowing: .constant(viewStore.profile.following.contains(profile.id))
                    ) { userId in
                      viewStore.send(.follow(userId))
                    } onUnfollow: { userId in
                      viewStore.send(.unFollow(userId))
                    }
                  }
                }
              }
            }
          }
          .padding(.horizontal)
        }
        .padding(.top, 1)
      }
    }
  }
}

struct ExploreView_Previews: PreviewProvider {
  static var previews: some View {
    ExploreView(store: Store(
      initialState: ExploreState(
        profile: Mocks.profile,
        profiles: [Mocks.profile]
      ),
      reducer: exploreReducer,
      environment: AppEnvironment()
    ))
  }
}

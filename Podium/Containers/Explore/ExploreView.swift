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
        ZStack {
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
                  RoundedRectangle(cornerRadius: 15)
                    .frame(height: 120)
                    .overlay(
                      ZStack {
                        Image("welcome")
                          .resizable()
                          .scaledToFill()
                          .frame(height: 120)
                          .clipShape(RoundedRectangle(cornerRadius: 15))
                        
                        Text("#welcome")
                          .fontWeight(.semibold)
                          
                        VStack {
                          Spacer()
                          HStack {
                            Spacer()
                            Text("@jach")
                              .fontWeight(.medium)
                              .padding(10)
                          }
                        }
                      }
                    )
                  
                  Text("🌎 Trends")
                    .fontWeight(.semibold)
                    .padding(.top, 18)
                  
                  ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                      ForEach(viewStore.hashtags) { tag in
                        Text(tag.hashtag)
                          .fontWeight(.medium)
                          .padding(.horizontal)
                          .padding(.vertical, 10)
                          .background(
                            RoundedRectangle(cornerRadius: 24)
                              .foregroundColor(Color("ColorLightBackground"))
                          )
                      }
                    }
                  }
                  .onAppear {
                    viewStore.send(.getTopHashtags)
                  }
                  
                  Text("🤗 Profiles")
                    .fontWeight(.semibold)
                    .padding(.top, 18)
                  
                  ForEach(viewStore.profiles) { profile in
                    Button {
                      viewStore.send(.presentProfile(
                        isPresented: true,
                        profile: profile
                      ))
                    } label: {
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
          
          WithViewStore(store.scope(state: \.isProfilePresented)) { viewStore in
            NavigationLink(
              destination: IfLetStore(
                store.scope(
                  state: \.profileState,
                  action: ExploreAction.profile
                ),
                then: { store in
                  ProfileView(store: store)
                }
              ),
              isActive: viewStore.binding(
                send: .presentProfile(
                  isPresented: false,
                  profile: nil
                )
              ),
              label: EmptyView.init
            )
          }
        }
      }
      .navigationViewStyle(StackNavigationViewStyle())
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

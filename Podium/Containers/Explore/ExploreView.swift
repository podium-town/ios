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
                  if viewStore.searchQuery.count > 0 {
                    HStack {
                      Text("🤗 Profiles")
                        .fontWeight(.medium)
                        .padding(.top, 18)
                      
                      Spacer()
                    }
                    
                    ForEach(viewStore.foundProfiles) { profile in
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
                  } else {
                    RoundedRectangle(cornerRadius: 15)
                      .frame(height: 160)
                      .overlay(
                        ZStack {
                          Image("welcome")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 160)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                          
                          Text("#welcome")
                            .fontWeight(.semibold)
                        }
                      )
                    
                    Text("🌎 Trends")
                      .fontWeight(.medium)
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
                    
                    Button {
                      
                    } label: {
                      HStack {
                        Text("💪 Active votings")
                          .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("How does it work ?")
                          .fontWeight(.medium)
                          .foregroundColor(.gray)
                      }
                    }
                    .padding(.top, 18)
                    
                    VStack {
                      HStack {
                        Text("Ban profile @bot123")
                          .fontWeight(.medium)
                        Spacer()
                        HStack {
                          Circle()
                            .foregroundColor(.green)
                            .frame(width: 12, height: 12)
                          Text("94%")
                          Circle()
                            .foregroundColor(.red)
                            .frame(width: 12, height: 12)
                          Text("6%")
                        }
                      }
                      .padding()
                      .background(Color("ColorLightBackground"))
                      .clipShape(RoundedRectangle(cornerRadius: 15))
                      
                      HStack {
                        Text("Usernames min. length 2")
                          .fontWeight(.medium)
                        Spacer()
                        HStack {
                          Circle()
                            .foregroundColor(.green)
                            .frame(width: 12, height: 12)
                          Text("14%")
                          Circle()
                            .foregroundColor(.red)
                            .frame(width: 12, height: 12)
                          Text("86%")
                        }
                      }
                      .padding()
                      .background(Color("ColorLightBackground"))
                      .clipShape(RoundedRectangle(cornerRadius: 15))
                      
                      HStack {
                        Text("180 characters limit")
                          .fontWeight(.medium)
                        Spacer()
                        HStack {
                          Circle()
                            .foregroundColor(.green)
                            .frame(width: 12, height: 12)
                          Text("70%")
                          Circle()
                            .foregroundColor(.red)
                            .frame(width: 12, height: 12)
                          Text("30%")
                        }
                      }
                      .padding()
                      .background(Color("ColorLightBackground"))
                      .clipShape(RoundedRectangle(cornerRadius: 15))
                      
                      HStack {
                        Text("Add banned words")
                          .fontWeight(.medium)
                        Spacer()
                        HStack {
                          Circle()
                            .foregroundColor(.green)
                            .frame(width: 12, height: 12)
                          Text("58%")
                          Circle()
                            .foregroundColor(.red)
                            .frame(width: 12, height: 12)
                          Text("42%")
                        }
                      }
                      .padding()
                      .background(Color("ColorLightBackground"))
                      .clipShape(RoundedRectangle(cornerRadius: 15))
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
        foundProfiles: [Mocks.profile]
      ),
      reducer: exploreReducer,
      environment: AppEnvironment()
    ))
  }
}

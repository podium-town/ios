//
//  HomeView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
  let store: StoreOf<Home>
  
  var body: some View {
    NavigationView {
      ZStack {
        WithViewStore(store) { viewStore in
          VStack(spacing: 0) {
            if viewStore.isEmpty {
              VStack {
                Spacer()
                Text("👋 Follow some people to get you started.")
                  .fontWeight(.medium)
                  .padding()
                Spacer()
              }
            } else {
              List {
                ForEach(viewStore.posts) { post in
                  Button {
                    viewStore.send(.presentThread(
                      isPresented: true,
                      post: post
                    ))
                  } label: {
                    Post(
                      isSelf: viewStore.profile.id == post.post.ownerId,
                      post: post,
                      onDelete: { post in
                        viewStore.send(.deletePost(post: post))
                      },
                      onReport: { post in
                        viewStore.send(.reportPost(post: post))
                      },
                      onBlockProfile: { post in
                        viewStore.send(.blockProfile(profile: post.profile))
                      },
                      onBlockPost: { post in
                        viewStore.send(.blockPost(post: post))
                      },
                      onProfile: { profile in
                        viewStore.send(.presentProfile(
                          isPresented: true,
                          profile: profile
                        ))
                      },
                      onImage: { post, loadedImages in
                        viewStore.send(.presentMedia(
                          isPresented: true,
                          post: post,
                          loadedImages: loadedImages
                        ))
                      },
                      onMenuTap: {
                        viewStore.send(.onMenuOpen)
                      }
                    )
                  }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
              }
              .listStyle(.plain)
              .refreshable {
#if targetEnvironment(simulator)
                
#else
                await viewStore.send(.getPosts, while: \.isLoadingRefreshable)
#endif
              }
              .sheet(isPresented: viewStore.binding(
                get: \.isMediaPresented,
                send: HomeAction.presentMedia(
                  isPresented: false,
                  post: nil,
                  loadedImages: nil
                ))) {
                  IfLetStore(
                    store.scope(
                      state: \.mediaState,
                      action: HomeAction.media
                    ),
                    then: MediaView.init(store:)
                  )
                }
            }
            
            VStack(spacing: 0) {
              Divider()
                .overlay(Color("ColorSeparator"))
              
              ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack(spacing: 4) {
                    if viewStore.isStoriesLoading {
                      StoryAvatar(
                        profile: viewStore.profile,
                        isAddVisible: true,
                        hasNew: false
                      )
                      .opacity(0.5)
                      .overlay(
                        ProgressView()
                      )
                    } else {
                      ForEach(viewStore.profiles) { profile in
                        Button {
                          viewStore.send(.presentStories(
                            isPresented: true,
                            profileId: profile.id
                          ))
                        } label: {
                          StoryAvatar(
                            profile: profile,
                            isAddVisible: profile.id == viewStore.profile.id,
                            hasNew: profile.hasNewStories ?? false
                          )
                          
                        }
                      }
                    }
                  }
                  .padding(.horizontal)
                  .animation(.default)
                }
                .padding(.top, 16)
                .padding(.bottom, 18)
                
                HStack {
                  Spacer()
                  Button {
                    viewStore.send(.presentAdd(isPresented: true))
                  } label: {
                    Image("add")
                      .resizable()
                      .frame(width: 32, height: 32)
                      .padding(20)
                      .background(Color.accentColor)
                  }
                  .foregroundColor(Color("ColorTextInverted"))
                  .clipShape(Circle())
                  .padding(.trailing)
                  .shadow(radius: 5)
                  .fullScreenCover(isPresented: viewStore.binding(
                    get: \.isAddPresented,
                    send: HomeAction.presentAdd
                  )) {
                    IfLetStore(
                      store.scope(
                        state: \.add,
                        action: HomeAction.add
                      ),
                      then: AddView.init(store:)
                    )
                  }
                }
              }
            }
            .sheet(isPresented: viewStore.binding(
              get: \.isStoriesPresented,
              send: HomeAction.presentStories(
                isPresented: false,
                profileId: nil
              )
            )) {
              IfLetStore(
                store.scope(
                  state: \.storiesState,
                  action: HomeAction.stories
                ),
                then: StoriesView.init(store:)
              )
            }
          }
          .navigationBarTitleDisplayMode(.inline)
          .navigationBarHidden(true)
          .banner(data: viewStore.binding(
            get: \.bannerData,
            send: HomeAction.dismissBanner
          ))
        }
        
        WithViewStore(store.scope(state: \.isThreadPresented)) { viewStore in
          NavigationLink(
            destination: IfLetStore(
              store.scope(
                state: \.threadState,
                action: HomeAction.thread
              ),
              then: { store in
                ThreadView(store: store)
              }
            ),
            isActive: viewStore.binding(
              send: .presentThread(
                isPresented: false,
                post: nil
              )
            ),
            label: EmptyView.init
          )
        }
        
        WithViewStore(store.scope(state: \.isProfilePresented)) { viewStore in
          NavigationLink(
            destination: IfLetStore(
              store.scope(
                state: \.profileState,
                action: HomeAction.profile
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
      .padding(.top, 1)
    }
    .navigationViewStyle(StackNavigationViewStyle())
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(store: Store(
      initialState: HomeState(
        profile: Mocks.profile,
        isEmpty: false,
        stories: [
          "456": [Mocks.storyProfile]
        ],
        profiles: [
          Mocks.profile,
          Mocks.profile
        ]
      ),
      reducer: Home()
    ))
  }
}

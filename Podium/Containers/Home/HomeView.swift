//
//  HomeView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct HomeView: View {
  let store: Store<HomeState, HomeAction>
  
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
                      isSelf: viewStore.profile.id == post.ownerId,
                      post: post,
                      profile: viewStore.profiles[post.ownerId],
                      onDelete: { post in
                        viewStore.send(.deletePost(post: post))
                      },
                      onReport: { post in
                        viewStore.send(.reportPost(post: post))
                      },
                      onProfile: { profile in
                        viewStore.send(.presentProfile(
                          isPresented: true,
                          profile: profile
                        ))
                      },
                      onImage: { post in
                        viewStore.send(.presentMedia(
                          isPresented: true,
                          post: post
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
            }
            
            VStack(spacing: 0) {
              Divider()
                .overlay(Color("ColorSeparator"))
              
              ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack {
                    if viewStore.stories.isEmpty {
                      StoryAvatar(
                        profile: viewStore.profile,
                        isAddVisible: true
                      )
                      .opacity(0.5)
                      .overlay(
                        ProgressView()
                      )
                    } else {
                      Button {
                        viewStore.send(.presentStories(
                          isPresented: true,
                          profile: viewStore.profile
                        ))
                      } label: {
                        StoryAvatar(
                          profile: viewStore.profile,
                          isAddVisible: true
                        )
                      }
                      ForEach(Array(viewStore.stories), id: \.key) { id, posts in
                        if id != viewStore.profile.id {
                          Button {
                            viewStore.send(.presentStories(
                              isPresented: true,
                              profile: viewStore.profiles[id]
                            ))
                          } label: {
                            StoryAvatar(
                              profile: viewStore.profiles[id]!,
                              isAddVisible: id == viewStore.profile.id
                            )
                          }
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
                profile: nil
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
          .sheet(isPresented: viewStore.binding(
            get: \.isMediaPresented,
            send: HomeAction.presentMedia(
              isPresented: false,
              post: nil
            ))) {
              IfLetStore(
                store.scope(
                  state: \.mediaState,
                  action: HomeAction.media
                ),
                then: MediaView.init(store:)
              )
            }
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
              )),
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
        posts: [Mocks.post, Mocks.post]
      ),
      reducer: homeReducer,
      environment: AppEnvironment()
    ))
  }
}

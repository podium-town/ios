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
    WithViewStore(store) { viewStore in
      NavigationView {
        ZStack {
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
                      profile: viewStore.profiles[post.ownerId]!,
                      post: post
                    ))
                  } label: {
                    Post(
                      profile: viewStore.profiles[post.ownerId]!,
                      post: post,
                      onDelete: { post in
                        viewStore.send(.deletePost(id: post.id))
                      },
                      onProfile: { profile in
                        viewStore.send(.presentProfile(
                          isPresented: true,
                          profile: profile
                        ))
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
            
            Spacer()
            
            VStack(spacing: 0) {
              Divider()
                .overlay(Color("ColorSeparator"))
              
              ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                  HStack {
                    Button {
                      
                    } label: {
                      StoryAvatar(isAddVisible: true)
                    }
                    
                    Button {
                      viewStore.send(.presentStories(isPresented: true))
                    } label: {
                      StoryAvatar()
                    }
                    
                    Button {
                      viewStore.send(.presentStories(isPresented: true))
                    } label: {
                      StoryAvatar()
                    }
                    
                    Button {
                      viewStore.send(.presentStories(isPresented: true))
                    } label: {
                      StoryAvatar()
                    }
                    
                    Button {
                      viewStore.send(.presentStories(isPresented: true))
                    } label: {
                      StoryAvatar()
                    }
                    
                    Button {
                      viewStore.send(.presentStories(isPresented: true))
                    } label: {
                      StoryAvatar()
                    }
                  }
                  .padding(.horizontal)
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
                  .foregroundColor(Color.white)
                  .clipShape(Circle())
                  .padding(.trailing)
                  .shadow(radius: 5)
                  .sheet(isPresented: viewStore.binding(
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
              send: HomeAction.presentStories
            )) {
              IfLetStore(
                store.scope(
                  state: \.stories,
                  action: HomeAction.stories
                ),
                then: StoriesView.init(store:)
              )
            }
          }
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
              Text("")
            }
          }
          .onAppear {
#if targetEnvironment(simulator)
            
#else
            viewStore.send(.initialize)
#endif
          }
          
          // Workaround for multiple NavigationLinks
          // https://github.com/pointfreeco/swift-composable-architecture/issues/393
          NavigationLink(destination: EmptyView()) {
            EmptyView()
          }
          
          WithViewStore(store.scope(state: \.isThreadPresented)) { viewStore in
            NavigationLink(
              destination: IfLetStore(
                store.scope(
                  state: \.thread,
                  action: HomeAction.thread
                ),
                then: { store in
                  ThreadView(store: store)
                }
              ),
              isActive: viewStore.binding(send: .presentThread(
                isPresented: false,
                profile: nil,
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
      }
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView(store: Store(
      initialState: HomeState(
        profile: Mocks.profile,
        isEmpty: false
      ),
      reducer: homeReducer,
      environment: AppEnvironment()
    ))
  }
}

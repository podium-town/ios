//
//  HashtagView.swift
//  Podium
//
//  Created by Michael Jach on 02/12/2022.
//

import SwiftUI
import ComposableArchitecture

struct HashtagView: View {
  let store: StoreOf<Hashtag>
  
  var body: some View {
    ZStack {
      WithViewStore(store) { viewStore in
        VStack {
          if viewStore.isLoading {
            HStack {
              Spacer()
              ProgressView()
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
            .navigationTitle(viewStore.hashtag)
            .listStyle(.plain)
            .refreshable {
#if targetEnvironment(simulator)
              
#else
              await viewStore.send(.getPosts, while: \.isLoadingRefreshable)
#endif
            }
            .sheet(isPresented: viewStore.binding(
              get: \.isMediaPresented,
              send: HashtagAction.presentMedia(
                isPresented: false,
                post: nil,
                loadedImages: nil
              ))) {
                IfLetStore(
                  store.scope(
                    state: \.mediaState,
                    action: HashtagAction.media
                  ),
                  then: MediaView.init(store:)
                )
              }
          }
        }
        .onAppear {
          viewStore.send(.getPosts)
        }
      }
      
      WithViewStore(store.scope(state: \.isProfilePresented)) { viewStore in
        NavigationLink(
          destination: IfLetStore(
            store.scope(
              state: \.profileState,
              action: HashtagAction.profile
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
      
      WithViewStore(store.scope(state: \.isThreadPresented)) { viewStore in
        NavigationLink(
          destination: IfLetStore(
            store.scope(
              state: \.threadState,
              action: HashtagAction.thread
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
    }
  }
}

struct HashtagView_Previews: PreviewProvider {
  static var previews: some View {
    HashtagView(store: Store(
      initialState: HashtagState(
        profile: Mocks.profile,
        hashtag: "#hash"
      ),
      reducer: Hashtag()
    ))
  }
}

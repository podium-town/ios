//
//  ProfileView.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
  let store: Store<ProfileState, ProfileAction>
  
  @State private var tab = 0
  
  var body: some View {
    ZStack {
      WithViewStore(store) { viewStore in
        VStack(alignment: .leading, spacing: 0) {
          HStack(spacing: 12) {
            Button {
              if viewStore.fromProfile.id == viewStore.profile.id {
                viewStore.send(.presentPicker(isPresented: true))
              }
            } label: {
              Image(uiImage: viewStore.profile.avatarData == nil ? UIImage(named: "avatar")! : UIImage(data: viewStore.profile.avatarData!)!)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            }
            .sheet(isPresented: viewStore.binding(
              get: \.isPickerPresented,
              send: ProfileAction.presentPicker(isPresented:)
            )) {
              ImagePicker(
                sourceType: .photoLibrary
              ) { image in
                viewStore.send(.changeAvatar(image))
              }
            }
            
            Text(viewStore.profile.username ?? viewStore.profile.id)
              .font(.title2)
              .fontWeight(.semibold)
              .lineLimit(1)
            
            Spacer()
            
            HStack {
              if viewStore.fromProfile.id == viewStore.profile.id {
                Button {
                  viewStore.send(.presentSettings(isPresented: true))
                } label: {
                  Image("settings")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color("ColorText"))
                }
              } else {
                Button {
                  if viewStore.fromProfile.following.contains(viewStore.profile.id) {
                    viewStore.send(.unfollow)
                  } else {
                    viewStore.send(.follow)
                  }
                } label: {
                  Text(viewStore.fromProfile.following.contains(viewStore.profile.id) ? "Unfollow" : "Follow")
                    .fontWeight(.semibold)
                    .foregroundColor(Color("ColorTextInverted"))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(
                      RoundedRectangle(cornerRadius: 23)
                    )
                }
                .disabled(viewStore.isPendingFollowing)
                .opacity(viewStore.isPendingFollowing ? 0.5 : 1)
              }
            }
          }
          .padding(24)
          
          VStack {
            Picker("Filter entries", selection: $tab) {
              Text("Latest").tag(0)
              Text("Media").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .padding(.bottom, 0)
            
            if viewStore.isEmpty {
              VStack {
                Spacer()
                HStack {
                  Spacer()
                  Text("No posts.")
                    .fontWeight(.medium)
                    .padding()
                  Spacer()
                }
                Spacer()
              }
            } else if viewStore.isLoading {
              VStack {
                Spacer()
                HStack {
                  Spacer()
                  ProgressView()
                  Spacer()
                }
                Spacer()
              }
            } else {
              List {
                ForEach(filterData(posts: viewStore.posts)) { post in
                  Button {
                    viewStore.send(.presentThread(
                      isPresented: true,
                      post: post
                    ))
                  } label: {
                    Post(
                      isSelf: viewStore.fromProfile.id == post.post.ownerId,
                      post: post,
                      onDelete: { post in
                        viewStore.send(.deletePost(post: post))
                      },
                      onReport: { post in
                        viewStore.send(.reportPost(post: post))
                      },
                      onProfile: { profile in
                        
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
            }
          }
        }
        .sheet(isPresented: viewStore.binding(
          get: \.isMediaPresented,
          send: ProfileAction.presentMedia(
            isPresented: false,
            post: nil,
            loadedImages: nil
          ))) {
            IfLetStore(
              store.scope(
                state: \.mediaState,
                action: ProfileAction.media
              ),
              then: MediaView.init(store:)
            )
          }
        .onAppear {
          if !viewStore.isSelf {
            viewStore.send(.getPosts)
          }
        }
        .padding(.bottom, 18)
        .banner(data: viewStore.binding(
          get: \.bannerData,
          send: ProfileAction.dismissBanner
        ))
      }
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle("Profile")
      
      WithViewStore(store.scope(state: \.isSettingsPresented)) { viewStore in
        NavigationLink(
          destination: IfLetStore(
            store.scope(
              state: \.settingsState,
              action: ProfileAction.settings
            ),
            then: { store in
              SettingsView(store: store)
            }
          ),
          isActive: viewStore.binding(
            send: .presentSettings(isPresented: false)
          ),
          label: EmptyView.init
        )
      }
      
      WithViewStore(store.scope(state: \.isThreadPresented)) { viewStore in
        NavigationLink(
          destination: IfLetStore(
            store.scope(
              state: \.threadState,
              action: ProfileAction.thread
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
  
  func filterData(posts: [PostProfileModel]?) -> [PostProfileModel] {
    switch tab {
    case 0:
      return posts ?? []
      
    case 1:
      return posts?.filter({ !$0.post.images.isEmpty }) ?? []
      
    default:
      return []
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(store: Store(
      initialState: ProfileState(
        fromProfile: Mocks.profile,
        profile: Mocks.profile2,
        posts: [Mocks.postProfile]
      ),
      reducer: profileReducer,
      environment: AppEnvironment()
    ))
  }
}

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
          HStack(spacing: 18) {
            Button {
              if viewStore.isSelf {
                viewStore.send(.presentPicker(isPresented: true))
              }
            } label: {
              Image(uiImage: viewStore.profile.avatarData == nil ? UIImage(named: "avatar")! : UIImage(data: viewStore.profile.avatarData!)!)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
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
            
            Spacer()
            
            if viewStore.isSelf {
              Button {
                viewStore.send(.presentSettings(isPresented: true))
              } label: {
                Image("settings")
                  .resizable()
                  .frame(width: 24, height: 24)
                  .foregroundColor(Color("ColorText"))
              }
            }
          }
          .padding(24)
          
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
          } else {
            switch tab {
            case 0:
              List {
                ForEach(viewStore.posts) { post in
                  Button {
                    viewStore.send(.presentThread(
                      isPresented: true,
                      post: post
                    ))
                  } label: {
                    Post(
                      post: post,
                      onImage: { post in
                        viewStore.send(.presentMedia(
                          isPresented: true,
                          post: post
                        ))
                      })
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
              
            case 1:
              List {
                ForEach(viewStore.posts.filter({ !$0.images.isEmpty })) { post in
                  Button {
                    
                  } label: {
                    Post(
                      post: post
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
              
            default:
              Text("No data")
            }
          }
        }
        .sheet(isPresented: viewStore.binding(
          get: \.isMediaPresented,
          send: ProfileAction.presentMedia(
            isPresented: false,
            post: nil
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
          viewStore.send(.getPosts)
        }
      }
      
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
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(store: Store(
      initialState: ProfileState(
        profile: Mocks.profile,
        posts: [Mocks.post]
      ),
      reducer: profileReducer,
      environment: AppEnvironment()
    ))
  }
}

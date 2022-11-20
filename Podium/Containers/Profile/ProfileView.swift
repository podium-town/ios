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
    WithViewStore(store) { viewStore in
      VStack(alignment: .leading, spacing: 0) {
        HStack(spacing: 18) {
          Button {
            viewStore.send(.presentPicker(isPresented: true))
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
          List {
            ForEach(viewStore.posts) { post in
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
        }
      }
      .onAppear {
        viewStore.send(.getPosts)
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

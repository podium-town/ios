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
          Image(uiImage: viewStore.profile.avatar?.base64ToImage() ?? UIImage(named: "avatar")!)
            .resizable()
            .frame(width: 100, height: 100)
            .clipShape(Circle())
          
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
        
        List {
          ForEach(viewStore.posts) { post in
            Button {
              
            } label: {
              Post(
                post: post,
                profile: viewStore.profile,
                onDelete: { post in
                  
                }
              )
            }
          }
          .listRowSeparator(.hidden)
          .listRowInsets(EdgeInsets())
        }
        .listStyle(.plain)
        .refreshable {
          
        }
        
        Spacer()
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

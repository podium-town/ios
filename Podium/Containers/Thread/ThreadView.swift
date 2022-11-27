//
//  ThreadView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture
import FirebaseFirestore

struct ThreadView: View {
  let store: Store<ThreadState, ThreadAction>
  
  @State private var isMenuOpen: Bool = false
  @State private var listener: ListenerRegistration?
  
  var body: some View {
    WithViewStore(store) { viewStore in
      if let profile = viewStore.profile {
        VStack {
          ScrollView {
            VStack(spacing: 0) {
              if let post = viewStore.post {
                ThreadPost(
                  post: post,
                  profile: profile,
                  onDelete: { post in
                    
                  },
                  onProfile: { profile in
                    
                  },
                  onImage: { post in
                    viewStore.send(.presentMedia(
                      isPresented: true,
                      post: post
                    ))
                  }
                )
                
                if viewStore.isLoading {
                  VStack(alignment: .center) {
                    ProgressView()
                  }
                } else {
                  ForEach(viewStore.comments) { comment in
                    Post(
                      isSelf: viewStore.fromProfile.id == comment.ownerId,
                      post: comment,
                      profile: viewStore.profiles[comment.ownerId],
                      onDelete: { comment in
                        viewStore.send(.deleteComment(comment: comment))
                      },
                      onReport: { comment in
                        viewStore.send(.reportComment(comment: comment))
                      },
                      onProfile: { profile in
                        
                      },
                      onImage: { post in
                        viewStore.send(.presentMedia(
                          isPresented: true,
                          post: post
                        ))
                      },
                      onMenuTap: {
                        viewStore.send(.openMenu)
                      }
                    )
                  }
                }
              }
            }
          }
          
          HStack {
            TextField("Reply...", text: viewStore.binding(
              get: \.text,
              send: ThreadAction.textChanged
            ))
            .padding()
            .background(
              RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color("ColorLightBackground"))
            )
            
            Button {
              self.endTextEditing()
              viewStore.send(.send)
            } label: {
              Text("Send")
                .fontWeight(.semibold)
            }
            .disabled(viewStore.isSendDisabled)
          }
          .padding()
        }
        .onAppear {
          listener = API.listenComments(post: viewStore.post) { comments in
            viewStore.send(.addComments(comments: comments))
          }
        }
        .onDisappear {
          listener?.remove()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .navigationBarTrailing) {
            Menu {
              if viewStore.post.ownerId == viewStore.fromProfile.id {
                Button("Delete post") {
                  viewStore.send(.deletePost(post: viewStore.post))
                }
              }
              Button("Report post") {
                viewStore.send(.reportPost(post: viewStore.post))
              }
            } label: {
              Image("more")
                .resizable()
                .frame(width: 18, height: 18)
                .scaledToFill()
            }
            .onTapGesture {
              viewStore.send(.openMenu)
            }
          }
        }
        .sheet(isPresented: viewStore.binding(
          get: \.isMediaPresented,
          send: ThreadAction.presentMedia(
            isPresented: false,
            post: nil
          ))) {
            IfLetStore(
              store.scope(
                state: \.mediaState,
                action: ThreadAction.media
              ),
              then: MediaView.init(store:)
            )
          }
      }
    }
  }
}

struct ThreadView_Previews: PreviewProvider {
  static var previews: some View {
    ThreadView(store: Store(
      initialState: ThreadState(
        fromProfile: Mocks.profile,
        profile: Mocks.profile,
        profiles: [:],
        post: Mocks.post,
        comments: [
          Mocks.comment,
          Mocks.comment
        ]
      ),
      reducer: threadReducer,
      environment: AppEnvironment()
    ))
  }
}

//
//  ThreadView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct ThreadView: View {
  let store: Store<ThreadState, ThreadAction>
  
  @State private var isMenuOpen: Bool = false
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        ScrollView {
          VStack(spacing: 0) {
            if let post = viewStore.post {
              ThreadPost(
                post: post,
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
                    isSelf: viewStore.profile.id == comment.ownerId,
                    post: comment,
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
        Task {
          do {
            viewStore.send(.attachListener)
            try await API.listenComments(post: viewStore.post) { comments in
              viewStore.send(.addComments(comments: comments))
            }
          }
        }
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Menu {
            if viewStore.post.ownerId == viewStore.profile.id {
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

struct ThreadView_Previews: PreviewProvider {
  static var previews: some View {
    ThreadView(store: Store(
      initialState: ThreadState(
        profile: Mocks.profile,
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

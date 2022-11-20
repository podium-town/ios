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
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        ScrollView {
          if let post = viewStore.post {
            ThreadPost(
              post: post,
              onDelete: { post in
                
              },
              onProfile: { profile in
                
              }
            )
            
            VStack(spacing: 0) {
              ForEach(viewStore.comments) { comment in
                Post(
                  post: comment
                )
              }
            }
          }
        }
        
        HStack {
          TextField("Comment...", text: viewStore.binding(
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
        viewStore.send(.getComments)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Image("more")
            .resizable()
            .frame(width: 18, height: 18)
            .scaledToFill()
        }
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
        comments: [Mocks.comment, Mocks.comment]
      ),
      reducer: threadReducer,
      environment: AppEnvironment()
    ))
  }
}

//
//  AddView.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct AddView: View {
  let store: Store<AddState, AddAction>
  
  @FocusState private var isTextFocused: Bool
  
  init(store: Store<AddState, AddAction>) {
    self.store = store
    UITextView.appearance().backgroundColor = .clear
  }
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        Color("ColorBackground")
          .ignoresSafeArea()
        
        VStack {
          if #available(iOS 16.0, *) {
            TextEditor(text: viewStore.binding(
              get: \.text,
              send: AddAction.textChanged
            ))
            .scrollContentBackground(.hidden)
            .background(Color("ColorBackground"))
            .font(.largeTitle)
            .padding()
            .padding(.top, 22)
            .focused($isTextFocused)
          } else {
            TextEditor(text: viewStore.binding(
              get: \.text,
              send: AddAction.textChanged
            ))
            .background(Color("ColorBackground"))
            .font(.largeTitle)
            .padding()
            .padding(.top, 22)
            .focused($isTextFocused)
          }
          
          Button {
            viewStore.send(.addPost)
          } label: {
            HStack {
              Spacer()
              Text("Send")
              Spacer()
            }
          }
          .buttonStyle(PodiumButton())
          .disabled(viewStore.isSendPending || viewStore.isSendDisabled)
          .opacity(viewStore.isSendPending || viewStore.isSendDisabled ? 0.5 : 1)
          .padding()
          .padding(.top, 4)
        }
        .onAppear {
          isTextFocused = true
        }
        .background(Color("ColorBackground"))
      }
    }
  }
}

struct AddView_Previews: PreviewProvider {
  static var previews: some View {
    AddView(store: Store(
      initialState: AddState(
        profile: Mocks.profile
      ),
      reducer: addReducer,
      environment: AppEnvironment()
    ))
  }
}

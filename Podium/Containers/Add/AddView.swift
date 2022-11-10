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
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        TextEditor(text: viewStore.binding(
          get: \.text,
          send: AddAction.textChanged
        ))
        .font(.largeTitle)
        .padding()
        .padding(.top, 22)
        .focused($isTextFocused)
        
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
        .disabled(viewStore.isSendPending)
        .padding()
      }
      .onAppear {
        isTextFocused = true
      }
      .background(Color("ColorBackground"))
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

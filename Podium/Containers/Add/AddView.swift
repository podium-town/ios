//
//  AddView.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import SwiftUI
import ComposableArchitecture
import Introspect

struct AddView: View {
  let store: Store<AddState, AddAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      NavigationView {
        VStack(spacing: 0) {
          HStack {
            Spacer()
            Button {
              viewStore.send(.dismiss)
            } label: {
              Image("close")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(Color("ColorText"))
            }
          }
          .padding()
          
          TextEditor(text: viewStore.binding(
            get: \.text,
            send: AddAction.textChanged
          ))
          .font(.title)
          .padding(.horizontal)
          .introspectTextView { textField in
            textField.becomeFirstResponder()
          }
          
          HStack {
            ForEach(viewStore.images, id: \.self) { image in
              RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color("ColorLightBackground"))
                .overlay(
                  Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                )
                .frame(height: 140)
                .clipped()
            }
          }
          .padding()
          .padding(.bottom, 0)
          
          HStack {
            Button {
              viewStore.send(.presentPicker(isPresented: true))
            } label: {
              Image("media")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(Color("ColorText"))
            }
            .buttonStyle(PodiumButtonSecondary())
            .disabled(viewStore.images.count > 3)
            .opacity(viewStore.images.count > 3 ? 0.5 : 1)
            .sheet(isPresented: viewStore.binding(
              get: \.isPickerPresented,
              send: AddAction.presentPicker(isPresented:)
            )) {
              ImagePicker(
                sourceType: .photoLibrary
              ) { image in
                viewStore.send(.addImage(image))
              }
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
          }
          .padding()
          .padding(.top, 0)
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
        profile: Mocks.profile,
        images: [
          UIImage(named: "avatar")!,
          UIImage(named: "avatar")!,
          UIImage(named: "avatar")!
        ]
      ),
      reducer: addReducer,
      environment: AppEnvironment()
    ))
  }
}

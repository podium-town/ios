//
//  SettingsView.swift
//  Podium
//
//  Created by Michael Jach on 20/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
  let store: StoreOf<Settings>
  
  @State private var isPresentingConfirm: Bool = false
  
  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        Section(header: Text("Settings")) {
          Button {

          } label: {
            HStack {
              Text("Username")
              
              Spacer()
              
              Text("@\(viewStore.profile.username ?? "")")
                .fontWeight(.semibold)
            }
          }
          Button {
            viewStore.send(.logout)
          } label: {
            Text("Logout")
              .foregroundColor(.red)
          }
        }
        
        Section(header: Text("Information"), footer: HStack {
          Spacer()
          Image("logo")
            .resizable()
            .frame(width: 42, height: 42)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .padding(.top, 8)
          Spacer()
        }) {
          Button {
            viewStore.send(.viewPrivacy)
          } label: {
            Text("Privacy policy")
          }
          
          Button {
            viewStore.send(.viewTerms)
          } label: {
            Text("Terms of service")
          }
          
          Button {
            isPresentingConfirm = true
          } label: {
            Text("Delete account")
              .foregroundColor(.red)
          }
          .confirmationDialog("Account deletion is permanent",
                              isPresented: $isPresentingConfirm) {
            Button("Delete my account", role: .destructive) {
              viewStore.send(.deleteAccount)
            }
          } message: {
            Text("Account deletion is permanent")
          }

        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Settings")
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(store: Store(
      initialState: SettingsState(
        profile: Mocks.profile
      ),
      reducer: Settings()
    ))
  }
}

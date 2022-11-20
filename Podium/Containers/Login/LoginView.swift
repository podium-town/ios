//
//  LoginView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
  let store: Store<LoginState, LoginAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        VStack(alignment: .leading) {
          Text("Podium")
            .font(.largeTitle.bold())
          
          Text("Join the future of social media.")
            .font(.title2)
          
          Divider()
            .padding(.vertical, 22)
          
          if viewStore.verificationId != nil {
            Text("Enter Verification Code you just recieved")
            
            VStack(alignment: .leading) {
              TextField("", text: viewStore.binding(
                get: \.verificationCode,
                send: LoginAction.verificationCodeChanged
              ))
              .textFieldStyle(PodiumTextFieldStyle(isEditing: true))
              .keyboardType(.numberPad)
              
              Button {
                viewStore.send(.resend)
              } label: {
                Text("Resend")
              }
            }
            
            Button {
              viewStore.send(.signIn)
            } label: {
              HStack {
                Spacer()
                HStack(spacing: 8) {
                  if viewStore.isVerificationPending {
                    ProgressView()
                  }
                  Text("Enter Podium !")
                }
                Spacer()
              }
            }
            .disabled(viewStore.isVerificationPending)
            .buttonStyle(PodiumButton())
            .onAppear {
              self.endTextEditing()
            }
          } else if viewStore.verificationId == nil && !viewStore.isUsernameSelectionVisible {
            VStack(alignment: .leading, spacing: 8) {
              Text("Phone number")
                .foregroundColor(.gray)
                .font(.body.weight(.medium))
              
              iPhoneNumberField(text: viewStore.binding(
                get: \.phoneNumber,
                send: LoginAction.phoneNumberChanged
              ), formatted: true)
              .flagHidden(false)
              .prefixHidden(false)
              .flagSelectable(true)
              .padding()
              .background(
                RoundedRectangle(cornerRadius: 16)
                  .strokeBorder(
                    LinearGradient(
                      gradient: .init(
                        colors: [
                          Color("ColorGradient1"),
                          Color("ColorGradient2")
                        ]
                      ),
                      startPoint: .topLeading,
                      endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                  )
              )
            }
            .onAppear {
              self.endTextEditing()
            }
            
            Button {
              viewStore.send(.verifyPhone)
            } label: {
              HStack {
                Spacer()
                HStack(spacing: 8) {
                  if viewStore.isVerificationPending {
                    ProgressView()
                  }
                  Text("Sign in")
                }
                Spacer()
              }
            }
            .disabled(viewStore.isVerificationPending)
            .buttonStyle(PodiumButton())
          }
          
          if viewStore.isUsernameSelectionVisible {
            VStack {
              Text("Enter your desired username")
              
              CustomTextField("", text: viewStore.binding(
                get: \.username,
                send: LoginAction.usernameChanged
              ))
              
              Button {
                viewStore.send(.setUsername)
              } label: {
                HStack {
                  Spacer()
                  HStack(spacing: 8) {
                    if viewStore.isVerificationPending {
                      ProgressView()
                    }
                    Text("Set username")
                  }
                  Spacer()
                }
              }
              .disabled(viewStore.isVerificationPending)
              .buttonStyle(PodiumButton())
            }
          }
          
          Divider()
            .padding(.top, 22)
          
          Text("By signing in you accept Terms of Service and Privacy Policy.")
            .foregroundColor(.gray)
            .font(.caption)
        }
        .padding()
      }
      .banner(data: viewStore.binding(
        get: \.bannerData,
        send: LoginAction.dismissBanner
      ))
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(store: Store(
      initialState: LoginState(),
      reducer: loginReducer,
      environment: AppEnvironment()
    ))
  }
}

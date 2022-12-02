//
//  LoginView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct LoginView: View {
  let store: StoreOf<Login>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ScrollView {
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
              self.endTextEditing()
              viewStore.send(.signIn)
            } label: {
              HStack {
                Spacer()
                HStack(spacing: 8) {
                  if viewStore.isVerificationPending {
                    ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                  }
                  Text("Enter Podium !")
                }
                Spacer()
              }
            }
            .opacity(viewStore.isVerificationPending ? 0.5 : 1)
            .disabled(viewStore.isVerificationPending)
            .buttonStyle(PodiumButtonSignIn())
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
              .foregroundColor(Color.white)
              .accentColor(Color.white)
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
            
            Button {
              self.endTextEditing()
              viewStore.send(.verifyPhone)
            } label: {
              HStack {
                Spacer()
                HStack(spacing: 8) {
                  if viewStore.isVerificationPending {
                    ProgressView()
                      .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                  }
                  Text("Sign in")
                }
                Spacer()
              }
            }
            .opacity(viewStore.isVerificationPending ? 0.5 : 1)
            .disabled(viewStore.isVerificationPending)
            .buttonStyle(PodiumButtonSignIn())
          }
          
          if viewStore.isUsernameSelectionVisible {
            VStack {
              Text("Enter your desired username")
              
              CustomTextField("", text: viewStore.binding(
                get: \.username,
                send: LoginAction.usernameChanged
              ))
              
              Button {
                self.endTextEditing()
                viewStore.send(.setUsername)
              } label: {
                HStack {
                  Spacer()
                  HStack(spacing: 8) {
                    if viewStore.isVerificationPending {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    }
                    Text("Set username")
                  }
                  Spacer()
                }
              }
              .opacity(viewStore.isVerificationPending || !viewStore.isUsernameValidated ? 0.5 : 1)
              .disabled(viewStore.isVerificationPending || !viewStore.isUsernameValidated)
              .buttonStyle(PodiumButtonSignIn())
            }
          }
          
          Divider()
            .padding(.top, 22)
          
          Button {
            viewStore.send(.viewTerms)
          } label: {
            Group {
              Text("By signing in you accept ")
                .foregroundColor(.gray)
                .font(.caption) +
              Text("Terms of Service and Privacy Policy")
                .foregroundColor(.white)
                .font(.caption) +
              Text(".")
                .foregroundColor(.gray)
                .font(.caption)
            }
          }
        }
        .banner(data: viewStore.binding(
          get: \.bannerData,
          send: LoginAction.dismissBanner
        ))
        .padding()
        .padding(.top, 220)
        .foregroundColor(.white)
      }
      .background(
        Image("loginbg")
          .resizable()
      )
      .ignoresSafeArea()
    }
  }
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView(store: Store(
      initialState: LoginState(),
      reducer: Login()
    ))
  }
}

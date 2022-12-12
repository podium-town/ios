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
          Image("logo_white")
            .resizable()
            .frame(width: 220, height: 34)
          
          Text("Open social network.")
            .font(.title2)
          
          Divider()
            .padding(.vertical, 22)
          
          switch viewStore.step {
          case .phone:
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
            } else if viewStore.verificationId == nil {
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
                .padding(20)
                .background(
                  RoundedRectangle(cornerRadius: 16)
                    .fill(Color("ColorLightBackgroundInverted"))
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
              .opacity(viewStore.phoneNumber.count < 4 || viewStore.isVerificationPending ? 0.5 : 1)
              .disabled(viewStore.phoneNumber.count < 4 || viewStore.isVerificationPending)
              .buttonStyle(PodiumButtonSignIn())
              .padding(.top, 12)
              
              Button {
                viewStore.send(.setStep(step: .email))
              } label: {
                HStack {
                  Spacer()
                  Text("Sign in using email address")
                    .fontWeight(.medium)
                    .padding(.vertical, 24)
                  Spacer()
                }
              }
            }
          case .emailRegister:
            VStack(alignment: .leading, spacing: 12) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Email address")
                  .foregroundColor(.gray)
                  .font(.body.weight(.medium))
                
                TextField("", text: viewStore.binding(
                  get: \.emailAddress,
                  send: LoginAction.emailAddressChanged
                ))
                .textFieldStyle(PodiumTextFieldStyle(isEditing: true))
                .keyboardType(.emailAddress)
                .accentColor(Color.white)
              }
              
              VStack(alignment: .leading, spacing: 4) {
                Text("Password")
                  .foregroundColor(.gray)
                  .font(.body.weight(.medium))
                
                SecureField("", text: viewStore.binding(
                  get: \.password,
                  send: LoginAction.passwordChanged
                ))
                .textFieldStyle(PodiumTextFieldStyle(isEditing: true))
                .accentColor(Color.white)
              }
              
              Button {
                self.endTextEditing()
                viewStore.send(.createAccount)
              } label: {
                HStack {
                  Spacer()
                  HStack(spacing: 8) {
                    if viewStore.isVerificationPending {
                      ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                    }
                    Text("Create Account")
                  }
                  Spacer()
                }
              }
              .opacity(viewStore.isVerificationPending ? 0.5 : 1)
              .disabled(viewStore.isVerificationPending)
              .buttonStyle(PodiumButtonSignIn())
              .padding(.top, 12)
              
              Button {
                viewStore.send(.setStep(step: .phone))
              } label: {
                HStack {
                  Spacer()
                  
                  Text("Sign in using phone number")
                    .fontWeight(.medium)
                    .padding(.vertical, 12)
                  
                  Spacer()
                }
              }
            }
          case .email:
            VStack(alignment: .leading, spacing: 12) {
              VStack(alignment: .leading, spacing: 4) {
                Text("Email address")
                  .foregroundColor(.gray)
                  .font(.body.weight(.medium))
                
                TextField("", text: viewStore.binding(
                  get: \.emailAddress,
                  send: LoginAction.emailAddressChanged
                ))
                .textFieldStyle(PodiumTextFieldStyle(isEditing: true))
                .keyboardType(.emailAddress)
                .accentColor(Color.white)
              }
              
              VStack(alignment: .leading, spacing: 4) {
                Text("Password")
                  .foregroundColor(.gray)
                  .font(.body.weight(.medium))
                
                SecureField("", text: viewStore.binding(
                  get: \.password,
                  send: LoginAction.passwordChanged
                ))
                .textFieldStyle(PodiumTextFieldStyle(isEditing: true))
                .accentColor(Color.white)
              }
              
              Button {
                self.endTextEditing()
                viewStore.send(.verifyEmail)
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
              .padding(.top, 12)
              
              Button {
                viewStore.send(.setStep(step: .emailRegister))
              } label: {
                HStack {
                  Spacer()
                  
                  Text("Create account")
                    .fontWeight(.medium)
                    .padding(.vertical, 12)
                  
                  Spacer()
                }
              }
            }
            
          case .createProfile:
            VStack(alignment: .leading) {
              Text("Enter your desired username")
              
              CustomTextField("", text: viewStore.binding(
                get: \.username,
                send: LoginAction.usernameChanged
              ))
              .accentColor(.white)
              
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
                    Text("Create account")
                  }
                  Spacer()
                }
              }
              .opacity(viewStore.isVerificationPending || !viewStore.isUsernameValidated ? 0.5 : 1)
              .disabled(viewStore.isVerificationPending || !viewStore.isUsernameValidated)
              .buttonStyle(PodiumButtonSignIn())
              .padding(.top, 12)
            }
          }
          
          Divider()
            .background(Color("ColorSeparator"))
            .padding(.bottom, 12)
          
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
        .padding(24)
        .padding(.top, 80)
        .foregroundColor(.white)
        
        Spacer()
      }
      .background(.black)
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
      initialState: LoginState(
        step: .email
      ),
      reducer: Login()
    ))
  }
}

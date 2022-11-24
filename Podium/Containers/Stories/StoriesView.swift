//
//  StoriesView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct StoriesView: View {
  let store: Store<StoriesState, StoriesAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        Color.black
          .overlay(
            Image("welcome")
              .resizable()
              .scaledToFill()
          )
          .edgesIgnoringSafeArea(.all)
        
        VStack {
          HStack {
            ForEach(1..<4) { story in
              RoundedRectangle(cornerRadius: 15)
                .frame(height: 4)
                .opacity(0.5)
            }
          }
          
          HStack {
            Image("welcome")
              .resizable()
              .scaledToFill()
              .frame(width: 32, height: 32)
              .clipShape(Circle())
            
            Text("fomtord")
              .fontWeight(.semibold)
            
            Spacer()
            
            Text("5h")
          }
          
          Spacer()
          
          HStack {
            Spacer()
            Button {
              
            } label: {
              Image("heart")
                .resizable()
                .frame(width: 24, height: 24)
            }
            .padding(.horizontal)
          }
        }
        .padding()
        .foregroundColor(.white)
      }
      .background(Color.black)
    }
  }
}

struct StoriesView_Previews: PreviewProvider {
  static var previews: some View {
    StoriesView(store: Store(
      initialState: StoriesState(),
      reducer: storiesReducer,
      environment: AppEnvironment()
    ))
  }
}

//
//  CreateView.swift
//  Podium
//
//  Created by Michael Jach on 25/11/2022.
//

import SwiftUI

struct CreateView: View {
  var onAdd: () -> Void
  var onDismiss: () -> Void

  
  var body: some View {
    VStack {
      HStack {
        Spacer()
        Button {
          onDismiss()
        } label: {
          Image("close")
            .resizable()
            .frame(width: 32, height: 32)
            .foregroundColor(.white)
        }
      }
      .padding(24)
      
      Spacer()
      
      HStack {
        Spacer()
        Button {
          onAdd()
        } label: {
          HStack {
            Text("Add")
              .fontWeight(.medium)
              .font(.title3)
            
            Image("send")
              .resizable()
              .frame(width: 24, height: 24)
          }
          .foregroundColor(.black)
          .padding(.vertical, 10)
          .padding(.horizontal, 18)
          .background(.white)
          .clipShape(RoundedRectangle(cornerRadius: 99))
        }
      }
      .padding(24)
    }
  }
}

struct CreateView_Previews: PreviewProvider {
  static var previews: some View {
    CreateView(onAdd: {}, onDismiss: {})
  }
}

//
//  StoryAvatar.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct StoryAvatar: View {
  var isAddVisible: Bool = false
  
  var body: some View {
    Image("dummy-avatar")
      .resizable()
      .frame(width: 58, height: 58)
      .scaledToFill()
      .clipShape(Circle())
      .overlay(isAddVisible ?
               VStack {
        Spacer()
        HStack {
          Circle()
            .frame(width: 18, height: 18)
            .foregroundColor(.accentColor)
            .overlay(
              Image("plus")
                .resizable()
                .foregroundColor(.white)
                .frame(width: 10, height: 10)
            )
          Spacer()
        }
      } : nil
      )
  }
}

struct StoryAvatar_Previews: PreviewProvider {
  static var previews: some View {
    StoryAvatar(isAddVisible: true)
  }
}

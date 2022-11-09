//
//  StoryAvatar.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct StoryAvatar: View {
  var body: some View {
    Image("dummy-avatar")
      .resizable()
      .frame(width: 58, height: 58)
      .scaledToFill()
      .clipShape(Circle())
  }
}

struct StoryAvatar_Previews: PreviewProvider {
  static var previews: some View {
    StoryAvatar()
  }
}

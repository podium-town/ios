//
//  Post.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct Post: View {
  var post: PostModel
  
  var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .top) {
        Image("dummy-avatar")
          .resizable()
          .scaledToFill()
          .frame(width: 48, height: 48)
          .clipShape(Circle())
        
        VStack(alignment: .leading, spacing: 4) {
          Text("michaeljach")
            .fontWeight(.semibold)
          
          Text("This just shows you just how bad things have gotten. That a celebrity would not only vote R -- but then publicly post it is something else. You could say the energy is shifting.")
        }
        
        Spacer()
        
        Text("5h")
          .foregroundColor(.gray)
      }
      .padding()
      
      Divider()
        .overlay(Color("ColorSeparator"))
    }
  }
}

struct Post_Previews: PreviewProvider {
  static var previews: some View {
    Post(
      post: Mocks.post
    )
  }
}

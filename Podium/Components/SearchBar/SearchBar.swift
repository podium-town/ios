//
//  SearchBar.swift
//  Dumb
//
//  Created by Michael Jach on 24/10/2022.
//

import SwiftUI

struct SearchBar: View {
  @Binding var searchQuery: String
  @FocusState private var focus: Bool
  
  var onClear: (() -> Void)?
  
  var body: some View {
    ZStack {
      Rectangle()
        .foregroundColor(Color("ColorLightBackground"))
      HStack {
        Image(systemName: "magnifyingglass")
        TextField("Search...", text: $searchQuery)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .submitLabel(.search)
          .focused($focus)
        
        Spacer()
        
        if onClear != nil && focus {
          Button {
            focus = false
            onClear?()
          } label: {
            Image(systemName: "multiply")
              .padding(.trailing, 13)
          }
        }
      }
      .foregroundColor(.gray)
      .padding(.leading, 13)
    }
    .frame(height: 40)
    .cornerRadius(13)
  }
}

struct SearchBar_Previews: PreviewProvider {
  static var previews: some View {
    SearchBar(searchQuery: .constant("Test"))
  }
}

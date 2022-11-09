//
//  TextFieldStyle+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct PodiumTextFieldStyle: TextFieldStyle {
  var isEditing: Bool
  
  func _body(configuration: TextField<_Label>) -> some View {
    configuration
      .textFieldStyle(PlainTextFieldStyle())
      .multilineTextAlignment(.leading)
      .font(.body.weight(.medium))
      .padding()
      .background(border)
  }
  
  var border: some View {
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
        lineWidth: isEditing ? 3 : 2
      )
      .animation(.easeOut(duration: 0.2), value: isEditing)
  }
}

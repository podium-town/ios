//
//  TextFieldStyle+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct PodiumTextFieldStyle: TextFieldStyle {
  @FocusState private var textFieldFocused: Bool
  var isEditing: Bool
  
  func _body(configuration: TextField<_Label>) -> some View {
    configuration
      .padding(20)
      .focused($textFieldFocused)
      .textFieldStyle(PlainTextFieldStyle())
      .multilineTextAlignment(.leading)
      .font(.body.weight(.medium))
      .background(
        RoundedRectangle(cornerRadius: 16)
          .fill(Color("ColorLightBackgroundInverted"))
      )
      .onTapGesture {
        textFieldFocused = true
      }
  }
  
  var border: some View {
    RoundedRectangle(cornerRadius: 16)
      .strokeBorder(
        Color("ColorLightBackgroundInverted"),
        lineWidth: isEditing ? 3 : 2
      )
      .animation(.easeOut(duration: 0.2), value: isEditing)
  }
}

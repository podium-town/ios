//
//  CustomTextField.swift
//  Podium
//
//  Created by Michael Jach on 20/11/2022.
//

import SwiftUI

struct CustomTextField: View {
  let label: LocalizedStringKey
  @Binding var text: String
  let limit: Int
  let allowed: CharacterSet
  
  init(_ label: LocalizedStringKey, text: Binding<String>, limit: Int = Int.max, allowed: CharacterSet = .alphanumerics) {
    self.label = label
    self._text = Binding(projectedValue: text)
    self.limit = limit
    self.allowed = allowed
  }
  
  var body: some View {
    TextField(label, text: $text)
      .onChange(of: text) { _ in
        text = String(text.prefix(limit).unicodeScalars.filter(allowed.contains))
      }
      .textFieldStyle(PodiumTextFieldStyle(isEditing: true))
      .textInputAutocapitalization(.never)
      .disableAutocorrection(true)
  }
}

//
//  TextFieldView.swift
//  Podium
//
//  Created by Michael Jach on 12/11/2022.
//

import SwiftUI

struct CustomTextField: UIViewRepresentable {
  
  class Coordinator: NSObject, UITextViewDelegate {
    
    @Binding var text: String
    private var isResponder: Bool = true
    
    init(text: Binding<String>) {
      _text = text
      
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
      text = textView.text ?? ""
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
      DispatchQueue.main.async {
        self.isResponder = true
      }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
      DispatchQueue.main.async {
        self.isResponder = false
      }
    }
  }
  
  @Binding var text: String
  var isResponder : Bool = true
  
  var isSecured : Bool = false
  var keyboard : UIKeyboardType
  
  func makeUIView(context: UIViewRepresentableContext<CustomTextField>) -> UITextView {
    let textField = UITextView(frame: .zero)
    textField.isSecureTextEntry = isSecured
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.keyboardType = keyboard
    textField.delegate = context.coordinator
    textField.becomeFirstResponder()
    textField.font = UIFont.preferredFont(forTextStyle: .largeTitle)
    return textField
  }
  
  func makeCoordinator() -> CustomTextField.Coordinator {
    return Coordinator(text: $text)
  }
  
  func updateUIView(_ uiView: UITextView, context: UIViewRepresentableContext<CustomTextField>) {
    uiView.text = text
    if isResponder {
//      uiView.becomeFirstResponder()
    } else {
//      uiView.resignFirstResponder()
    }
  }
  
}

//
//  ButtonStyle+Extensions.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct PodiumButton: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.vertical, 20)
      .padding(.horizontal, 12)
      .background(Color("ColorText"))
      .foregroundColor(Color("ColorTextInverted"))
      .font(.body.bold())
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .scaleEffect(configuration.isPressed ? 1.05 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

struct PodiumButtonSignIn: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding(.vertical, 20)
      .padding(.horizontal, 12)
      .background(.white)
      .foregroundColor(.black)
      .font(.body.bold())
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .scaleEffect(configuration.isPressed ? 1.05 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

struct PodiumButtonSecondary: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .padding()
      .background(RoundedRectangle(cornerRadius: 16)
        .strokeBorder(
          Color("ColorText"),
          lineWidth: 2
        )
      )
      .foregroundColor(Color("ColorTextInverted"))
      .font(.body.bold())
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .scaleEffect(configuration.isPressed ? 1.05 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}

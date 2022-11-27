//
//  Banner.swift
//  Podium
//
//  Created by Michael Jach on 10/11/2022.
//

import SwiftUI

struct BannerData: Equatable {
  var title: String
  var detail: String
  var type: BannerType
}

enum BannerType {
  case info
  case warning
  case success
  case error
  
  var tintColor: Color {
    switch self {
    case .info:
      return Color("ColorText")
    case .success:
      return Color.green
    case .warning:
      return Color.yellow
    case .error:
      return Color.red
    }
  }
}

struct BannerModifier: ViewModifier {
  
  @Binding var data: BannerData?
  
  @State var task: DispatchWorkItem?
  
  func body(content: Content) -> some View {
    ZStack {
      if let data = data {
        VStack {
          Spacer()
          HStack {
            VStack(alignment: .leading, spacing: 2) {
              Text(data.title)
                .bold()
              Text(data.detail)
                .font(Font.system(size: 15, weight: Font.Weight.light, design: Font.Design.default))
            }
            Spacer()
          }
          .foregroundColor(Color("ColorTextInverted"))
          .padding(12)
          .background(data.type.tintColor)
          .cornerRadius(8)
          .shadow(radius: 20)
        }
        .padding()
        .animation(.easeInOut(duration: 1.2))
        .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
        .onTapGesture {
          withAnimation {
            self.data = nil
          }
        }
        .onAppear {
          self.task = DispatchWorkItem {
            withAnimation {
              self.data = nil
            }
          }
          // Auto dismiss after 5 seconds, and cancel the task if view disappear before the auto dismiss
          DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: self.task!)
        }
        .onDisappear {
          self.task?.cancel()
        }
        .zIndex(999)
      }
      content
    }
  }
}

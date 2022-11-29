//
//  CreateBar.swift
//  Podium
//
//  Created by Michael Jach on 25/11/2022.
//

import SwiftUI

struct CreateBar: View {
  var isLoading: Bool
  @Binding var isPresented: Bool
  var onPicker: () -> Void
  var onAddImage: (_ image: UIImage) -> Void
  var onDelete: () -> Void
  var seenBy: Int?
  
  var body: some View {
    VStack {
      HStack(spacing: 6) {
        if isLoading {
          HStack(spacing: 6) {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
            
            Text("Uploading")
              .fontWeight(.medium)
          }
        } else {
          Button {
            onPicker()
          } label: {
            Image("add")
              .resizable()
              .frame(width: 32, height: 32)
            Text("Add Story")
              .fontWeight(.medium)
          }
        }
        
        Spacer()
        
        HStack {
          Menu {
            Button("Delete story") {
              onDelete()
            }
          } label: {
            Image("more")
              .resizable()
              .frame(width: 18, height: 18)
              .scaledToFill()
          }
          
          if let seenBy = seenBy {
            Text("Seen by: \(seenBy)")
              .fontWeight(.medium)
          }
        }
      }
      .animation(.default)
      .frame(height: 40)
      .padding()
      .foregroundColor(.black)
      .background(.white)
      .clipShape(RoundedRectangle(cornerRadius: 25))
      .shadow(radius: 5)
    }
    .sheet(isPresented: $isPresented) {
      ImagePicker(
        sourceType: .photoLibrary
      ) { image in
        onAddImage(image)
      }
    }
  }
}

struct CreateBar_Previews: PreviewProvider {
  static var previews: some View {
    CreateBar(
      isLoading: true,
      isPresented: .constant(false),
      onPicker: {},
      onAddImage: { _ in },
      onDelete: {},
      seenBy: 43
    )
  }
}

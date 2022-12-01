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
  var seenBy: [SeenByModel]?
  var likedBy: [SeenByModel]?
  @State private var isStatsPresented = false
  
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
            Button {
              isStatsPresented = true
            } label: {
              HStack(spacing: 0) {
                ForEach(seenBy.prefix(upTo: min(seenBy.count, 4))) { by in
                  ZStack {
                    Image(uiImage: by.avatar == nil ? UIImage(named: "avatar")! : UIImage(data: by.avatar!)!)
                      .resizable()
                      .scaledToFill()
                      .clipShape(Circle())
                      .frame(width: 32, height: 32)
                    
                    if let likedBy = likedBy, likedBy.contains(where: { $0.id == by.id }) {
                      VStack {
                        Spacer()
                        HStack {
                          Image("heart-filled")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(Color("ColorRed"))
                            .frame(width: 16, height: 16)
                            .offset(x: -4)
                          Spacer()
                        }
                      }
                    }
                  }
                  .frame(width: 16, height: 32)
                }
              }
              .padding(.horizontal)
            }
            .sheet(isPresented: $isStatsPresented) {
              VStack(alignment: .leading) {
                HStack {
                  Text("Seen by:")
                    .fontWeight(.medium)
                    .foregroundColor(Color("ColorText"))
                  Spacer()
                  Button {
                    isStatsPresented = false
                  } label: {
                    Image("close")
                      .resizable()
                      .frame(width: 28, height: 28)
                      .foregroundColor(Color("ColorText"))
                  }
                }
                .padding()
                .padding(.bottom, 0)
                
                ScrollView {
                  VStack(spacing: 0) {
                    ForEach(seenBy) { by in
                      HStack {
                        Image(uiImage: by.avatar == nil ? UIImage(named: "avatar")! : UIImage(data: by.avatar!)!)
                          .resizable()
                          .scaledToFill()
                          .clipShape(Circle())
                          .frame(width: 32, height: 32)
                        
                        Text(by.username)
                          .fontWeight(.medium)
                          .foregroundColor(Color("ColorText"))
                        
                        if let likedBy = likedBy, likedBy.contains(where: { $0.id == by.id }) {
                          Image("heart-filled")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(Color("ColorRed"))
                            .frame(width: 16, height: 16)
                        }
                        
                        Spacer()
                      }
                      .padding(.vertical, 4)
                    }
                  }
                  .padding(.horizontal)
                }
              }
              .background(Color("ColorBackground"))
            }
          }
        }
      }
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
      onDelete: {}
    )
  }
}

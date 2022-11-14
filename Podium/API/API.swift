//
//  API.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

class API {
  let db = Firestore.firestore()
  let storage = Storage.storage()
  
  func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    do {
      return try await PhoneAuthProvider.provider()
        .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
    } catch let error {
      throw error
    }
  }
  
  func signIn(verificationId: String?, verificationCode: String?) async throws -> ProfileModel {
    if let verificationId = verificationId,
       let verificationCode = verificationCode {
      let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationId,
        verificationCode: verificationCode
      )
      do {
        let result = try await Auth.auth().signIn(with: credential)
        let dictionary = try await db
          .collection("users")
          .document(result.user.uid)
          .getDocument()
          .data()
        
        if let dictionary = dictionary {
          return try ProfileModel(dictionary: dictionary)
        } else {
          let profile = ProfileModel(
            id: result.user.uid,
            following: [result.user.uid],
            createdAt: Int(Date().millisecondsSince1970) / 1000
          )
          try await db
            .collection("users")
            .document(profile.id)
            .setData([
              "id": profile.id,
              "following": profile.following,
              "createdAt": profile.createdAt
            ])
          
          return profile
        }
      } catch let error {
        throw error
      }
    } else {
      throw AppError.general
    }
  }
  
  func uploadMedia(profileId: String, images: [UIImage]) async throws -> [String] {
    do {
      var ids: [String] = []
      for image in images {
        let fileId = UUID().uuidString
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(profileId)/\(fileId).png")
        _ = try await fileRef.putDataAsync(image.jpegData(compressionQuality: 9)!)
        ids.append(fileId)
      }
      return ids
    } catch let error {
      throw error
    }
  }
  
  func loadImage(profileId: String, fileId: String) async throws -> (String, Data) {
    do {
      let storageRef = storage.reference()
      let fileRef = storageRef.child("\(profileId)/\(fileId).png")
      let data = try await fileRef.data(maxSize: 100 * 1024 * 1024)
      return (fileId, data)
    } catch let error {
      throw error
    }
  }
  
  func getProfiles(ids: [String]) async throws -> [ProfileModel] {
    do {
      var profiles: [ProfileModel] = []
      
      let dictionary = try await db
        .collection("users")
        .whereField("id", in: ids)
        .getDocuments().documents
      
      for document in dictionary {
        if let profile = try? ProfileModel(dictionary: document.data()) {
          profiles.append(profile)
        }
      }
      return profiles
    } catch let error {
      throw error
    }
  }
  
  func getPosts(followingIds: [String]) async throws -> [PostModel] {
    do {
      var posts: [PostModel] = []
      
      let dictionary = try await db
        .collection("posts")
        .whereField("ownerId", in: followingIds)
        .order(by: "createdAt", descending: true)
        .limit(to: 50)
        .getDocuments().documents
      
      for document in dictionary {
        if let post = try? PostModel(dictionary: document.data()) {
          posts.append(post)
        }
      }
      
      return posts
    } catch let error {
      throw error
    }
  }
  
  func getPostsProfiles(ids: [String]) async throws -> ([ProfileModel], [PostModel]) {
    do {
      let posts = try await getPosts(followingIds: ids)
      let profiles = try await getProfiles(ids: posts.map({ $0.ownerId }))
      return (profiles, posts)
    } catch let error {
      throw error
    }
  }
  
  func addPost(text: String, ownerId: String, images: [String]?) async throws -> PostModel {
    do {
      let post = PostModel(
        id: UUID().uuidString,
        text: text,
        ownerId: ownerId,
        createdAt: Date().millisecondsSince1970 / 1000,
        images: images ?? []
      )
      
      try await db
        .collection("posts")
        .document(post.id)
        .setData([
          "id": post.id,
          "ownerId": post.ownerId,
          "createdAt": post.createdAt,
          "text": post.text,
          "images": post.images
        ], merge: true)
      
      return post
    } catch let error {
      throw error
    }
  }
  
  func setUsername(profile: ProfileModel, username: String) async throws -> ProfileModel {
    var updated = profile
    do {
      try await db
        .collection("users")
        .document(updated.id)
        .setData([
          "username": username
        ], merge: true)
      
      updated.username = username
      return updated
    } catch let error {
      throw error
    }
  }
  
  func follow(from: ProfileModel, id: String) async throws -> (ProfileModel, String) {
    var updated = from
    do {
      try await db
        .collection("users")
        .document(updated.id)
        .updateData([
          "following": FieldValue.arrayUnion([id])
        ])
      
      updated.following.append(id)
      return (updated, id)
    } catch let error {
      throw error
    }
  }
  
  func unFollow(from: ProfileModel, id: String) async throws -> (ProfileModel, String) {
    var updated = from
    do {
      try await db
        .collection("users")
        .document(updated.id)
        .updateData([
          "following": FieldValue.arrayRemove([id])
        ])
      
      updated.following.removeAll(where: { $0 == id })
      return (updated, id)
    } catch let error {
      throw error
    }
  }
  
  func deletePost(id: String) async throws -> String {
    do {
      try await db
        .collection("posts")
        .document(id)
        .delete()
      
      return id
    } catch let error {
      throw error
    }
  }
  
  func search(query: String) async throws -> [ProfileModel] {
    do {
      var profiles: [ProfileModel] = []
      let results = try await db
        .collection("users")
        .whereField("username", isGreaterThanOrEqualTo: query)
        .whereField("username", isLessThanOrEqualTo: query+"\u{F7FF}")
        .limit(to: 50)
        .getDocuments()
        .documents
      
      for document in results {
        if let profile = try? ProfileModel(dictionary: document.data()) {
          profiles.append(profile)
        }
      }
      
      return profiles
    } catch let error {
      throw error
    }
  }
}

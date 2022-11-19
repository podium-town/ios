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
  static let db = Firestore.firestore()
  static let storage = Storage.storage()
  static let cache = CustomCache<String, Data>()
  
  static func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    do {
      return try await PhoneAuthProvider.provider()
        .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
    } catch let error {
      throw error
    }
  }
  
  static func signIn(verificationId: String?, verificationCode: String?) async throws -> ProfileModel {
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
          var profile = try ProfileModel(dictionary: dictionary)
          if let avatarId = profile.avatarId {
            let storageRef = storage.reference()
            let fileRef = storageRef.child("\(profile.id)/\(avatarId).png")
            let data = try await fileRef.data(maxSize: 10 * 1024 * 1024)
            profile.avatarData = data
          }
          return profile
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
  
  static func uploadMedia(profileId: String, images: [UIImage]) async throws -> [String] {
    do {
      var ids: [String] = []
      for image in images {
        let fileId = UUID().uuidString
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(profileId)/\(fileId).png")
        _ = try await fileRef.putDataAsync(image.scalePreservingAspectRatio(targetSize: CGSize(width: 900, height: 1800)).jpegData(compressionQuality: 0.7)!)
        ids.append(fileId)
      }
      return ids
    } catch let error {
      throw error
    }
  }
  
  static func loadImage(profileId: String, fileId: String) async throws -> (String, Data) {
    do {
      if let cached = API.cache.value(forKey: fileId) {
        return (fileId, cached)
      } else {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(profileId)/\(fileId).png")
        let data = try await fileRef.data(maxSize: 10 * 1024 * 1024)
        API.cache.insert(data, forKey: fileId, timeToLiveInMinutes: 24 * 60)
        return (fileId, data)
      }
    } catch let error {
      throw error
    }
  }
  
  static func getProfiles(ids: [String]) async throws -> [ProfileModel] {
    do {
      var profiles: [ProfileModel] = []
      
      let dictionary = try await db
        .collection("users")
        .whereField("id", in: ids)
        .getDocuments().documents
      
      for document in dictionary {
        if var profile = try? ProfileModel(dictionary: document.data()) {
          if let avatarId = profile.avatarId {
            let storageRef = storage.reference()
            let fileRef = storageRef.child("\(profile.id)/\(avatarId).png")
            let data = try await fileRef.data(maxSize: 10 * 1024 * 1024)
            profile.avatarData = data
          }
          profiles.append(profile)
        }
      }
      return profiles
    } catch let error {
      throw error
    }
  }
  
  static func getPosts(followingIds: [String]) async throws -> [PostModel] {
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
  
  static func getPostsProfiles(ids: [String]) async throws -> ([ProfileModel], [PostModel]) {
    do {
      let posts = try await getPosts(followingIds: ids)
      if !posts.isEmpty {
        let profiles = try await getProfiles(ids: Array(Set(posts.map({ $0.ownerId }))))
        return (profiles, posts)
      } else {
        throw AppError.general
      }
    } catch let error {
      throw error
    }
  }
  
  static func addPost(text: String, ownerId: String, images: [String]?) async throws -> PostModel {
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
  
  static func setUsername(profile: ProfileModel, username: String) async throws -> ProfileModel {
    var updated = profile
    do {
      let isAvailable = try await API.checkUsername(username: username)
      if isAvailable {
        try await db
          .collection("users")
          .document(updated.id)
          .setData([
            "username": username
          ], merge: true)
        
        updated.username = username
        return updated
      } else {
        throw AppError.usernameTaken
      }
    } catch let error {
      throw error
    }
  }
  
  static func changeAvatar(profileId: String, uiImage: UIImage) async throws -> String {
    do {
      let fileId = UUID().uuidString
      let storageRef = storage.reference()
      let fileRef = storageRef.child("\(profileId)/\(fileId).png")
      _ = try await fileRef.putDataAsync(uiImage.scalePreservingAspectRatio(targetSize: CGSize(width: 300, height: 300)).jpegData(compressionQuality: 0.5)!)
      try await db
        .collection("users")
        .document(profileId)
        .updateData([
          "avatarId": fileId
        ])
      return fileId
    } catch let error {
      throw error
    }
  }
  
  static func checkUsername(username: String) async throws -> Bool {
    do {
      let results = try await db
        .collection("users")
        .whereField("username", isEqualTo: username)
        .count
        .getAggregation(source: .server)
      
      return results.count == 0
    } catch let error {
      throw error
    }
  }
  
  static func follow(from: ProfileModel, id: String) async throws -> (ProfileModel, String) {
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
  
  static func unFollow(from: ProfileModel, id: String) async throws -> (ProfileModel, String) {
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
  
  static func deletePost(id: String) async throws -> String {
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
  
  static func search(query: String) async throws -> [ProfileModel] {
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

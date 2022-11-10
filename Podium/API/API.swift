//
//  API.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import FirebaseFirestore
import FirebaseAuth

class API {
  let db = Firestore.firestore()
  
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
          throw AppError.general
        }
      } catch let error {
        throw error
      }
    } else {
      throw AppError.general
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
      let profiles = try await getProfiles(ids: ids)
      let posts = try await getPosts(followingIds: ids)
      return (profiles, posts)
    } catch let error {
      throw error
    }
  }
  
  func addPost(text: String, ownerId: String) async throws -> PostModel {
    do {
      let post = PostModel(
        id: UUID().uuidString,
        text: text,
        ownerId: ownerId,
        createdAt: Date().millisecondsSince1970 / 1000
      )

      try await db
        .collection("posts")
        .document(post.id)
        .setData([
          "id": post.id,
          "ownerId": post.ownerId,
          "createdAt": post.createdAt,
          "text": post.text
        ], merge: true)
      
      return post
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
}

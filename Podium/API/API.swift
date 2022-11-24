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
  
  static func uploadMedia(post: PostModel, images: [UIImage]) async throws -> PostModel {
    var mut = post
    do {
      var urls: [String] = []
      for image in images {
        let fileId = UUID().uuidString
        let storageRef = storage.reference()
        let profileId = post.ownerId
        let fileRef = storageRef.child("\(profileId)/\(fileId).png")
        _ = try await fileRef.putDataAsync(image.scalePreservingAspectRatio(targetSize: CGSize(width: 900, height: 1800)).jpegData(compressionQuality: 0.7)!)
        let url = try await fileRef.downloadURL()
        urls.append(url.absoluteString)
      }
      mut.images = urls
      return mut
    } catch let error {
      throw error
    }
  }
  
  static func getImage(url: String) async throws -> (String, Data) {
    do {
      let request = URLRequest(url: URL(string: url)!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
      let (data, _) = try await URLSession.shared.data(for: request)
      return (url, data)
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
  
  static func getProfile(id: String) async throws -> ProfileModel {
    do {
      let dictionary = try await db
        .collection("users")
        .document(id)
        .getDocument()
        .data()
      
      if let dictionary = dictionary,
         var profile = try? ProfileModel(dictionary: dictionary) {
        if let avatarId = profile.avatarId {
          let storageRef = storage.reference()
          let fileRef = storageRef.child("\(profile.id)/\(avatarId).png")
          let data = try await fileRef.data(maxSize: 10 * 1024 * 1024)
          profile.avatarData = data
        }
        return profile
      }
      throw AppError.profileNotExists
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
  
  static func getPostsProfiles(ids: [String]) async throws -> [PostModel] {
    do {
      var posts = try await getPosts(followingIds: ids)
      if !posts.isEmpty {
        let profiles = try await getProfiles(ids: Array(Set(posts.map({ $0.ownerId }))))
        posts = posts.map { post in
          var mut = post
          mut.profile = profiles.first(where: { $0.id == mut.ownerId })
          return mut
        }
        return posts
      } else {
        return []
      }
    } catch let error {
      throw error
    }
  }
  
  static func getTopHashtags() async throws -> [HashtagModel] {
    do {
      var tags: [HashtagModel] = []
      let dictionary = try await db
        .collection("hashtags")
        .order(by: "posts", descending: true)
        .limit(to: 20)
        .getDocuments().documents
      
      for document in dictionary {
        if let tag = try? HashtagModel(dictionary: document.data()) {
          tags.append(tag)
        }
      }
      return tags
    } catch let error {
      throw error
    }
  }
  
  static func listenPosts(ids: [String], completion: @escaping (_ posts: [PostModel]) -> Void) async throws {
    let profiles = try await getProfiles(ids: ids)
    db
      .collection("posts")
      .whereField("ownerId", in: ids)
      .order(by: "createdAt", descending: true)
      .addSnapshotListener({ querySnapshot, error in
        var posts: [PostModel] = []
        if let documents = querySnapshot?.documentChanges {
          for document in documents {
            if document.type == .added,
               var post = try? PostModel(dictionary: document.document.data()) {
              post.profile = profiles.first(where: { $0.id == post.ownerId })
              posts.append(post)
            }
          }
          if(!posts.isEmpty) {
            completion(posts)
          }
        }
      })
  }
  
  static func listenComments(post: PostModel, completion: @escaping (_ comments: [PostModel]) -> Void) async throws {
    
    db
      .collection("comments")
      .whereField("postId", isEqualTo: post.id)
      .order(by: "createdAt", descending: true)
      .addSnapshotListener({ querySnapshot, error in
        var comments: [PostModel] = []
        let group = DispatchGroup()
        if let documents = querySnapshot?.documentChanges {
          for document in documents {
            if document.type == .added,
               var comment = try? PostModel(dictionary: document.document.data()) {
              group.enter()
              db
                .collection("users")
                .document(comment.ownerId)
                .getDocument { querySnapshot, error in
                  if let querySnapshot = querySnapshot {
                    if let data = querySnapshot.data(),
                       var profile = try? ProfileModel(dictionary: data) {
                      if let avatarId = profile.avatarId {
                        let storageRef = storage.reference()
                        let fileRef = storageRef.child("\(profile.id)/\(avatarId).png")
                        fileRef.getData(maxSize: 10 * 1024 * 1024) { data, error in
                          if let data = data {
                            profile.avatarData = data
                          }
                          comment.profile = profile
                          comments.append(comment)
                          group.leave()
                        }
                      } else {
                        comment.profile = profile
                        comments.append(comment)
                        group.leave()
                      }
                    }
                  }
                }
            }
          }
          group.notify(queue: .main) {
            completion(comments)
          }
        }
      })
  }
  
  static func addPost(post: PostModel) async throws -> PostModel {
    do {
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
      
      let matches = post.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
      for hashtag in matches {
        try await db
          .collection("hashtags")
          .document(hashtag)
          .setData([
            "hashtag": hashtag,
            "createdAt": Int(Date().millisecondsSince1970) / 1000,
            "posts" : FieldValue.arrayUnion([post.id])
          ], merge: true)
      }
      
      return post
    } catch let error {
      throw error
    }
  }
  
  static func addComment(comment: PostModel, postId: String) async throws -> PostModel {
    do {
      try await db
        .collection("comments")
        .document(comment.id)
        .setData([
          "id": comment.id,
          "ownerId": comment.ownerId,
          "postId": postId,
          "createdAt": comment.createdAt,
          "text": comment.text,
          "images": comment.images
        ])
      
      return comment
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
  
  static func getComments(postId: String) async throws -> [PostModel] {
    do {
      var posts: [PostModel] = []
      let dictionary = try await db
        .collection("comments")
        .whereField("postId", isEqualTo: postId)
        .order(by: "createdAt", descending: true)
        .limit(to: 50)
        .getDocuments().documents
      
      for document in dictionary {
        if let post = try? PostModel(dictionary: document.data()) {
          posts.append(post)
        }
      }
      
      if !posts.isEmpty {
        let profiles = try await getProfiles(ids: Array(Set(posts.map({ $0.ownerId }))))
        posts = posts.map { post in
          var mut = post
          mut.profile = profiles.first(where: { $0.id == mut.ownerId })
          return mut
        }
        return posts
      } else {
        return []
      }
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
  
  static func deletePost(post: PostModel) async throws -> String {
    do {
      try await db
        .collection("posts")
        .document(post.id)
        .delete()
      
      let comments = try await db
        .collection("comments")
        .whereField("postId", isEqualTo: post.id)
        .getDocuments()
        .documents
      
      for comment in comments {
        try await comment.reference.delete()
      }
      
      let matches = post.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
      for hashtag in matches {
        try await db
          .collection("hashtags")
          .document(hashtag)
          .updateData([
            "posts": FieldValue.arrayRemove([post.id])
          ])
      }
      
      return post.id
    } catch let error {
      throw error
    }
  }
  
  static func reportPost(reporterId: String, post: PostModel) async throws -> String {
    do {
      try await db
        .collection("reports")
        .document(post.id)
        .setData([
          "reporters": FieldValue.arrayUnion([reporterId])
        ], merge: true)
      return post.id
    } catch let error {
      throw error
    }
  }
  
  static func reportComment(reporterId: String, comment: PostModel) async throws -> String {
    do {
      try await db
        .collection("reports")
        .document(comment.id)
        .setData([
          "reporters": FieldValue.arrayUnion([reporterId])
        ], merge: true)
      return comment.id
    } catch let error {
      throw error
    }
  }
  
  static func deleteComment(comment: PostModel) async throws -> String {
    do {
      try await db
        .collection("comments")
        .document(comment.id)
        .delete()
      
      let matches = comment.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
      for hashtag in matches {
        try await db
          .collection("hashtags")
          .document(hashtag)
          .updateData([
            "posts": FieldValue.arrayRemove([comment.id])
          ])
      }
      
      return comment.id
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
        .limit(to: 25)
        .getDocuments()
        .documents
      
      for document in results {
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
}

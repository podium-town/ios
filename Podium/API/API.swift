//
//  API.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestoreSwift
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
            let data = try? await fileRef.data(maxSize: 10 * 1024 * 1024)
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
  
  static func uploadMedia(post: PostProfileModel, images: [UIImage]) async throws -> PostProfileModel {
    var mut = post
    do {
      for image in images {
        let fileId = UUID().uuidString
        let storageRef = storage.reference()
        let profileId = post.post.ownerId
        let fileRef = storageRef.child("\(profileId)/\(fileId).png")
        _ = try await fileRef.putDataAsync(image.scalePreservingAspectRatio(targetSize: CGSize(width: 900, height: 1800)).jpegData(compressionQuality: 0.1)!)
        let url = try await fileRef.downloadURL()
        mut.post.images.append(PostImage(
          id: fileId,
          url: url.absoluteString
        ))
      }
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
            let data = try? await fileRef.data(maxSize: 10 * 1024 * 1024)
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
          let data = try? await fileRef.data(maxSize: 10 * 1024 * 1024)
          profile.avatarData = data
        }
        return profile
      }
      throw AppError.profileNotExists
    } catch let error {
      throw error
    }
  }
  
  static func getPosts(followingIds: [String]) async throws -> [PostProfileModel] {
    do {
      var tempPosts: [PostModel] = []
      
      let dictionary = try await db
        .collection("posts")
        .whereField("ownerId", in: followingIds)
        .order(by: "createdAt", descending: true)
        .limit(to: 50)
        .getDocuments().documents
      
      for document in dictionary {
        if let post = try? document.data(as: PostModel.self) {
          tempPosts.append(post)
        }
      }
      
      let uniqueProfileIds = Array(Set(tempPosts.map { $0.ownerId }))
      
      let profiles = try await withThrowingTaskGroup(of: ProfileModel.self) { group in
        for id in uniqueProfileIds {
          group.addTask {
            return try await getProfile(id: id)
          }
        }
        
        var collected: [String: ProfileModel] = [:]
        
        for try await value in group {
          collected[value.id] = value
        }
        
        return collected
      }
      
      return tempPosts.map({ post in
        return PostProfileModel(
          id: post.id,
          post: post,
          profile: profiles[post.ownerId]!
        )
      })
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
        if let tag = try? document.data(as: HashtagModel.self) {
          tags.append(tag)
        }
      }
      return tags
    } catch let error {
      throw error
    }
  }
  
  static func listenPosts(ids: [String], completion: @escaping (_ posts: [PostProfileModel]) -> Void) {
    db
      .collection("posts")
      .whereField("ownerId", in: ids)
      .order(by: "createdAt", descending: true)
      .addSnapshotListener({ querySnapshot, error in
        Task {
          var tempPosts: [PostModel] = []
          
          if let documents = querySnapshot?.documentChanges {
            for document in documents {
              if document.type == .added,
                 let post = try? document.document.data(as: PostModel.self) {
                tempPosts.append(post)
              }
            }
            
            let uniqueProfileIds = Array(Set(tempPosts.map({ $0.ownerId })))
            
            let profiles = try await withThrowingTaskGroup(of: ProfileModel.self) { group in
              for id in uniqueProfileIds {
                group.addTask {
                  return try await getProfile(id: id)
                }
              }
              
              var collected: [String: ProfileModel] = [:]
              
              for try await value in group {
                collected[value.id] = value
              }
              
              return collected
            }
            
            let posts = tempPosts.map({ post in
              return PostProfileModel(
                id: post.id,
                post: post,
                profile: profiles[post.ownerId]!
              )
            })
            
            completion(posts)
          }
        }
      })
  }
  
  static func listenComments(post: PostProfileModel, completion: @escaping (_ comments: [PostProfileModel]) -> Void) -> ListenerRegistration {
    return db
      .collection("comments")
      .whereField("postId", isEqualTo: post.post.id)
      .order(by: "createdAt", descending: true)
      .addSnapshotListener({ querySnapshot, error in
        Task {
          var tempComments: [PostModel] = []
          
          if let documents = querySnapshot?.documentChanges {
            for document in documents {
              if document.type == .added,
                 let comment = try? document.document.data(as: PostModel.self) {
                tempComments.append(comment)
              }
            }
            
            let uniqueProfileIds = Array(Set(tempComments.map({ $0.ownerId })))
            
            let profiles = try await withThrowingTaskGroup(of: ProfileModel.self) { group in
              for id in uniqueProfileIds {
                group.addTask {
                  return try await getProfile(id: id)
                }
              }
              
              var collected: [String: ProfileModel] = [:]
              
              for try await value in group {
                collected[value.id] = value
              }
              
              return collected
            }
            
            let comments = tempComments.map({ post in
              return PostProfileModel(
                id: post.id,
                post: post,
                profile: profiles[post.ownerId]!
              )
            })
            
            completion(comments)
          }
        }
      })
  }
  
  static func addPost(post: PostProfileModel) async throws -> PostProfileModel {
    do {
      try db
        .collection("posts")
        .document(post.post.id)
        .setData(from: post.post, merge: true)
      
      let matches = post.post.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
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
  
  static func addComment(comment: PostProfileModel, postId: String) async throws -> PostProfileModel {
    do {
      try await db
        .collection("comments")
        .document(comment.post.id)
        .setData([
          "id": comment.post.id,
          "ownerId": comment.post.ownerId,
          "postId": postId,
          "createdAt": comment.post.createdAt,
          "text": comment.post.text,
          "images": comment.post.images
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
      let fileId = "avatar"
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
  
  static func getComments(postId: String) async throws -> [PostProfileModel] {
    do {
      let profiles: [String: ProfileModel] = [:]
      var posts: [PostProfileModel] = []
      let dictionary = try await db
        .collection("comments")
        .whereField("postId", isEqualTo: postId)
        .order(by: "createdAt", descending: true)
        .limit(to: 50)
        .getDocuments().documents
      
      for document in dictionary {
        if let post = try? document.data(as: PostModel.self) {
          if let profile = profiles[post.ownerId] {
            posts.append(PostProfileModel(
              id: post.id,
              post: post,
              profile: profile
            ))
          } else {
            if let profile = try? await getProfile(id: post.ownerId) {
              posts.append(PostProfileModel(
                id: post.id,
                post: post,
                profile: profile
              ))
            }
          }
        }
      }
      
      if !posts.isEmpty {
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
  
  static func deleteStory(story: StoryProfileModel) async throws -> StoryProfileModel {
    do {
      try await db
        .collection("stories")
        .document(story.story.id)
        .delete()
      
      let storageRef = storage.reference()
      let fileRef = storageRef.child("\(story.story.ownerId)/stories/\(story.story.fileId).png")
      try await fileRef.delete()
      return story
    } catch let error {
      throw error
    }
  }
  
  static func deletePost(post: PostProfileModel) async throws -> String {
    do {
      try await db
        .collection("posts")
        .document(post.post.id)
        .delete()
      
      let comments = try await db
        .collection("comments")
        .whereField("postId", isEqualTo: post.post.id)
        .getDocuments()
        .documents
      
      for comment in comments {
        try? await comment.reference.delete()
      }
      
      let matches = post.post.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
      for hashtag in matches {
        try? await db
          .collection("hashtags")
          .document(hashtag)
          .updateData([
            "posts": FieldValue.arrayRemove([post.post.id])
          ])
      }
      
      for image in post.post.images {
        let storageRef = storage.reference()
        let fileRef = storageRef.child("\(post.post.ownerId)/\(image.id).png")
        try? await fileRef.delete()
      }
      
      return post.post.id
    } catch let error {
      throw error
    }
  }
  
  static func reportPost(reporterId: String, post: PostProfileModel) async throws -> String {
    do {
      try await db
        .collection("reports")
        .document(post.post.id)
        .setData([
          "reporters": FieldValue.arrayUnion([reporterId])
        ], merge: true)
      return post.post.id
    } catch let error {
      throw error
    }
  }
  
  static func reportComment(reporterId: String, comment: PostProfileModel) async throws -> String {
    do {
      try await db
        .collection("reports")
        .document(comment.post.id)
        .setData([
          "reporters": FieldValue.arrayUnion([reporterId])
        ], merge: true)
      return comment.post.id
    } catch let error {
      throw error
    }
  }
  
  static func deleteComment(comment: PostProfileModel) async throws -> String {
    do {
      try await db
        .collection("comments")
        .document(comment.post.id)
        .delete()
      
      let matches = comment.post.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
      for hashtag in matches {
        try await db
          .collection("hashtags")
          .document(hashtag)
          .updateData([
            "posts": FieldValue.arrayRemove([comment.post.id])
          ])
      }
      
      return comment.post.id
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
  
  static func addStory(profile: ProfileModel, image: UIImage) async throws -> (String, StoryProfileModel) {
    do {
      let fileId = UUID().uuidString
      var story = StoryProfileModel(
        story: StoryModel(
          id: UUID().uuidString,
          url: "",
          fileId: fileId,
          ownerId: profile.id,
          createdAt: Int64(Int(Date().millisecondsSince1970) / 1000),
          seenBy: []
        ),
        profile: profile
      )
      
      let storageRef = storage.reference()
      let fileRef = storageRef.child("\(profile.id)/stories/\(fileId).png")
      _ = try await fileRef.putDataAsync(image.scalePreservingAspectRatio(targetSize: CGSize(width: 900, height: 1800)).jpegData(compressionQuality: 0.1)!)
      let url = try await fileRef.downloadURL()
      story.story.url = url.absoluteString
      
      try db
        .collection("stories")
        .document(story.story.id)
        .setData(from: story.story, merge: true)
      
      return (profile.id, story)
    } catch let error {
      throw error
    }
  }
  
  static func listenStories(ids: [String], profileId: String, completion: @escaping (_ storiesToAdd: ([String: [StoryProfileModel]], [StoryUrlModel], [ProfileModel]), _ storiesToRemove: [String: [StoryModel]]) -> Void) {
    db
      .collection("stories")
      .whereField("ownerId", in: ids)
      .addSnapshotListener({ querySnapshot, error in
        Task {
          var tempStories: [StoryModel] = []
          var toRemove: [String: [StoryModel]] = [:]
          var stories: [String: [StoryProfileModel]] = [:]
          var urls: [StoryUrlModel] = []
          
          if let documents = querySnapshot?.documentChanges {
            for document in documents {
              if document.type == .added,
                 let story = try? document.document.data(as: StoryModel.self) {
                urls.append(StoryUrlModel(
                  url: story.url,
                  createdAt: story.createdAt
                ))
                tempStories.append(story)
              }
              if document.type == .removed,
                 let story = try? document.document.data(as: StoryModel.self) {
                if toRemove[story.ownerId] == nil {
                  toRemove[story.ownerId] = [story]
                } else {
                  toRemove[story.ownerId]?.append(story)
                }
              }
            }
            
            let uniqueProfileIds = Array(Set(tempStories.map({ $0.ownerId })))
            
            let profiles = try await withThrowingTaskGroup(of: ProfileModel.self) { group in
              for id in uniqueProfileIds {
                group.addTask {
                  return try await getProfile(id: id)
                }
              }
              
              var collected: [String: ProfileModel] = [:]
              
              for try await value in group {
                collected[value.id] = value
              }
              
              return collected
            }
            
            tempStories.forEach { story in
              let storyModel = StoryProfileModel(
                story: story,
                profile: profiles[story.ownerId]!
              )
              if stories[story.ownerId] == nil {
                stories[story.ownerId] = [storyModel]
              } else {
                stories[story.ownerId]?.append(storyModel)
              }
            }
            
            let sortedProfiles = stories
              .map({ profiles[$0.key]! })
              .map { profile in
                var mut = profile
                mut.hasNewStories = stories[mut.id]?.contains(where: { !$0.story.seenBy.contains(where: { $0 == profileId}) })
                return mut
              }
              
            completion((stories, urls, sortedProfiles), toRemove)
          }
        }
      })
  }
  
  static func getStories(ids: [String], profileId: String) async throws -> ([String: [StoryProfileModel]], [StoryUrlModel], [ProfileModel]) {
    do {
      var tempStories: [StoryModel] = []
      var urls: [StoryUrlModel] = []
      var stories: [String: [StoryProfileModel]] = [:]
      
      let dictionary = try await db
        .collection("stories")
        .whereField("ownerId", in: ids)
        .getDocuments()
        .documents
      
      for document in dictionary {
        if let story = try? document.data(as: StoryModel.self) {
          urls.append(StoryUrlModel(
            url: story.url,
            createdAt: story.createdAt
          ))
          tempStories.append(story)
        }
      }
      
      let uniqueProfileIds = Array(Set(tempStories.map { $0.ownerId }))
      
      let profiles = try await withThrowingTaskGroup(of: ProfileModel.self) { group in
        for id in uniqueProfileIds {
          group.addTask {
            return try await getProfile(id: id)
          }
        }
        
        var collected: [String: ProfileModel] = [:]
        
        for try await value in group {
          collected[value.id] = value
        }
        
        return collected
      }
      
      tempStories.forEach { story in
        let model = StoryProfileModel(
          story: story,
          profile: profiles[story.ownerId]!
        )
        if stories[story.ownerId] == nil {
          stories[story.ownerId] = [model]
        } else {
          stories[story.ownerId]?.append(model)
        }
      }
      
      let sortedProfiles = stories
        .sorted(by: { $0.value.last!.story.createdAt > $1.value.last!.story.createdAt })
        .map({ profiles[$0.key]! })
        .map { profile in
          var mut = profile
          mut.hasNewStories = stories[mut.id]?.contains(where: { !$0.story.seenBy.contains(where: { $0 == profileId}) })
          return mut
        }
      
      return (stories, urls, sortedProfiles)
    } catch let error {
      throw error
    }
  }
  
  static func prefetchStories(fileUrls: [String]) async throws -> [String: Data] {
    try await withThrowingTaskGroup(of: (String, Data).self) { group in
      var prefetched: [String: Data] = [:]
      
      for url in fileUrls {
        group.addTask {
          let (fileUrl, data) = try await getImage(url: url)
          return (fileUrl, data)
        }
      }
      
      for try await value in group {
        let (fileUrl, data) = value
        prefetched[fileUrl] = data
      }
      
      return prefetched
    }
  }
  
  static func markSeen(storyId: String?, profileId: String) async throws -> String {
    do {
      if let storyId = storyId {
        try await db
          .collection("stories")
          .document(storyId)
          .updateData([
            "seenBy": FieldValue.arrayUnion([profileId])
          ])
        return storyId
      }
      throw AppError.general
    } catch let error {
      throw error
    }
  }
  
  static func getStats(storyId: String) async throws -> [String] {
    do {
      let story = try await db
        .collection("stories")
        .document(storyId)
        .getDocument(as: StoryModel.self)
        
      return story.seenBy
    } catch let error {
      throw error
    }
  }
}

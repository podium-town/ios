//
//  PodiumApp.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture
import Firebase

@main
struct PodiumApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      AppView(
        store: Store(
          initialState: AppState(),
          reducer: appReducer,
          environment: AppEnvironment()
        ))
      .onOpenURL { url in
        Auth.auth().canHandle(url)
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
  var environment: AppEnvironment?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    environment = AppEnvironment()
    UNUserNotificationCenter.current().delegate = self
    
    // register for notifications, but request permissions during signup flow
    application.registerForRemoteNotifications()
    return true
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    completionHandler(UIBackgroundFetchResult.newData)
  }
}

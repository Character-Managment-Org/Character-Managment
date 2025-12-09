//
//  AppDelegate.swift
//  CoreApp UIKit
//
//  Created by Никита Борчевский on 25.09.25.
//

import UIKit
import AppTrackingTransparency
import FirebaseMessaging
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {

    var window: UIWindow?
    var internetStatus: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        return true
    }
        // MARK: - Firebase Messaging Delegate
        func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
            UserDefaults.standard.set(fcmToken, forKey: "fcm_token")
            UserDefaults.standard.synchronize()
            print("FCM Token: \(fcmToken ?? "nil")")
        }
    
    
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
}


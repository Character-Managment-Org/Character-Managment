// ...existing code...
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
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {

    // Показывать пуши, когда приложение открыто
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    var window: UIWindow?
    var internetStatus: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
        // Обработка перехода по пуш-уведомлению
        func userNotificationCenter(_ center: UNUserNotificationCenter,
            didReceive response: UNNotificationResponse,
            withCompletionHandler completionHandler: @escaping () -> Void) {
            let userInfo = response.notification.request.content.userInfo
            if let newURL = userInfo["url"] as? String {
                UserDefaults.standard.set(newURL, forKey: "config_url")
                UserDefaults.standard.synchronize()
                // Здесь можно добавить логику открытия вебвью с новой ссылкой
                // Например, через window?.rootViewController
            }
            completionHandler()
        }
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


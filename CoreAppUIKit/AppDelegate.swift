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

    var window: UIWindow?
    var internetStatus: Bool = true

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    // MARK: - APNs Token Methods
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        print("APNs device token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

    // Показывать пуши, когда приложение открыто
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    // Обработка перехода по пуш-уведомлению
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        if let newURL = userInfo["url"] as? String {
            UserDefaults.standard.set(newURL, forKey: "config_url")
            UserDefaults.standard.synchronize()
            // Открываем вебвью с новой ссылкой, если есть rootViewController
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                guard let self = self, let root = self.window?.rootViewController else { return }
                let webVC = WebViewController(url: newURL)
                root.present(webVC, animated: true, completion: nil)
            }
        }
        completionHandler()
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


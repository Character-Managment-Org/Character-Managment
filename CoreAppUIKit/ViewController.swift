import UIKit
import FirebaseMessaging
import FirebaseCore
import AppTrackingTransparency
import AdSupport
import AppsFlyerLib
import WebKit

struct ConfigKeys {
    static let url = "config_url"
    static let expires = "config_expires"
    static let lastCustomPushRequest = "last_custom_push_request"
}

class ViewController: UIViewController, AppsFlyerLibDelegate, DeepLinkDelegate {
    
    @IBOutlet weak var spinView: UIImageView!
    let appsFlyerDevKey = "z5JrY32kZnC2REjFEbtwGe"
    let appleAppID = "6755873596"
    let endPoint = "https://charactermanagment.com"
    var window: UIWindow?
    private var conversionData: [AnyHashable: Any] = [:]
    private var noInternetVC: NoInternetViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startSpinAnimation()
        let now = Date().timeIntervalSince1970
        let expires = UserDefaults.standard.double(forKey: ConfigKeys.expires)
        
        if expires > now, let savedURL = UserDefaults.standard.string(forKey: ConfigKeys.url) {
            // URL валиден → проверяем пуши перед запуском вебвью
            checkPushBeforeWebView(savedURL: savedURL)
            return
        }
        
        // Если ссылки нет или истек срок — идём по пути ATT → AppsFlyer → запрос конфига
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            print("✅ Tracking разрешён → запускаем AppsFlyer")
                            self.startAppsflyer()
                        case .denied, .restricted, .notDetermined:
                            print("❌ Tracking запрещён → AppsFlyer не запускаем")
                            // тут можно запустить игру
                            self.startGame()
                        @unknown default:
                            break
                        }
                    }
                }
            } else {
                self.startAppsflyer()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Запускаем мониторинг интернета после появления экрана
        startNetworkMonitoring()
    }
    
    // MARK: - AppsFlyer
    private func startAppsflyer() {
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppID
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().delegate = self
        AppsFlyerLib.shared().start()
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        
        switch result.status {
        case .notFound:
            AppsFlyerLib.shared().logEvent(name: "DeepLinkNotFound", values: nil)
            return
            
        case .failure:
            if let error = result.error {
                AppsFlyerLib.shared().logEvent(name: "DeepLinkError", values: nil)
            } else {
                print("[AFSDK] Deep link error: unknown")
                AppsFlyerLib.shared().logEvent(name: "DeepLinkError", values: nil)
            }
            return
            
        case .found:
            AppsFlyerLib.shared().logEvent(name: "DeepLinkFound", values: nil)

            guard let deepLink = result.deepLink else {
                AppsFlyerLib.shared().logEvent(name: "NoDeepLinkData", values: nil)
                print("[AFSDK] No deep link data")
                return
            }

            // Проверка на deferred / direct
            let isDeferred = deepLink.isDeferred ?? false
            print(isDeferred ? "This is a deferred deep link" : "This is a direct deep link")

            // Извлечение параметров диплинка
            var deepLinkParams: [String: Any] = [:]

            if let clickEventDict = (deepLink.clickEvent["click_event"] as? [String: Any]) {
                deepLinkParams = clickEventDict
            } else {
                deepLinkParams = deepLink.clickEvent
            }
        
            self.conversionData.merge(deepLinkParams) { (_, new) in new }
        }
    }
    
    // Успешное получение данных AppsFlyer
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("Conversion data: \(conversionInfo)")
        fetchConfig(conversionInfo: conversionInfo)
    }
    
    func onConversionDataFail(_ error: Error) {
        print("Conversion data error: \(error.localizedDescription)")
        handleConfigFailure()
    }
    
    // MARK: - Config
    private func fetchConfig(conversionInfo: [AnyHashable: Any]) {
        guard let url = URL(string: "\(endPoint)/config.php") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // payload
        var payload = conversionData
        for (key, value) in conversionInfo {
            if let keyStr = key as? String {
                payload[keyStr] = value
            }
        }
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["os"] = "iOS"
        payload["bundle_id"] = Bundle.main.bundleIdentifier ?? "unknown"
        payload["store_id"] = "id\(appleAppID)"
        payload["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        let pushToken = UserDefaults.standard.string(forKey: "fcm_token") ?? Messaging.messaging().fcmToken
        payload["push_token"] = pushToken

        // Визуальный вывод push_token
        let alert = UIAlertController(title: "Push Token", message: pushToken ?? "nil", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        payload["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            print("❌ Ошибка сериализации JSON: \(error)")
            handleConfigFailure()
            return
        }
        
        let session = URLSession(configuration: .default, delegate: UnsafeSessionDelegate(), delegateQueue: nil)
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Ошибка запроса: \(error.localizedDescription)")
                    self.handleConfigFailure()
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let data = data else {
                    print("❌ Сервер вернул ошибку")
                    self.handleConfigFailure()
                    return
                }
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let urlString = json["url"] as? String,
                       let expires = json["expires"] as? TimeInterval {
                        
                        // Сохраняем url и expires
                        UserDefaults.standard.set(urlString, forKey: ConfigKeys.url)
                        UserDefaults.standard.set(expires, forKey: ConfigKeys.expires)
                        UserDefaults.standard.synchronize()
                        
                        // Перед запуском вебвью проверяем пуши
                        self.checkPushBeforeWebView(savedURL: urlString)
                        
                    } else {
                        self.handleConfigFailure()
                    }
                } catch {
                    print("❌ Ошибка парсинга JSON: \(error)")
                    self.handleConfigFailure()
                }
            }
        }
        
        task.resume()
    }
    
    private func handleConfigFailure() {
        if let savedURL = UserDefaults.standard.string(forKey: ConfigKeys.url) {
            // Было сохранено ранее → запускаем вебвью
            checkPushBeforeWebView(savedURL: savedURL)
        } else {
            // Иначе запускаем игру
            startGame()
        }
    }
    
    // MARK: - Push Flow
    private func checkPushBeforeWebView(savedURL: String) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    self.openWebView(savedURL)
                } else {
                    self.handleCustomPushFlow(savedURL: savedURL)
                }
            }
        }
    }
    
    private func handleCustomPushFlow(savedURL: String) {
        let now = Date().timeIntervalSince1970
        let lastRequest = UserDefaults.standard.double(forKey: ConfigKeys.lastCustomPushRequest)
        let threeDays: TimeInterval = 259200 // 3 дня
        
        if lastRequest > 0, now - lastRequest < threeDays {
            // ⏳ Прошло меньше 3 дней с отказа → сразу открываем вебвью
            openWebView(savedURL)
        } else {
            // ⏰ Прошло больше 3 дней или окно ещё не показывалось
            showCustomPushRequest(savedURL: savedURL)
        }
    }
    
    private func showCustomPushRequest(savedURL: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "NotificationViewController") as! NotificationViewController
        vc.modalPresentationStyle = .fullScreen
        vc.completion = { [weak self] granted in
            guard let self = self else { return }
            if !granted {
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: ConfigKeys.lastCustomPushRequest)
            }
            self.openWebView(savedURL)
        }
        present(vc, animated: true)
    }
    
    // MARK: - Navigation
    private func openWebView(_ urlString: String) {
        // Проверяем, что URL валиден
        guard let _ = URL(string: urlString) else { return }
        stopSpinAnimation()
        // Инициализируем WebViewController с нужным URL
        let webVC = WebViewController(url: urlString)
        
        // Полноэкранная презентация
        webVC.modalPresentationStyle = .fullScreen
        webVC.modalTransitionStyle = .coverVertical
        
        // Запускаем модально
        present(webVC, animated: true)
    }
    
    private func startGame() {
        print("🎮 Запуск игры")
        stopSpinAnimation()
        self.openWebView("https://play.unity.com/api/v1/games/game/10e67e7c-11b1-4756-babf-3ff6c8fbad93/build/latest/frame")
    }
    
    // MARK: - Network Monitoring
    private func startNetworkMonitoring() {
        NetworkMonitor.shared.startMonitoring()
        
        NetworkMonitor.shared.onStatusChange = { [weak self] isConnected in
            guard let self = self else { return }
            
            if isConnected {
                // Интернет восстановлен - закрываем NoInternetViewController
                self.dismissNoInternetViewController()
            } else {
                // Интернет пропал - показываем NoInternetViewController
                self.showNoInternetViewController()
            }
        }
        
        // Проверяем текущее состояние при старте
        if !NetworkMonitor.shared.isConnected {
            showNoInternetViewController()
        }
    }
    
    private func showNoInternetViewController() {
        // Если уже показан, не показываем повторно
        guard noInternetVC == nil else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "NoInternetViewController") as? NoInternetViewController else {
            return
        }
        
        vc.modalPresentationStyle = .fullScreen
        noInternetVC = vc
        
        // Показываем поверх всего, что открыто
        if let topVC = getTopViewController() {
            topVC.present(vc, animated: true)
        }
    }
    
    private func dismissNoInternetViewController() {
        guard let vc = noInternetVC else { return }
        
        vc.dismiss(animated: true) { [weak self] in
            self?.noInternetVC = nil
        }
    }
    
    private func getTopViewController() -> UIViewController? {
        var topVC: UIViewController = self
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        return topVC
    }
    
    func startSpinAnimation() {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = NSNumber(value: Double.pi * 2) // полный оборот (360°)
        rotation.duration = 1.0 // длительность одного оборота в секундах
        rotation.repeatCount = .infinity // бесконечное повторение
        spinView.layer.add(rotation, forKey: "spinAnimation")
    }

    func stopSpinAnimation() {
        spinView.layer.removeAnimation(forKey: "spinAnimation")
    }
}

// MARK: - UnsafeSessionDelegate
class UnsafeSessionDelegate: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

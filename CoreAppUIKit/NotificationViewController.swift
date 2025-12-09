import UIKit
import UserNotifications

class NotificationViewController: UIViewController {

    @IBOutlet weak var acceptButtonView: UIView!
    @IBOutlet weak var skipButtonView: UIView!
    
    var completion: ((Bool) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let acceptGesture = UITapGestureRecognizer(target: self, action: #selector(acceptTapped))
        acceptButtonView.addGestureRecognizer(acceptGesture)
        acceptButtonView.isUserInteractionEnabled = true
        
        let skipGesture = UITapGestureRecognizer(target: self, action: #selector(skipTapped))
        skipButtonView.addGestureRecognizer(skipGesture)
        skipButtonView.isUserInteractionEnabled = true
        
        acceptButtonView.layer.cornerRadius = 10
    }
    
    @objc func acceptTapped() {
        print("acceptTapped")
        requestSystemPushPermission { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true) {
                self.completion?(true) // ✅ согласие
            }
        }
    }
    
    @objc func skipTapped() {
        print("skipTapped")
        dismiss(animated: true) {
            self.completion?(false) // ❌ отказ
        }
    }
    
    private func requestSystemPushPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                print("📲 Системный пуш запрос: \(granted)")
                UIApplication.shared.registerForRemoteNotifications()
                completion()
            }
        }
    }
}

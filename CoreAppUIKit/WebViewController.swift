//
//  WebViewController.swift
//

import UIKit
import WebKit
import UniformTypeIdentifiers

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIDocumentPickerDelegate {
    
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    private var loadTimeoutWorkItem: DispatchWorkItem?
    private var fileUploadCompletionHandler: (([URL]?) -> Void)?
    private var targetURL: String
    private var lastSuccessfulURL: String = ""  // последний успешно загруженный URL
    private var loadAttempts = 0
    private var maxLoadAttempts = 5
    private var lastUrls: [String] = []
    
    init(url: String) {
        self.targetURL = url
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let config = WKWebViewConfiguration()
        config.preferences.javaScriptEnabled = true
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            config.mediaTypesRequiringUserActionForPlayback = []
        }
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.isHidden = true // Скрываем до тех пор, пока контент не подтвердит загрузку
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        // 1. Отключаем автоматическую корректировку
        webView.scrollView.contentInsetAdjustmentBehavior = .never
          
          // 2. Настраиваем dismiss mode
        webView.scrollView.keyboardDismissMode = .interactive
          
          view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
          
          // 3. Используем safeAreaLayoutGuide с отступами
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
          
          // 4. Настраиваем инсеты для скролла
        webView.scrollView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: view.safeAreaInsets.bottom,
            right: 0
        )
        // настраиваем индикатор загрузки
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        activityIndicator.startAnimating()

        // чистим userAgent
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            if let ua = result as? String {
                self?.webView.customUserAgent = ua.replacingOccurrences(of: "; wv", with: "")
                    .replacingOccurrences(of: " Version/4.0", with: "")
            }
            self?.startLoadWithTimeout(urlString: self?.targetURL ?? "")
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("🎬 ViewController appeared")
        print("👁️ View frame: \(view.frame)")
        print("👁️ WebView frame: \(webView.frame)")
    }
    
    // MARK: - Loader
    private func loadWebView(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        loadAttempts += 1
        print("🌐 Загружаем URL (попытка \(loadAttempts)): \(url.absoluteString)")
        print("💾 Последний успешный URL: \(lastSuccessfulURL)")
        
        var request = URLRequest(url: url)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        
        webView.load(request)
    }

    private func startLoadWithTimeout(urlString: String) {
        // отменяем предыдущий таймаут
        loadTimeoutWorkItem?.cancel()

        // запланировать таймаут на случай, если контент никогда не загрузится
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            print("⏱️ Таймаут загрузки — контент не подтвердил готовность")
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                // Оставляем webView скрытым, можно показать сообщение пользователю
                let alert = UIAlertController(title: "Ошибка загрузки",
                                              message: "Не удалось загрузить содержимое страницы.",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
        loadTimeoutWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 12.0, execute: workItem)

        // начинаем загрузку
        loadWebView(urlString: urlString)
    }
    
    private func checkWebViewContent() {
        // Проверяем размер контента
        webView.evaluateJavaScript("document.body.scrollHeight") { result, error in
            if let height = result as? Int {
                print("📏 Высота контента: \(height)px")
                if height == 0 {
                    print("⚠️ Контент пустой, пробуем обновить")
                    DispatchQueue.main.async { [weak self] in
                        self?.webView.reload()
                    }
                }
            }
        }
        
        // Проверяем HTML
        webView.evaluateJavaScript("document.documentElement.outerHTML.length") { result, error in
            if let length = result as? Int {
                print("📄 Размер HTML: \(length) символов")
                if length < 100 {
                    print("⚠️ HTML слишком короткий, возможно пустая страница")
                }
            }
        }
        
        // Проверяем видимость WebView
        print("👁️ WebView frame: \(webView.frame)")
        print("👁️ WebView hidden: \(webView.isHidden)")
        print("👁️ WebView alpha: \(webView.alpha)")
        
        // Принудительно обновляем layout
        DispatchQueue.main.async { [weak self] in
            self?.webView.setNeedsLayout()
            self?.webView.layoutIfNeeded()
            self?.view.setNeedsLayout()
            self?.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Keyboard
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        webView.scrollView.contentInset.bottom = frame.height
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        webView.scrollView.contentInset.bottom = 0
    }
    
    // MARK: - Navigation delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let urlStr = navigationAction.request.url?.absoluteString else {
            decisionHandler(.allow)
            return
        }
        
        print("➡️ Navigation: \(navigationAction.navigationType.rawValue) - \(urlStr)")
        lastSuccessfulURL = urlStr
        // Проверяем localhost
        if urlStr.starts(with: "https://localhost") {
            print("⚠️ Перехват перехода на https://localhost")
            decisionHandler(.cancel)
            return
        }
        
        // Очищаем куки если нужно
        if urlStr.contains("sub_id_2=99999") {
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                cookies.forEach { WKWebsiteDataStore.default().httpCookieStore.delete($0) }
            }
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if let url = webView.url?.absoluteString {
            print("🚀 Начинаем загрузку: \(url)")
        }
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        // Сохраняем URL как только начинается загрузка контента (это значит редирект прошел успешно)
        if let currentURL = webView.url?.absoluteString {
            //lastSuccessfulURL = currentURL
           // lastUrls.append(lastSuccessfulURL)
            print("💾 Сохранили успешный URL: \(lastSuccessfulURL)")
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Проверяем, действительно ли содержимое загружено и готово к показу
        webView.evaluateJavaScript("document.readyState") { [weak self] result, _ in
            guard let self = self else { return }
            let ready = result as? String ?? ""
            print("📘 document.readyState = \(ready)")

            // Проверяем размеры и длину HTML как дополнительную валидацию
            self.webView.evaluateJavaScript("document.body.scrollHeight") { heightResult, _ in
                let height = (heightResult as? Int) ?? 0
                self.webView.evaluateJavaScript("document.documentElement.outerHTML.length") { lengthResult, _ in
                    let length = (lengthResult as? Int) ?? 0
                    print("📏 Высота: \(height)px, HTML length: \(length)")

                    // Критерии достаточности: readyState == 'complete' и либо height>0 либо length>150
                    if ready == "complete" && (height > 0 || length > 150) {
                        self.showWebViewContent()
                    } else {
                        // Если page не готова — попробуем ещё раз немного позднее
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            // ещё одна попытка проверки
                            self.webView.evaluateJavaScript("document.readyState") { r2, _ in
                                let ready2 = r2 as? String ?? ""
                                if ready2 == "complete" {
                                    self.showWebViewContent()
                                } else {
                                    print("⚠️ Страница не готова после didFinish — оставляем скрытой и ждём таймаута")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func showWebViewContent() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            // отменяем таймаут
            self.loadTimeoutWorkItem?.cancel()
            self.loadTimeoutWorkItem = nil

            self.activityIndicator.stopAnimating()
            // Анимированно показываем webView
            self.webView.alpha = 0.0
            self.webView.isHidden = false
            UIView.animate(withDuration: 0.25) {
                self.webView.alpha = 1.0
            }
            print("✅ WebView показан — контент подтверждён")
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let nsError = error as NSError
        print("❌ didFailProvisionalNavigation: \(error.localizedDescription) (код: \(nsError.code))")
        
        // Обрабатываем ошибку редиректов
        if nsError.code == -1007 { // too many redirects
            if loadAttempts < maxLoadAttempts && !lastSuccessfulURL.isEmpty {
                print("🔄 Ошибка редиректов, возвращаемся к последнему успешному URL через 2 секунды")
                print("🔙 Используем: \(lastSuccessfulURL)")
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self else { return }
                    // Очищаем данные перед повторной загрузкой
                    WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
                        cookies.forEach { WKWebsiteDataStore.default().httpCookieStore.delete($0) }
                        DispatchQueue.main.async {
                            self.loadWebView(urlString: self.lastSuccessfulURL)
                        }
                    }
                }
            }
        }
        // Другие ошибки
        else if nsError.code == -1001 || nsError.code == -1009 { // таймаут или нет интернета
            if loadAttempts < maxLoadAttempts {
                print("🔄 Критическая ошибка, повторяем попытку через 5 секунд")
                let urlToLoad = !lastSuccessfulURL.isEmpty ? lastSuccessfulURL : targetURL
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                    self?.loadWebView(urlString: urlToLoad)
                }
            }
        }
    }

    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("❌ didFail navigation: \(error.localizedDescription)")
    }
    
    // MARK: - UIDelegate (popups, file uploads)
    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        dismiss(animated: true)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        present(alert, animated: true)
    }
    
    func webView(_ webView: WKWebView,
                 runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })
        present(alert, animated: true)
    }
    
    // MARK: - File upload
    func webView(_ webView: WKWebView,
                 runOpenPanelWith completionHandler: @escaping ([URL]?) -> Void) {
        fileUploadCompletionHandler = completionHandler
        let types: [UTType] = [.image, .pdf, .plainText, .spreadsheet, .presentation, .zip]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types, asCopy: true)
        picker.delegate = self
        picker.allowsMultipleSelection = false
        present(picker, animated: true)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        fileUploadCompletionHandler?(urls)
        fileUploadCompletionHandler = nil
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        fileUploadCompletionHandler?(nil)
        fileUploadCompletionHandler = nil
    }
    
    // MARK: - Rotation
    override var shouldAutorotate: Bool { true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .all }
    
    // MARK: - Cleanup
    deinit {
        loadTimeoutWorkItem?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
}

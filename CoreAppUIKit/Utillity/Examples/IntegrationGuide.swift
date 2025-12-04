//
//  IntegrationGuide.swift
//  ScreamAndRush Module
//

/*
 
 РУКОВОДСТВО ПО ИНТЕГРАЦИИ МОДУЛЯ SCREAM AND RUSH
 
 ═══════════════════════════════════════════════════════════════
 
 1. КОПИРОВАНИЕ МОДУЛЯ В ВАШ ПРОЕКТ
 ═══════════════════════════════════════════════════════════════
 
 Скопируйте папку ScreamAndRush в ваш проект:
 
 YourProject/
 ├── ScreamAndRush/           ← Вся папка модуля
 │   ├── Models/
 │   ├── ViewModels/
 │   ├── Views/
 │   ├── Services/
 │   └── Utilities/
 └── YourApp/
     └── ContentView.swift
 
 ═══════════════════════════════════════════════════════════════
 
 2. НАСТРОЙКА INFO.PLIST
 ═══════════════════════════════════════════════════════════════
 
 Добавьте необходимые разрешения в Info.plist вашего проекта:
 
 <key>NSMicrophoneUsageDescription</key>
 <string>Приложение использует микрофон для измерения уровня шума</string>
 
 <key>NSLocationWhenInUseUsageDescription</key>
 <string>Приложение использует геолокацию для отметки точек измерения на карте</string>
 
 ═══════════════════════════════════════════════════════════════
 
 3. БАЗОВОЕ ИСПОЛЬЗОВАНИЕ
 ═══════════════════════════════════════════════════════════════
 
 import SwiftUI
 
 struct ContentView: View {
     @State private var showScreamAndRush = false
     
     var body: some View {
         Button("Открыть Scream and Rush") {
             showScreamAndRush = true
         }
         .sheet(isPresented: $showScreamAndRush) {
             ScreamAndRushMainView()
         }
     }
 }
 
 ═══════════════════════════════════════════════════════════════
 
 4. РАСШИРЕННОЕ ИСПОЛЬЗОВАНИЕ С КОНФИГУРАЦИЕЙ
 ═══════════════════════════════════════════════════════════════
 
 ScreamAndRushMainView(
     config: ScreamAndRushConfig(
         measurementDuration: 10.0,      // Длительность измерения в секундах
         quietThreshold: 40.0,            // Порог "тихо" в дБ
         moderateThreshold: 70.0,         // Порог "умеренно" в дБ
         enableARMode: false,             // AR режим (будущая функция)
         enableExport: true,              // Экспорт данных
         enableHistory: true              // История измерений
     )
 )
 
 ═══════════════════════════════════════════════════════════════
 
 5. РАЗЛИЧНЫЕ СПОСОБЫ ПРЕДСТАВЛЕНИЯ
 ═══════════════════════════════════════════════════════════════
 
 // Sheet (модальное окно)
 .sheet(isPresented: $showModule) {
     ScreamAndRushMainView()
 }
 
 // FullScreenCover (полноэкранное окно)
 .fullScreenCover(isPresented: $showModule) {
     ScreamAndRushMainView()
 }
 
 // NavigationLink (навигация)
 NavigationLink {
     ScreamAndRushMainView()
 } label: {
     Text("Открыть модуль")
 }
 
 ═══════════════════════════════════════════════════════════════
 
 6. ДОСТУП К ДАННЫМ ИЗМЕРЕНИЙ ИЗ ВАШЕГО КОДА
 ═══════════════════════════════════════════════════════════════
 
 // Создайте экземпляр сервиса хранения
 let storageService = DataStorageService()
 
 // Получите все измерения
 let allMeasurements = storageService.measurements
 
 // Получите последние 3 измерения
 let recent = storageService.getRecentMeasurements(limit: 3)
 
 // Получите индекс тишины за сегодня
 if let quietIndex = storageService.getTodayQuietIndex() {
     print("Средний уровень шума сегодня: \(quietIndex) дБ")
 }
 
 // Экспортируйте данные в CSV
 let csvData = storageService.exportToCSV()
 
 ═══════════════════════════════════════════════════════════════
 
 7. КАСТОМИЗАЦИЯ ЦВЕТОВ
 ═══════════════════════════════════════════════════════════════
 
 Вы можете изменить цвета в файле Utilities/ColorExtensions.swift:
 
 extension Color {
     static let quietBird = Color.blue     // Цвет для тихих зон
     static let moderateBird = Color.yellow // Цвет для умеренных зон
     static let loudBird = Color.red        // Цвет для шумных зон
 }
 
 ═══════════════════════════════════════════════════════════════
 
 8. ТРЕБОВАНИЯ
 ═══════════════════════════════════════════════════════════════
 
 - iOS 16.0+
 - Swift 5.9+
 - Xcode 15.0+
 - SwiftUI
 
 ═══════════════════════════════════════════════════════════════
 
 9. АРХИТЕКТУРА МОДУЛЯ
 ═══════════════════════════════════════════════════════════════
 
 Models/
 ├── NoiseMeasurement.swift        - Модель измерения шума
 └── ScreamAndRushConfig.swift     - Конфигурация модуля
 
 ViewModels/
 └── ScreamAndRushViewModel.swift  - Основная бизнес-логика
 
 Views/
 ├── ScreamAndRushMainView.swift   - Точка входа
 ├── HomeScreenView.swift          - Главный экран
 ├── MeasurementScreenView.swift   - Экран измерения
 ├── ResultScreenView.swift        - Экран результата
 ├── MapScreenView.swift           - Карта
 └── HistoryScreenView.swift       - История
 
 Services/
 ├── AudioMeasurementService.swift - Сервис измерения звука
 ├── LocationService.swift         - Сервис геолокации
 └── DataStorageService.swift      - Сервис хранения данных
 
 Utilities/
 ├── ColorExtensions.swift         - Расширения цветов
 └── DateExtensions.swift          - Расширения дат
 
 ═══════════════════════════════════════════════════════════════
 
 10. КОНФИДЕНЦИАЛЬНОСТЬ
 ═══════════════════════════════════════════════════════════════
 
 - Модуль НЕ сохраняет аудиофайлы
 - Сохраняются только численные значения (дБ) и координаты
 - Все данные хранятся локально на устройстве
 - Данные анонимны
 
 ═══════════════════════════════════════════════════════════════
 
 */

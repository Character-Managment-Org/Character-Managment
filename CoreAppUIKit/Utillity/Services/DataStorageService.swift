//
//  DataStorageService.swift
//  ScreamAndRush Module
//

import Foundation

/// Сервис для хранения данных измерений
@MainActor
public class DataStorageService: ObservableObject {
    @Published public var measurements: [NoiseMeasurement] = []
    
    private let userDefaults = UserDefaults.standard
    private let measurementsKey = "screamAndRush_measurements"
    
    public init() {
        loadMeasurements()
    }
    
    /// Сохранить новое измерение
    public func saveMeasurement(_ measurement: NoiseMeasurement) {
        measurements.insert(measurement, at: 0)
        persistMeasurements()
    }
    
    /// Удалить измерение
    public func deleteMeasurement(_ measurement: NoiseMeasurement) {
        measurements.removeAll { $0.id == measurement.id }
        persistMeasurements()
    }
    
    /// Получить последние N измерений
    public func getRecentMeasurements(limit: Int = 3) -> [NoiseMeasurement] {
        Array(measurements.prefix(limit))
    }
    
    /// Получить индекс тишины за день (среднее значение дБ)
    public func getTodayQuietIndex() -> Double? {
        let today = Calendar.current.startOfDay(for: Date())
        let todayMeasurements = measurements.filter {
            Calendar.current.isDate($0.timestamp, inSameDayAs: today)
        }
        
        guard !todayMeasurements.isEmpty else { return nil }
        
        let total = todayMeasurements.reduce(0.0) { $0 + $1.decibelLevel }
        return total / Double(todayMeasurements.count)
    }
    
    /// Экспортировать данные в CSV
    public func exportToCSV() -> String {
        var csv = "Дата,Время,Широта,Долгота,Уровень (дБ),Категория,Адрес\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        
        for measurement in measurements {
            let date = dateFormatter.string(from: measurement.timestamp)
            let time = timeFormatter.string(from: measurement.timestamp)
            let lat = String(format: "%.6f", measurement.location.latitude)
            let lon = String(format: "%.6f", measurement.location.longitude)
            let db = String(format: "%.1f", measurement.decibelLevel)
            let category = measurement.noiseCategory.description
            let address = measurement.location.address ?? "N/A"
            
            csv += "\(date),\(time),\(lat),\(lon),\(db),\(category),\"\(address)\"\n"
        }
        
        return csv
    }
    
    /// Очистить все данные
    public func clearAllData() {
        measurements.removeAll()
        persistMeasurements()
    }
    
    // MARK: - Private Methods
    
    private func loadMeasurements() {
        guard let data = userDefaults.data(forKey: measurementsKey) else { return }
        
        do {
            measurements = try JSONDecoder().decode([NoiseMeasurement].self, from: data)
        } catch {
            print("Ошибка загрузки данных: \(error.localizedDescription)")
        }
    }
    
    private func persistMeasurements() {
        do {
            let data = try JSONEncoder().encode(measurements)
            userDefaults.set(data, forKey: measurementsKey)
        } catch {
            print("Ошибка сохранения данных: \(error.localizedDescription)")
        }
    }
}

//
//  AudioMeasurementService.swift
//  ScreamAndRush Module
//

import Foundation
import AVFoundation

/// Сервис для измерения уровня шума через микрофон
@MainActor
public class AudioMeasurementService: NSObject, ObservableObject {
    @Published public var currentDecibels: Double = 0.0
    @Published public var isRecording: Bool = false
    @Published public var averageDecibels: Double = 0.0
    
    private var audioRecorder: AVAudioRecorder?
    private var measurementTimer: Timer?
    private var decibelReadings: [Double] = []
    private let updateInterval: TimeInterval = 0.1
    
    public override init() {
        super.init()
        setupAudioSession()
    }
    
    /// Настройка аудио сессии
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.record, mode: .measurement)
            try session.setActive(true)
        } catch {
            print("Ошибка настройки аудио сессии: \(error.localizedDescription)")
        }
    }
    
    /// Запросить разрешение на использование микрофона
    public func requestMicrophonePermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
    
    /// Начать измерение
    public func startMeasurement(duration: TimeInterval, completion: @escaping (Double) -> Void) {
        guard !isRecording else { return }
        
        decibelReadings.removeAll()
        
        // Создаем временный файл для записи
        let audioFilename = getTemporaryAudioFileURL()
        
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
            
            isRecording = true
            
            // Таймер для обновления уровня дБ
            measurementTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
                self?.updateDecibels()
            }
            
            // Завершение измерения через заданную длительность
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.stopMeasurement(completion: completion)
            }
        } catch {
            print("Ошибка запуска записи: \(error.localizedDescription)")
            isRecording = false
        }
    }
    
    /// Обновить текущий уровень дБ
    private func updateDecibels() {
        audioRecorder?.updateMeters()
        
        guard let recorder = audioRecorder else { return }
        
        // Получаем уровень в дБ (-160 до 0)
        let power = recorder.averagePower(forChannel: 0)
        
        // Конвертируем в абсолютные дБ (приблизительно)
        // Нормализуем от -160..0 к 0..100+ дБ
        let normalizedDB = max(0, (power + 160) / 160 * 100)
        
        currentDecibels = Double(normalizedDB)
        decibelReadings.append(Double(normalizedDB))
    }
    
    /// Остановить измерение
    private func stopMeasurement(completion: @escaping (Double) -> Void) {
        measurementTimer?.invalidate()
        measurementTimer = nil
        
        audioRecorder?.stop()
        isRecording = false
        
        // Вычисляем среднее значение
        if !decibelReadings.isEmpty {
            averageDecibels = decibelReadings.reduce(0, +) / Double(decibelReadings.count)
        }
        
        // Удаляем временный файл (мы не сохраняем аудио)
        if let url = audioRecorder?.url {
            try? FileManager.default.removeItem(at: url)
        }
        
        completion(averageDecibels)
    }
    
    /// Получить URL временного файла
    private func getTemporaryAudioFileURL() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent(UUID().uuidString + ".m4a")
    }
    
    deinit {
        measurementTimer?.invalidate()
        audioRecorder?.stop()
    }
}

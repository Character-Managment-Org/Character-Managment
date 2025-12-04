//
//  NoiseMeasurement.swift
//  ScreamAndRush Module
//

import Foundation
import CoreLocation

/// Модель замера шума
public struct NoiseMeasurement: Identifiable, Codable {
    public let id: UUID
    public let timestamp: Date
    public let location: LocationData
    public let decibelLevel: Double
    public let duration: TimeInterval
    public let noiseCategory: NoiseCategory
    
    public init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        location: LocationData,
        decibelLevel: Double,
        duration: TimeInterval
    ) {
        self.id = id
        self.timestamp = timestamp
        self.location = location
        self.decibelLevel = decibelLevel
        self.duration = duration
        self.noiseCategory = NoiseCategory.from(decibelLevel: decibelLevel)
    }
}

/// Категория шума с ассоциированными цветами и иконками птиц
public enum NoiseCategory: String, Codable {
    case quiet      // Тихо (до 40 дБ)
    case moderate   // Умеренно (40-70 дБ)
    case loud       // Шумно (70+ дБ)
    
    public static func from(decibelLevel: Double) -> NoiseCategory {
        switch decibelLevel {
        case ..<40:
            return .quiet
        case 40..<70:
            return .moderate
        default:
            return .loud
        }
    }
    
    public var birdEmoji: String {
        switch self {
        case .quiet: return "🕊"
        case .moderate: return "🦜"
        case .loud: return "🦅"
        }
    }
    
    public var colorName: String {
        switch self {
        case .quiet: return "quietBird"
        case .moderate: return "moderateBird"
        case .loud: return "loudBird"
        }
    }
    
    public var description: String {
        switch self {
        case .quiet: return "Тихо"
        case .moderate: return "Умеренно"
        case .loud: return "Шумно"
        }
    }
}

/// Структура для хранения координат (Codable-совместимая)
public struct LocationData: Codable, Equatable {
    public let latitude: Double
    public let longitude: Double
    public let address: String?
    
    public init(latitude: Double, longitude: Double, address: String? = nil) {
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    public init(from coordinate: CLLocationCoordinate2D, address: String? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.address = address
    }
    
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

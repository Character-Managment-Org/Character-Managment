//
//  ScreamAndRushConfig.swift
//  ScreamAndRush Module
//

import Foundation

/// Конфигурация модуля Scream and Rush
public struct ScreamAndRushConfig {
    public let measurementDuration: TimeInterval
    public let quietThreshold: Double
    public let moderateThreshold: Double
    public let enableARMode: Bool
    public let enableExport: Bool
    public let enableHistory: Bool
    
    public init(
        measurementDuration: TimeInterval = 7.0,
        quietThreshold: Double = 40.0,
        moderateThreshold: Double = 70.0,
        enableARMode: Bool = false,
        enableExport: Bool = true,
        enableHistory: Bool = true
    ) {
        self.measurementDuration = measurementDuration
        self.quietThreshold = quietThreshold
        self.moderateThreshold = moderateThreshold
        self.enableARMode = enableARMode
        self.enableExport = enableExport
        self.enableHistory = enableHistory
    }
    
    public static let `default` = ScreamAndRushConfig()
}

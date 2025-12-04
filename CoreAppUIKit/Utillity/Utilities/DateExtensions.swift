//
//  DateExtensions.swift
//  ScreamAndRush Module
//

import Foundation

extension Date {
    /// Форматирование даты в относительный формат
    func relativeFormat() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.localizedString(for: self, relativeTo: Date())
    }
    
    /// Форматирование даты в стандартный формат
    func standardFormat() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: self)
    }
}

//
//  LocationService.swift
//  ScreamAndRush Module
//

import Foundation
import CoreLocation
import Contacts

/// Сервис для работы с геолокацией
@MainActor
public class LocationService: NSObject, ObservableObject {
    @Published public var currentLocation: CLLocationCoordinate2D?
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    public override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    /// Запросить разрешение на использование геолокации
    public func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Начать отслеживание локации
    public func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }
    
    /// Остановить отслеживание локации
    public func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    /// Получить текущую локацию один раз
    public func requestCurrentLocation() async -> CLLocationCoordinate2D? {
        return await withCheckedContinuation { continuation in
            let completionHandler: () -> Void = { [weak self] in
                continuation.resume(returning: self?.currentLocation)
            }
            
            if let location = currentLocation {
                continuation.resume(returning: location)
            } else {
                locationManager.requestLocation()
                // Ждем обновления или таймаут
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: completionHandler)
            }
        }
    }
    
    /// Получить адрес по координатам
    public func getAddress(for coordinate: CLLocationCoordinate2D) async -> String? {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return formatAddress(from: placemark)
            }
        } catch {
            print("Ошибка геокодирования: \(error.localizedDescription)")
        }
        
        return nil
    }
    
    /// Форматировать адрес из placemark
    private func formatAddress(from placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        
        if let street = placemark.thoroughfare {
            addressComponents.append(street)
        }
        if let city = placemark.locality {
            addressComponents.append(city)
        }
        
        return addressComponents.isEmpty ? "Неизвестное место" : addressComponents.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка получения локации: \(error.localizedDescription)")
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

//
//  HomeScreenView.swift
//  ScreamAndRush Module
//

import SwiftUI

/// Домашний экран
struct HomeScreenView: View {
    @ObservedObject var viewModel: ScreamAndRushViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Заголовок
                VStack(spacing: 10) {
                    Text("🪶 Scream and Rush")
                        .font(.system(size: 34, weight: .bold))
                    
                    Text("Картирование городского шума")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                // Индекс тишины дня
                QuietIndexCard(quietIndex: viewModel.getQuietIndex())
                
                // Кнопка замера
                Button(action: {
                    Task {
                        await viewModel.startMeasurement()
                    }
                }) {
                    HStack {
                        Image(systemName: "waveform.circle.fill")
                            .font(.title2)
                        Text("Замерить шум")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                .padding(.horizontal)
                
                // Последние измерения
                RecentMeasurementsSection(measurements: viewModel.storageService.getRecentMeasurements())
                
                // Навигационные кнопки
                HStack(spacing: 15) {
                    NavigationButton(
                        icon: "map.fill",
                        title: "Карта",
                        action: { viewModel.navigateToMap() }
                    )
                    
                    NavigationButton(
                        icon: "clock.fill",
                        title: "История",
                        action: { viewModel.navigateToHistory() }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Компоненты

struct QuietIndexCard: View {
    let quietIndex: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Индекс тишины сегодня")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(quietIndex)
                .font(.system(size: 48, weight: .bold))
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.7))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
    }
}

struct RecentMeasurementsSection: View {
    let measurements: [NoiseMeasurement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Последние измерения")
                .font(.headline)
                .padding(.horizontal)
            
            if measurements.isEmpty {
                Text("Пока нет измерений")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                ForEach(measurements) { measurement in
                    MeasurementRowView(measurement: measurement)
                }
            }
        }
    }
}

struct MeasurementRowView: View {
    let measurement: NoiseMeasurement
    
    var body: some View {
        HStack(spacing: 15) {
            Text(measurement.noiseCategory.birdEmoji)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(measurement.location.address ?? "Неизвестное место")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(formatDate(measurement.timestamp))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f дБ", measurement.decibelLevel))
                    .font(.headline)
                    .foregroundColor(colorForCategory(measurement.noiseCategory))
                
                Text(measurement.noiseCategory.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func colorForCategory(_ category: NoiseCategory) -> Color {
        switch category {
        case .quiet: return .green
        case .moderate: return .orange
        case .loud: return .red
        }
    }
}

struct NavigationButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                Text(title)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color.white.opacity(0.5))
            .cornerRadius(16)
        }
        .foregroundColor(.primary)
    }
}

#Preview {
    HomeScreenView(viewModel: ScreamAndRushViewModel())
}

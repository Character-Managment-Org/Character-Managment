//
//  ResultScreenView.swift
//  ScreamAndRush Module
//

import SwiftUI

/// Экран результата измерения
struct ResultScreenView: View {
    @ObservedObject var viewModel: ScreamAndRushViewModel
    @State private var birdOffset: CGFloat = -100
    @State private var showContent: Bool = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if let measurement = viewModel.latestMeasurement {
                // Анимация птицы
                Text(measurement.noiseCategory.birdEmoji)
                    .font(.system(size: 100))
                    .offset(y: birdOffset)
                    .onAppear {
                        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                            birdOffset = 0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                showContent = true
                            }
                        }
                    }
                
                if showContent {
                    // Результат
                    VStack(spacing: 15) {
                        Text("Измерение завершено!")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        // Уровень шума
                        VStack(spacing: 8) {
                            Text(String(format: "%.1f дБ", measurement.decibelLevel))
                                .font(.system(size: 56, weight: .bold))
                                .foregroundColor(colorForCategory(measurement.noiseCategory))
                            
                            Text(measurement.noiseCategory.description)
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(20)
                        
                        // Место и время
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                                Text(measurement.location.address ?? "Неизвестное место")
                                    .font(.subheadline)
                            }
                            
                            HStack {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(.blue)
                                Text(formatDate(measurement.timestamp))
                                    .font(.subheadline)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.3))
                        .cornerRadius(12)
                    }
                    .transition(.opacity.combined(with: .scale))
                    
                    // Кнопки действий
                    VStack(spacing: 12) {
                        Button(action: {
                            viewModel.navigateToMap()
                        }) {
                            HStack {
                                Image(systemName: "map.fill")
                                Text("Посмотреть на карте")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            Task {
                                await viewModel.startMeasurement()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Измерить ещё раз")
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.5))
                            .foregroundColor(.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            viewModel.navigateToHome()
                        }) {
                            Text("На главную")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func colorForCategory(_ category: NoiseCategory) -> Color {
        switch category {
        case .quiet: return .green
        case .moderate: return .orange
        case .loud: return .red
        }
    }
}

#Preview {
    ResultScreenView(viewModel: {
        let vm = ScreamAndRushViewModel()
        vm.latestMeasurement = NoiseMeasurement(
            location: LocationData(latitude: 55.7558, longitude: 37.6173, address: "Москва, Красная площадь"),
            decibelLevel: 65.5,
            duration: 7.0
        )
        return vm
    }())
}

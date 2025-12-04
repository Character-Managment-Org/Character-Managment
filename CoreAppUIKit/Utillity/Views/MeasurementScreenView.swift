//
//  MeasurementScreenView.swift
//  ScreamAndRush Module
//

import SwiftUI

/// Экран процесса измерения
struct MeasurementScreenView: View {
    @ObservedObject var viewModel: ScreamAndRushViewModel
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Заголовок
            Text("Измерение уровня шума...")
                .font(.title2)
                .fontWeight(.semibold)
            
            // Анимированный индикатор
            ZStack {
                // Внешний круг
                Circle()
                    .stroke(Color.blue.opacity(0.2), lineWidth: 20)
                    .frame(width: 250, height: 250)
                
                // Прогресс-круг
                Circle()
                    .trim(from: 0, to: viewModel.measurementProgress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.blue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.1), value: viewModel.measurementProgress)
                
                // Волновая анимация
                WaveformView(amplitude: viewModel.currentDecibels / 100)
                    .frame(width: 200, height: 200)
            }
            
            // Текущий уровень
            VStack(spacing: 8) {
                Text(String(format: "%.1f дБ", viewModel.currentDecibels))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                
                Text("Текущий уровень")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Прогресс-бар
            VStack(spacing: 8) {
                ProgressView(value: viewModel.measurementProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                    .scaleEffect(y: 2)
                
                Text("\(Int(viewModel.measurementProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 50)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Waveform View

struct WaveformView: View {
    let amplitude: Double
    @State private var phase: Double = 0
    
    let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Canvas { context, size in
            let midY = size.height / 2
            let width = size.width
            
            var path = Path()
            path.move(to: CGPoint(x: 0, y: midY))
            
            for x in stride(from: 0, through: width, by: 2) {
                let relativeX = x / width
                let sine = sin((relativeX * 4 * 3.14) + phase)
                let y = midY + (sine * CGFloat(amplitude) * 60)
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            context.stroke(
                path,
                with: .color(.blue),
                lineWidth: 3
            )
        }
        .onReceive(timer) { _ in
            phase += 0.5
            if phase > 2 * .pi {
                phase = 0
            }
        }
    }
}

#Preview {
    MeasurementScreenView(viewModel: ScreamAndRushViewModel())
}

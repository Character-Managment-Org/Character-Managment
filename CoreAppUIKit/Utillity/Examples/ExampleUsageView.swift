//
//  ExampleUsageView.swift
//  Example of using ScreamAndRush Module
//

import SwiftUI

/// Пример использования модуля в вашем приложении
struct ExampleUsageView: View {
    @State private var showScreamAndRush = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Моё приложение")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Способ 1: Открыть как Sheet
            Button("Открыть Scream and Rush (Sheet)") {
                showScreamAndRush = true
            }
            .buttonStyle(.borderedProminent)
            .sheet(isPresented: $showScreamAndRush) {
                ScreamAndRushMainView()
            }
            
            // Способ 2: Открыть как FullScreenCover
            Button("Открыть Scream and Rush (Full Screen)") {
                showScreamAndRush = true
            }
            .buttonStyle(.bordered)
            .fullScreenCover(isPresented: $showScreamAndRush) {
                ScreamAndRushMainView()
            }
            
            // Способ 3: С кастомной конфигурацией
            NavigationLink {
                ScreamAndRushMainView(
                    config: ScreamAndRushConfig(
                        measurementDuration: 10.0,
                        quietThreshold: 35.0,
                        moderateThreshold: 65.0,
                        enableARMode: false,
                        enableExport: true,
                        enableHistory: true
                    )
                )
            } label: {
                Text("Открыть с кастомной конфигурацией")
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - SwiftUI App Example


struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ExampleUsageView()
        }
    }
}

#Preview {
    ExampleUsageView()
}

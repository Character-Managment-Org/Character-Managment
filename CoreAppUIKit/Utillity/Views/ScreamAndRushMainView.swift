//
//  ScreamAndRushMainView.swift
//  ScreamAndRush Module
//

import SwiftUI

/// Главная точка входа в модуль Scream and Rush
public struct ScreamAndRushMainView: View {
    @StateObject private var viewModel: ScreamAndRushViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(config: ScreamAndRushConfig = .default) {
        _viewModel = StateObject(wrappedValue: ScreamAndRushViewModel(config: config))
    }
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Фоновый градиент
                LinearGradient(
                    colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.2)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Контент в зависимости от текущего экрана
                switch viewModel.currentScreen {
                case .home:
                    HomeScreenView(viewModel: viewModel)
                case .measuring:
                    MeasurementScreenView(viewModel: viewModel)
                case .result:
                    ResultScreenView(viewModel: viewModel)
                case .map:
                    MapScreenView(viewModel: viewModel)
                case .history:
                    HistoryScreenView(viewModel: viewModel)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if viewModel.currentScreen != .home && viewModel.currentScreen != .measuring {
                        Button("Назад") {
                            viewModel.navigateToHome()
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
            }
            .alert("Требуется разрешение", isPresented: $viewModel.showPermissionAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.permissionAlertMessage)
            }
        }
    }
}

#Preview {
    ScreamAndRushMainView()
}

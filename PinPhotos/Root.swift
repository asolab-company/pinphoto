import Photos
import SwiftUI
import UIKit

let onboardingShownKey = "onboardingShown"

enum AppRoute: Equatable {
    case loading
    case onboarding
    case menu
    case access
    case cleaning
    case done

}

struct RootView: View {
    @State private var route: AppRoute = .loading
    @State private var showSettingsAlert: Bool = false
    @State private var lastDeletedCount: Int = 0
    @State private var lastFreedBytes: Int64 = 0
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "7EDCF3"), Color(hex: "04AFD5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            currentScreen
        }
        .alert(
            "Allow photo access in Settings",
            isPresented: $showSettingsAlert
        ) {
            Button("Cancel", role: .cancel) {}
            Button("Open Settings") {
                openAppSettings()
            }
        } message: {
            Text(
                "To continue cleaning up your photos, please allow access to your photo library in Settings."
            )
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {

                if route == .access {
                    checkPhotoPermission()
                }
            }
        }
    }

    @ViewBuilder
    private var currentScreen: some View {
        switch route {
        case .loading:
            Preloading {
                let needsOnboarding = !UserDefaults.standard.bool(
                    forKey: onboardingShownKey
                )
                route = needsOnboarding ? .onboarding : .menu
            }

        case .onboarding:
            Welcome {
                UserDefaults.standard.set(true, forKey: onboardingShownKey)
                route = .menu
            }

        case .menu:
            Menu {
                checkPhotoPermission()
            }

        case .access:
            Access(
                onContinue: { requestPhotoAccess() },
                onBack: { route = .menu }
            )

        case .cleaning:
            Cleaning(
                onContinue: { deletedCount, freedBytes in
                    lastDeletedCount = deletedCount
                    lastFreedBytes = freedBytes
                    route = .done
                },
                onBack: { route = .menu }
            )

        case .done:
            Done(
                deletedCount: lastDeletedCount,
                freedBytes: lastFreedBytes
            ) {
                route = .menu
            }

        }
    }

    private func checkPhotoPermission() {
        let status = PHPhotoLibrary.authorizationStatus()

        switch status {
        case .authorized, .limited:
            route = .cleaning
        case .denied, .restricted:
            route = .access
        case .notDetermined:

            route = .access
        @unknown default:
            route = .access
        }
    }

    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized, .limited:
                    route = .cleaning
                case .denied, .restricted:

                    showSettingsAlert = true
                case .notDetermined:
                    break
                @unknown default:
                    break
                }
            }
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

#Preview {
    RootView()
}

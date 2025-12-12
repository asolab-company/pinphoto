import Combine
import Photos
import SwiftUI
import UIKit

struct Cleaning: View {

    var onContinue: (_ deletedCount: Int, _ freedBytes: Int64) -> Void = {
        _,
        _ in
    }
    var onBack: () -> Void = {}

    @StateObject private var photoProvider = CleaningPhotoProvider()

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showDelete: Bool = false

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {

                    HStack {
                        Button {
                            onBack()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(
                                    width: 32,
                                    height: 32,
                                    alignment: .leading
                                )
                        }

                        Spacer()

                        Text("Cleaning")
                            .foregroundColor(Color(hex: "FFFFFF"))
                            .font(.system(size: 16, weight: .bold))

                        Spacer()

                        Button {
                            showDelete = true
                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image("app_ic_deletegallery")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(Color(hex: "ffffff"))

                                if photoProvider.deletedAssets.count > 0 {
                                    Text("\(photoProvider.deletedAssets.count)")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.red)
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                            .frame(width: 32, height: 32, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "7EDCF3"),
                                Color(hex: "04AFD5"),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    Spacer()

                    ZStack {
                        if photoProvider.assets.isEmpty {
                            Text("No more photos")
                                .foregroundColor(.gray)
                                .font(.system(size: 16, weight: .medium))
                        } else {

                            let backgroundAssets = Array(
                                photoProvider.assets.dropLast().suffix(2)
                            )

                            ForEach(
                                Array(backgroundAssets.enumerated()),
                                id: \.element.localIdentifier
                            ) { index, asset in
                                PhotoAssetView(asset: asset)
                                    .frame(
                                        width: geo.size.width * 0.8,
                                        height: geo.size.height * 0.65
                                    )
                                    .cornerRadius(16)
                                    .shadow(radius: 4)
                                    .scaleEffect(0.95 - CGFloat(index) * 0.03)
                                    .offset(y: CGFloat(index + 1) * 12)
                            }

                            if let topAsset = photoProvider.assets.last {
                                PhotoAssetView(asset: topAsset)
                                    .id(topAsset.localIdentifier)
                                    .frame(
                                        width: geo.size.width * 0.8,
                                        height: geo.size.height * 0.65
                                    )
                                    .cornerRadius(16)
                                    .shadow(radius: 8)
                                    .offset(
                                        x: dragOffset.width,
                                        y: dragOffset.height
                                    )
                                    .rotationEffect(
                                        .degrees(Double(dragOffset.width / 15))
                                    )
                                    .gesture(
                                        DragGesture()
                                            .onChanged { value in
                                                dragOffset = value.translation
                                            }
                                            .onEnded { value in
                                                let threshold: CGFloat = 120
                                                let isLeftSwipe =
                                                    value.translation.width
                                                    <= -threshold
                                                let isRightSwipe =
                                                    value.translation.width
                                                    >= threshold

                                                if isLeftSwipe || isRightSwipe {
                                                    let direction: CGFloat =
                                                        isLeftSwipe ? -1 : 1

                                                    if isLeftSwipe,
                                                        let asset =
                                                            photoProvider.assets
                                                            .last
                                                    {
                                                        photoProvider
                                                            .deletedAssets
                                                            .append(asset)
                                                    }

                                                    withAnimation(
                                                        .spring(
                                                            response: 0.35,
                                                            dampingFraction:
                                                                0.85
                                                        )
                                                    ) {
                                                        dragOffset = CGSize(
                                                            width: direction
                                                                * 500,
                                                            height: 0
                                                        )
                                                    }

                                                    DispatchQueue.main
                                                        .asyncAfter(
                                                            deadline: .now()
                                                                + 0.22
                                                        ) {
                                                            goToNextPhoto()
                                                            dragOffset = .zero
                                                        }
                                                } else {

                                                    withAnimation(
                                                        .spring(
                                                            response: 0.3,
                                                            dampingFraction: 0.8
                                                        )
                                                    ) {
                                                        dragOffset = .zero
                                                    }
                                                }
                                            }
                                    )
                            }
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: geo.size.height * 0.7
                    )

                    Spacer()

                    HStack(spacing: 10) {

                        Button {
                            swipeLeftFromButton()
                        } label: {
                            Image("app_btn_delete")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                        }

                        Spacer()

                        Button {
                            let assetsToDelete = photoProvider.deletedAssets
                            guard !assetsToDelete.isEmpty else { return }

                            let totalSize = calculateTotalSize(
                                for: assetsToDelete
                            )
                            let count = assetsToDelete.count

                            PHPhotoLibrary.shared().performChanges({
                                PHAssetChangeRequest.deleteAssets(
                                    assetsToDelete as NSArray
                                )
                            }) { success, error in
                                DispatchQueue.main.async {
                                    if success {
                                        photoProvider.deletedAssets.removeAll()
                                        onContinue(count, totalSize)
                                    } else {

                                        onContinue(0, 0)
                                    }
                                }
                            }
                        } label: {
                            Text("Done")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(
                                        cornerRadius: 5,
                                        style: .continuous
                                    )
                                    .fill(Color.init(hex: "6EDAF5"))
                                )
                        }
                        .disabled(photoProvider.deletedAssets.isEmpty)
                        .opacity(
                            photoProvider.deletedAssets.isEmpty ? 0.5 : 1.0
                        )
                        Spacer()

                        Button {

                            swipeRightFromButton()
                        } label: {
                            Image("app_btn_check")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)

                        }
                    }.padding(.horizontal, 30)
                        .padding(.bottom)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    photoProvider.loadPhotosIfNeeded()
                }
            }
        }
        .fullScreenCover(isPresented: $showDelete) {
            Delete(
                onBack: { showDelete = false },
                assets: $photoProvider.deletedAssets
            )
        }
        .background(

            ZStack {
                Color(.white)
                    .ignoresSafeArea()

            }

        )
    }

    private func swipeLeftFromButton() {
        guard !photoProvider.assets.isEmpty else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = CGSize(width: -400, height: 0)
        }

        if let asset = photoProvider.assets.last {
            photoProvider.deletedAssets.append(asset)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            goToNextPhoto()
            dragOffset = .zero
        }
    }

    private func swipeRightFromButton() {
        guard !photoProvider.assets.isEmpty else { return }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            dragOffset = CGSize(width: 400, height: 0)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            goToNextPhoto()
            dragOffset = .zero
        }
    }

    private func goToNextPhoto() {
        guard !photoProvider.assets.isEmpty else { return }

        photoProvider.assets.removeLast()
    }

    private func calculateTotalSize(for assets: [PHAsset]) -> Int64 {
        var total: Int64 = 0

        for asset in assets {
            let resources = PHAssetResource.assetResources(for: asset)
            for resource in resources {
                if let fileSize = resource.value(forKey: "fileSize") as? CLong {
                    total += Int64(fileSize)
                }
            }
        }

        return total
    }
}

final class CleaningPhotoProvider: ObservableObject {
    @Published var assets: [PHAsset] = []
    @Published var deletedAssets: [PHAsset] = []
    private var isLoaded = false

    func loadPhotosIfNeeded() {
        guard !isLoaded else { return }
        isLoaded = true

        let status = PHPhotoLibrary.authorizationStatus()
        guard status == .authorized || status == .limited else {

            return
        }

        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        let result = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var tmp: [PHAsset] = []
        result.enumerateObjects { asset, _, _ in
            tmp.append(asset)
        }

        DispatchQueue.main.async {
            self.assets = tmp
        }
    }
}

struct PhotoAssetView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        ZStack {

            Color(.systemGray6)

            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false

        let targetSize = CGSize(width: 1200, height: 1200)

        manager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: options
        ) { image, _ in
            if let image {
                self.image = image
            }
        }
    }
}

#Preview {
    Cleaning()
}

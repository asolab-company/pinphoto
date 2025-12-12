import Photos
import SwiftUI
import UIKit

struct Delete: View {
    var onBack: () -> Void = {}
    @Binding var assets: [PHAsset]

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

                        Text("Delete")
                            .foregroundColor(Color(hex: "FFFFFF"))
                            .font(.system(size: 16, weight: .bold))

                        Spacer()

                        Button {

                        } label: {
                            ZStack(alignment: .topTrailing) {
                                Image("app_ic_deletegallery")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 26, height: 26)
                                    .foregroundColor(Color(hex: "ffffff"))

                            }
                            .frame(width: 32, height: 32, alignment: .trailing)
                            .opacity(0)
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

                    ScrollView {
                        let tileSize = (geo.size.width - 16 - 2 * 4) / 3
                        let columns = Array(
                            repeating: GridItem(.fixed(tileSize), spacing: 4),
                            count: 3
                        )

                        LazyVGrid(columns: columns, spacing: 4) {
                            ForEach(assets, id: \.localIdentifier) { asset in
                                ZStack {
                                    GridAssetView(asset: asset)
                                        .clipped()

                                    Circle()
                                        .fill(Color.black.opacity(0.35))
                                        .frame(width: 40, height: 40)

                                    Image(systemName: "clock.arrow.circlepath")
                                        .font(
                                            .system(size: 20, weight: .medium)
                                        )
                                        .foregroundColor(.white)
                                }
                                .frame(width: tileSize, height: tileSize)
                                .clipped()
                                .onTapGesture {

                                    let id = asset.localIdentifier
                                    if let index = assets.firstIndex(where: {
                                        $0.localIdentifier == id
                                    }) {
                                        assets.remove(at: index)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                    }

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(

            ZStack {
                Color(.white)
                    .ignoresSafeArea()

            }

        )
    }
}

struct GridAssetView: View {
    let asset: PHAsset
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Color(.systemGray5)
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

        let targetSize = CGSize(width: 600, height: 600)

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
    Delete(onBack: {}, assets: .constant([]))
}

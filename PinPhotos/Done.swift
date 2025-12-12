import Foundation
import SwiftUI

struct Done: View {
    var deletedCount: Int
    var freedBytes: Int64
    var onDone: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {

                    HStack {

                        VStack {
                            Text("You cleaned")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 24 : 26,
                                        weight: .heavy
                                    )
                                )

                            Text(formattedFreedSpace)
                                .foregroundColor(Color(hex: "00596D"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 48 : 56,
                                        weight: .heavy
                                    )
                                )
                        }

                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    VStack(spacing: 5) {

                        Group {

                            Text(
                                "👏 Nice swiping! You deleted \(deletedCount) photos and saved \(formattedFreedSpace)."
                            )
                            .foregroundColor(Color(hex: "000000"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 12 : 14,
                                    weight: .regular
                                )
                            )
                            .lineSpacing(6)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom)

                        Button(action: { onDone() }) {
                            ZStack {
                                Text("Continue")
                                    .font(.system(size: 24, weight: .bold))
                                HStack {
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(
                                            .system(size: 18, weight: .bold)
                                        )
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 14)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(BtnStyle(height: Device.isSmall ? 40 : 60))

                    }
                    .padding(.horizontal, 30)
                    .padding(.vertical)
                    .background(
                        Color(Color.init(hex: "F7F7F7"))
                            .ignoresSafeArea()
                    )

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(

            ZStack {
                Color(.black)
                    .ignoresSafeArea()

                Image("done_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }

        )
    }

    private var formattedFreedSpace: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: freedBytes)
    }
}

#Preview {
    Done(
        deletedCount: 120,
        freedBytes: 378 * 1024 * 1024,
        onDone: {}
    )
}

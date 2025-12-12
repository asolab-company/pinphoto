import SwiftUI

struct Menu: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {

                    HStack {
                        Text("Clean your gallery in a fun way.")
                            .foregroundColor(Color(hex: "ffffff"))
                            .font(
                                .system(
                                    size: Device.isSmall ? 24 : 26,
                                    weight: .heavy
                                )
                            )

                        Spacer()

                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    VStack(spacing: 5) {

                        Group {

                            Text(
                                "Open the app and allow access to your photos. Swipe left to delete or right to keep. Clean your gallery in seconds — it’s that simple! ✨"
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

                        Button(action: { onContinue() }) {
                            ZStack {
                                Text("Start Cleaning")
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

                Image("bg_menu")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            }

        )
    }
}

#Preview {
    Menu()
}

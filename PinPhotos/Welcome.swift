import SwiftUI

struct Welcome: View {
    var onContinue: () -> Void = {}

    var body: some View {
        ZStack(alignment: .top) {

            GeometryReader { geo in
                VStack {
                    Spacer()

                    VStack(spacing: 5) {

                        Group {
                            Text("Clean your gallery in seconds! 🧹")
                                .foregroundColor(Color(hex: "ffffff"))
                                .font(
                                    .system(
                                        size: Device.isSmall ? 28 : 32,
                                        weight: .heavy
                                    )
                                )

                            Text(
                                "Quickly swipe left ⬅️ to delete unwanted photos or swipe right ➡️ to keep the ones you love ❤️. Free up storage 💾, organize your memories 🖼️, and make your photo library simple and tidy ✨ — all with just a few swipes."
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
                        .padding(.bottom, 8)

                        TermsFooter().padding(
                            .bottom,
                            Device.isSmall ? 20 : 60
                        )
                    }
                    .padding(.horizontal, 30)

                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }.ignoresSafeArea()
            .background(

                ZStack {
                    Color(.black)
                        .ignoresSafeArea()

                    Image("bg_welcome")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea()
                }

            )
    }
}

private struct TermsFooter: View {
    var body: some View {
        VStack(spacing: 2) {
            Text("By Proceeding You Accept")
                .foregroundColor(Color.init(hex: "54585A"))
                .font(.footnote)

            HStack(spacing: 0) {
                Text("Our ")
                    .foregroundColor(Color.init(hex: "54585A"))
                    .font(.footnote)

                Link("Terms Of Use", destination: Data.terms)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "#E60000"))

                Text(" And ")
                    .foregroundColor(Color.init(hex: "54585A"))
                    .font(.footnote)

                Link("Privacy Policy", destination: Data.policy)
                    .font(.footnote)
                    .foregroundColor(Color.init(hex: "#E60000"))

            }
        }
        .frame(maxWidth: .infinity)
        .multilineTextAlignment(.center)
    }
}

#Preview {
    Welcome {
        print("Finished")
    }
}

import SwiftUI

struct Access: View {
    var onContinue: () -> Void = {}
    var onBack: () -> Void = {}

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
                        }

                        Spacer()

                        Text("Allow access to your photos?")
                            .foregroundColor(Color(hex: "FFFFFF"))
                            .font(
                                .system(
                                    size: 16,
                                    weight: .bold
                                )
                            )

                        Spacer()

                        Button {

                        } label: {
                            Image(systemName: "gearshape.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color(hex: "ffffff"))
                        }.opacity(0)
                    }
                    .padding(.horizontal, 30)

                    Spacer()

                    VStack(spacing: 5) {

                        Text("Allow access to your photos?")
                            .foregroundColor(Color(hex: "000000"))
                            .font(
                                .system(
                                    size: 24,
                                    weight: .bold
                                )
                            )
                            .lineSpacing(5)

                            .padding(.bottom)

                        Button(action: { onContinue() }) {
                            ZStack {
                                Text("Allow Access to All Photos")
                                    .font(.system(size: 20, weight: .bold))

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
    Access()
}

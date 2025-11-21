import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            VStack {
                Image("AppIconSplash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 180)
                Text("Dating App")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 16)
            }
        }
    }
}

#Preview {
    SplashScreenView()
}

import SwiftUI

struct LaunchScreen: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color("PrimaryOrange"), Color("WarmSand")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            VStack(spacing: 30) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                Text("Buildplate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text("Your personalized meal planning companion")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}

#Preview {
    LaunchScreen()
} 
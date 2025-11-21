import SwiftUI

struct LikeDislikeButton: View {
    let systemName: String
    let color: Color
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundColor(color)
        }
    }
}

#Preview {
    HStack {
        LikeDislikeButton(systemName: "xmark.circle.fill", color: .red, action: {})
        LikeDislikeButton(systemName: "heart.circle.fill", color: .green, action: {})
    }
}

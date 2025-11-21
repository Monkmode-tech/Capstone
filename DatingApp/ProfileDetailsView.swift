import SwiftUI

struct ProfileDetailsView: View {
    let imageUrl: String
    let photographer: String
    let alt: String
    let imageHeight: CGFloat
    var isHistory: Bool = false
    var liked: Bool? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ProfileImageView(url: imageUrl, height: imageHeight)
                .frame(width: imageHeight, height: imageHeight)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 4)
            VStack(alignment: .leading, spacing: 8) {
                Text(alt)
                    .font(.headline)
                    .lineLimit(2)
                Text("Photographer: \(photographer)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if isHistory, let liked = liked {
                    HStack(spacing: 6) {
                        Image(systemName: liked ? "heart.fill" : "xmark")
                            .foregroundColor(liked ? .green : .red)
                        Text(liked ? "Liked" : "Disliked")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        ProfileDetailsView(
            imageUrl: "https://images.pexels.com/photos/12345/pexels-photo-12345.jpeg",
            photographer: "Jane Doe",
            alt: "Sample profile",
            imageHeight: 100
        )
        ProfileDetailsView(
            imageUrl: "https://images.pexels.com/photos/67890/pexels-photo-67890.jpeg",
            photographer: "John Smith",
            alt: "Another profile",
            imageHeight: 60,
            isHistory: true,
            liked: false
        )
    }
    .padding()
}

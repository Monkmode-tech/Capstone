import SwiftUI

struct ProfileImageView: View {
    let url: String
    let height: CGFloat
    var body: some View {
        AsyncImage(url: URL(string: url)) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            ProgressView()
        }
        .frame(height: height)
        .clipped()
    }
}

#Preview {
    ProfileImageView(url: "https://images.pexels.com/photos/12345/pexels-photo-12345.jpeg", height: 350)
}

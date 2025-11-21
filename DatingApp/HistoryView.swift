import SwiftUI

struct HistoryView: View {
    let likedProfiles: [LikedProfile]
    var body: some View {
        NavigationStack {
            List(likedProfiles) { profile in
                ProfileDetailsView(
                    imageUrl: profile.imageUrl,
                    photographer: profile.photographer,
                    alt: profile.alt,
                    imageHeight: 60,
                    isHistory: true,
                    liked: profile.liked
                )
                .padding(.vertical, 4)
            }
            .navigationTitle("History")
        }
    }
}

#Preview {
    HistoryView(likedProfiles: [
        LikedProfile(id: 1, gender: "men", imageUrl: "https://images.pexels.com/photos/12345/pexels-photo-12345.jpeg", photographer: "Jane Doe", alt: "Sample profile", liked: true),
        LikedProfile(id: 2, gender: "women", imageUrl: "https://images.pexels.com/photos/67890/pexels-photo-67890.jpeg", photographer: "John Smith", alt: "Another profile", liked: false)
    ])
}

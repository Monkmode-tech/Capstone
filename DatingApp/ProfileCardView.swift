import SwiftUI

struct ProfileCardView: View {
    let profile: Profile
    var body: some View {
        ProfileDetailsView(
            imageUrl: profile.src.large,
            photographer: profile.photographer,
            alt: profile.alt,
            imageHeight: 350
        )
    }
}

#Preview {
    ProfileCardView(profile: Profile(id: 1, photographer: "Jane Doe", src: Profile.ProfileImageSrc(original: "", large: "https://images.pexels.com/photos/12345/pexels-photo-12345.jpeg", medium: "", small: "", portrait: "", landscape: "", tiny: ""), alt: "Sample profile", gender: "women"))
}

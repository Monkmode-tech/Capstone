import Foundation
import SwiftData

@Model
final class LikedProfile: Identifiable {
    @Attribute(.unique) var id: Int
    var gender: String
    var imageUrl: String
    var photographer: String
    var alt: String
    var liked: Bool
    var timestamp: Date
    
    init(id: Int, gender: String, imageUrl: String, photographer: String, alt: String, liked: Bool, timestamp: Date = Date()) {
        self.id = id
        self.gender = gender
        self.imageUrl = imageUrl
        self.photographer = photographer
        self.alt = alt
        self.liked = liked
        self.timestamp = timestamp
    }
}

struct Profile: Identifiable, Codable, Equatable {
    let id: Int
    let photographer: String
    let src: ProfileImageSrc
    let alt: String
    var gender: String? // Added gender property
    
    struct ProfileImageSrc: Codable, Equatable {
        let original: String
        let large: String
        let medium: String
        let small: String
        let portrait: String
        let landscape: String
        let tiny: String
    }
}

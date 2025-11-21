import Foundation

@MainActor
class ProfileFetcher: ObservableObject {
    @Published var profiles: [Profile] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var gender: String = "men" // or "women"
    
    private let apiKey = "U47vf4WgKAzeTz7DXxW7htHAff4hN3lzYPHVJ5wG9ES07ttCXEY3RZAc"
    private let perPage = 15
    private var currentPage = 1
    
    private let genderSearchTerms: [String: [String]] = [
        "men": ["men", "man", "male", "guy", "boy"],
        "women": ["women", "woman", "female", "girl", "lady"]
    ]
    // Caching and expiry
    private var genderCache: [String: [Profile]] = [:]
    private var cacheTimestamps: [String: Date] = [:]
    private let cacheExpiry: TimeInterval = 600 // 10 minutes

    func fetchProfiles(reset: Bool = false, searchTermIndex: Int = 0) async {
        if reset {
            currentPage = 1
            profiles = []
        }
        isLoading = true
        errorMessage = nil
        // Check cache first
        if !reset, let cached = genderCache[gender], let timestamp = cacheTimestamps[gender], Date().timeIntervalSince(timestamp) < cacheExpiry {
            profiles = cached
            isLoading = false
            return
        }
        let terms = genderSearchTerms[gender] ?? [gender]
        let query = searchTermIndex < terms.count ? terms[searchTermIndex] : gender
        let urlString = "https://api.pexels.com/v1/search?query=\(query)&per_page=\(perPage)&page=\(currentPage)"
        print("Fetching profiles from URL: \(urlString)")
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL: \(urlString)"
            isLoading = false
            return
        }
        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "Authorization")
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                errorMessage = "Failed to fetch profiles. URL: \(urlString)"
                isLoading = false
                return
            }
            let decoded = try JSONDecoder().decode(PexelsResponse.self, from: data)
            // Assign gender and filter
            let filtered = decoded.photos.compactMap { profile -> Profile? in
                var p = profile
                p.gender = gender
                // Fallback filter: check alt/photographer for gender keywords
                let lowerAlt = p.alt.lowercased()
                let lowerPhotographer = p.photographer.lowercased()
                let genderTerms = genderSearchTerms[gender]?.joined(separator: "|") ?? gender
                if lowerAlt.range(of: genderTerms, options: .regularExpression) != nil ||
                   lowerPhotographer.range(of: genderTerms, options: .regularExpression) != nil {
                    return p
                }
                // If no match, still allow (API may be good), but you can uncomment next line to filter strictly
                // return nil
                return p
            }
            if reset {
                profiles = filtered
            } else {
                profiles += filtered
            }
            // Cache result
            genderCache[gender] = profiles
            cacheTimestamps[gender] = Date()
            if filtered.isEmpty {
                if searchTermIndex + 1 < terms.count {
                    print("No profiles found for query '", query, "', trying next term...")
                    await fetchProfiles(reset: reset, searchTermIndex: searchTermIndex + 1)
                    return
                } else {
                    errorMessage = "No profiles found for URL: \(urlString)"
                }
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)\nURL: \(urlString)"
        }
        isLoading = false
        // Pre-fetch the other gender in background
        let otherGender = gender == "men" ? "women" : "men"
        if genderCache[otherGender] == nil || (cacheTimestamps[otherGender] == nil || Date().timeIntervalSince(cacheTimestamps[otherGender]!) > cacheExpiry) {
            Task.detached { [weak self] in
                await self?.prefetchGender(otherGender)
            }
        }
    }

    private func prefetchGender(_ gender: String) async {
        let oldGender = self.gender
        self.gender = gender
        await fetchProfiles(reset: true)
        self.gender = oldGender
    }

    func switchGender(to newGender: String) async {
        gender = newGender
        // Use cache if available and not expired
        if let cached = genderCache[newGender], let timestamp = cacheTimestamps[newGender], Date().timeIntervalSince(timestamp) < cacheExpiry {
            profiles = cached
            isLoading = false
        } else {
            await fetchProfiles(reset: true)
        }
    }

    func loadNextPage() async {
        currentPage += 1
        await fetchProfiles()
    }
}

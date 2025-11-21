//
//  DatingAppApp.swift
//  DatingApp
//
//  Created by Caleb Tetteh on 11/19/25.
//

import SwiftUI
import SwiftData

@main
struct DatingAppApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LikedProfile.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

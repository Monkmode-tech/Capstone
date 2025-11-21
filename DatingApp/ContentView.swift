//
//  ContentView.swift
//  DatingApp
//
//  Created by Caleb Tetteh on 11/19/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var fetcher = ProfileFetcher()
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\LikedProfile.timestamp, order: .reverse)]) private var likedProfiles: [LikedProfile]
    @State private var showHistory = false
    @State private var selectedGender = "men"
    @State private var currentIndex = 0
    @State private var showSplash = true // Add splash state

    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    // Gender Toggle
                    Picker("Gender", selection: $selectedGender) {
                        Text("Women").tag("men")
                        Text("Men").tag("women")
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .onChange(of: selectedGender) { newValue, _ in
                        Task { await fetcher.switchGender(to: newValue) }
                        currentIndex = 0
                    }

                    // Loading Animation (Splash)
                    if fetcher.isLoading {
                        Spacer()
                        ProgressView("Loading profiles...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.5)
                        Spacer()
                    } else if let error = fetcher.errorMessage {
                        Spacer()
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                        Button("Retry") {
                            Task { await fetcher.fetchProfiles(reset: true) }
                        }
                        Spacer()
                    } else if fetcher.profiles.isEmpty {
                        Spacer()
                        Text("No profiles found.")
                            .foregroundColor(.secondary)
                        Spacer()
                    } else {
                        // Swipeable Card Stack
                        ZStack {
                            ForEach(fetcher.profiles.indices, id: \ .self) { index in
                                if index == currentIndex {
                                    ProfileDetailsView(
                                        imageUrl: fetcher.profiles[index].src.large,
                                        photographer: fetcher.profiles[index].photographer,
                                        alt: fetcher.profiles[index].alt,
                                        imageHeight: 350
                                    )
                                    .transition(.scale)
                                    .gesture(
                                        DragGesture()
                                            .onEnded { value in
                                                if value.translation.width < -100 {
                                                    // Dislike
                                                    saveProfile(fetcher.profiles[index], liked: false)
                                                    withAnimation { nextProfile() }
                                                } else if value.translation.width > 100 {
                                                    // Like
                                                    saveProfile(fetcher.profiles[index], liked: true)
                                                    withAnimation { nextProfile() }
                                                }
                                            }
                                    )
                                }
                            }
                        }
                        .frame(maxHeight: 500)
                        .padding()
                        HStack {
                            LikeDislikeButton(systemName: "xmark.circle.fill", color: .red) {
                                if currentIndex < fetcher.profiles.count {
                                    saveProfile(fetcher.profiles[currentIndex], liked: false)
                                    withAnimation { nextProfile() }
                                }
                            }
                            Spacer()
                            LikeDislikeButton(systemName: "heart.circle.fill", color: .green) {
                                if currentIndex < fetcher.profiles.count {
                                    saveProfile(fetcher.profiles[currentIndex], liked: true)
                                    withAnimation { nextProfile() }
                                }
                            }
                        }
                        .padding(.horizontal, 60)
                        .padding(.top, 20)
                    }
                    Spacer()
                    Button(action: { showHistory = true }) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                            .font(.headline)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .padding(.bottom)
                }
                .navigationTitle("Dating App")
                .sheet(isPresented: $showHistory) {
                    HistoryView(likedProfiles: likedProfiles)
                }
                .onAppear {
                    if fetcher.profiles.isEmpty {
                        Task { await fetcher.fetchProfiles(reset: true) }
                    }
                }
            }
            // Splash overlay
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            // Hide splash after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation { showSplash = false }
            }
        }
    }

    private func nextProfile() {
        if currentIndex < fetcher.profiles.count - 1 {
            currentIndex += 1
        } else {
            Task { await fetcher.loadNextPage() }
            currentIndex = 0
        }
    }

    private func saveProfile(_ profile: Profile, liked: Bool) {
        guard !likedProfiles.contains(where: { $0.id == profile.id }) else { return }
        let newLiked = LikedProfile(
            id: profile.id,
            gender: selectedGender,
            imageUrl: profile.src.large,
            photographer: profile.photographer,
            alt: profile.alt,
            liked: liked
        )
        modelContext.insert(newLiked)
        try? modelContext.save() // Ensure persistence
    }
}

#Preview {
    ContentView()
}

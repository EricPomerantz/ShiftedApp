//
//  TabBarView.swift
//  Shifted
//
//  Created by Eric Pomerantz on 12/8/24.
//

import SwiftUI

enum ActiveTab {
    case marketplace
    case forum
    case chats
    case profile
}

struct TabBarView: View {
    @State private var activeTab: ActiveTab = .marketplace // Track the current active tab
    @State private var isPresentingCreateView = false // Tracks modal presentation
    @State private var isInRootView = true // Tracks if the user is in a root view

    var body: some View {
        ZStack {
            TabView(selection: $activeTab) {
                NavigationView {
                    MarketplaceView()
                        .onAppear { isInRootView = true }
                        .onDisappear { isInRootView = false }
                }
                .tabItem {
                    Label("Marketplace", systemImage: "cart")
                }
                .tag(ActiveTab.marketplace)

                NavigationView {
                    ForumView()
                        .onAppear { isInRootView = true }
                        .onDisappear { isInRootView = false }
                }
                .tabItem {
                    Label("Forum", systemImage: "bubble.left.and.bubble.right")
                }
                .tag(ActiveTab.forum)

                NavigationView {
                    ChatsView()
                }
                .tabItem {
                    Label("Chats", systemImage: "message")
                }
                .tag(ActiveTab.chats)

                NavigationView {
                    ProfileView()
                }
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
                .tag(ActiveTab.profile)
            }

            // Show the floating button only on Marketplace or Forum tabs when in the root view
            if (activeTab == .marketplace || activeTab == .forum) && isInRootView {
                VStack {
                    Spacer()
                    Button(action: {
                        isPresentingCreateView = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.blue)
                            .shadow(radius: 10)
                    }
                    .padding(.bottom, 80) // Position just above the navigation tab
                    .sheet(isPresented: $isPresentingCreateView) {
                        if activeTab == .marketplace {
                            CreateListingView()
                        } else if activeTab == .forum {
                            CreateQuestionView(onQuestionCreated: {
                                // Dismiss the sheet and update the ForumView
                                isPresentingCreateView = false
                                NotificationCenter.default.post(name: NSNotification.Name("QuestionCreated"), object: nil)
                            })
                        }
                    }
                }
                .ignoresSafeArea() // Prevents button from being clipped
            }
        }
    }
}

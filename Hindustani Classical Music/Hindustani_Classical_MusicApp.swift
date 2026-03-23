//
//  Hindustani_Classical_MusicApp.swift
//  Hindustani Classical Music
//
//  Created by user291866 on 3/21/26.
//

import SwiftUI
import SwiftData

@main
struct Hindustani_Classical_MusicApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            MainAppView()
        }
        .modelContainer(sharedModelContainer)
    }
}

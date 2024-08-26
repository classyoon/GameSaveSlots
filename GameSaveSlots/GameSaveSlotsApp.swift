//
//  GameSaveSlotsApp.swift
//  GameSaveSlots
//
//  Created by Conner Yoon on 8/26/24.
//

import SwiftUI
import SwiftData

@main
struct GameSaveSlotsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GameSave.self, User.self
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
            //ContentView()
            NavigationStack{
                UserListView()
            }
            
        }
        
        .modelContainer(sharedModelContainer)
    }
}

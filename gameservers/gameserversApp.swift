//
//  gameserversApp.swift
//  gameservers
//
//  Created by Mohammed Al-Dahleh on 2023-06-16.
//

import SwiftUI

@main
struct gameserversApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

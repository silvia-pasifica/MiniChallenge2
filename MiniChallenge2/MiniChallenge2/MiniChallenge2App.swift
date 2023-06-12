//
//  MiniChallenge2App.swift
//  MiniChallenge2
//
//  Created by Silvia Pasica on 12/06/23.
//

import SwiftUI

@main
struct MiniChallenge2App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

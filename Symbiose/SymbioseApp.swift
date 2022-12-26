//
//  SymbioseApp.swift
//  Symbiose
//
//  Created by Jonathan Pegaz on 21/12/2022.
//

import SwiftUI

@main
struct SymbioseApp: App {
    @StateObject var bleInterface = BLEObservable()
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(bleInterface)
        }
    }
}

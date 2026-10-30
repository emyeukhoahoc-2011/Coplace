import SwiftUI

@main
struct CoplaceApp: App {
    @StateObject private var game = GameModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
                .preferredColorScheme(.dark)
                .onChange(of: scenePhase) { phase in
                    if phase != .active {
                        game.saveProgress()
                        game.stopMovement()
                    }
                }
        }
    }
}

import SwiftUI
import Combine

@MainActor
final class GameModel: ObservableObject {
    static let worldSize = CGSize(width: 1800, height: 1300)

    @Published private(set) var playerPosition: CGPoint
    @Published private(set) var collectedIDs: Set<Int>
    @Published private(set) var message = "Welcome to Sunny Meadow!"
    @Published var isMapPresented = false

    let collectibles: [WorldItem] = [
        WorldItem(
            id: 1,
            position: CGPoint(x: 330, y: 330),
            symbol: "🌼",
            title: "Golden flower",
            description: "A flower that always faces the morning sun."
        ),
        WorldItem(
            id: 2,
            position: CGPoint(x: 1190, y: 330),
            symbol: "💎",
            title: "Blue crystal",
            description: "A tiny crystal hidden beside the old trees."
        ),
        WorldItem(
            id: 3,
            position: CGPoint(x: 430, y: 940),
            symbol: "🍄",
            title: "Forest mushroom",
            description: "A little mushroom from the quiet woods."
        ),
        WorldItem(
            id: 4,
            position: CGPoint(x: 1460, y: 700),
            symbol: "⭐",
            title: "Fallen star",
            description: "A bright star that landed in the meadow."
        ),
        WorldItem(
            id: 5,
            position: CGPoint(x: 900, y: 620),
            symbol: "🪵",
            title: "Ancient token",
            description: "An old token left by another explorer."
        ),
        WorldItem(
            id: 6,
            position: CGPoint(x: 1570, y: 1050),
            symbol: "🦋",
            title: "Blue butterfly",
            description: "A butterfly resting near the edge of the meadow."
        )
    ]

    private let defaults = UserDefaults.standard
    private let savePrefix = "coplace.save."
    private var movementVector = CGVector.zero
    private var movementTask: Task<Void, Never>?

    init() {
        let savedIDs = defaults.array(forKey: savePrefix + "collected") as? [Int] ?? []
        collectedIDs = Set(savedIDs)

        let savedX = defaults.object(forKey: savePrefix + "playerX") as? Double
        let savedY = defaults.object(forKey: savePrefix + "playerY") as? Double

        let initialX = CGFloat(savedX ?? Double(Self.worldSize.width * 0.5))
        let initialY = CGFloat(savedY ?? Double(Self.worldSize.height * 0.5))

        playerPosition = CGPoint(
            x: min(max(initialX, 32), Self.worldSize.width - 32),
            y: min(max(initialY, 32), Self.worldSize.height - 32)
        )

        if collectedIDs.count == collectibles.count {
            message = "You discovered everything. Amazing!"
        } else if !collectedIDs.isEmpty {
            message = "Welcome back, explorer!"
        }
    }

    var collectedCount: Int {
        collectedIDs.count
    }

    var totalCollectibles: Int {
        collectibles.count
    }

    func isCollected(_ id: Int) -> Bool {
        collectedIDs.contains(id)
    }

    func setMovement(_ vector: CGVector) {
        let clampedX = min(max(vector.dx, -1), 1)
        let clampedY = min(max(vector.dy, -1), 1)
        let magnitude = hypot(clampedX, clampedY)

        if magnitude > 1 {
            movementVector = CGVector(dx: clampedX / magnitude, dy: clampedY / magnitude)
        } else {
            movementVector = CGVector(dx: clampedX, dy: clampedY)
        }

        startMovementLoopIfNeeded()
    }

    func stopMovement() {
        movementVector = .zero
    }

    private func startMovementLoopIfNeeded() {
        guard movementTask == nil else { return }

        movementTask = Task { [weak self] in
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: 16_666_667)
                } catch {
                    break
                }

                guard let self else { return }
                self.advancePlayerOneFrame()
            }
        }
    }

    private func advancePlayerOneFrame() {
        guard abs(movementVector.dx) > 0.001 || abs(movementVector.dy) > 0.001 else {
            return
        }

        let unitsPerSecond: CGFloat = 205
        let delta = unitsPerSecond / 60

        let nextX = playerPosition.x + movementVector.dx * delta
        let nextY = playerPosition.y + movementVector.dy * delta

        playerPosition = CGPoint(
            x: min(max(nextX, 28), Self.worldSize.width - 28),
            y: min(max(nextY, 28), Self.worldSize.height - 28)
        )

        checkForNearbyCollectibles()
    }

    private func checkForNearbyCollectibles() {
        let pickupRadius: CGFloat = 46

        for item in collectibles where !collectedIDs.contains(item.id) {
            let distance = hypot(
                playerPosition.x - item.position.x,
                playerPosition.y - item.position.y
            )

            guard distance <= pickupRadius else { continue }

            collectedIDs.insert(item.id)
            message = "Found \(item.title)! \(item.symbol)"
            saveProgress()

            if collectedIDs.count == collectibles.count {
                message = "Amazing! You found every secret."
            }
            return
        }
    }

    func cameraOrigin(viewport: CGSize) -> CGPoint {
        let maxX = max(0, Self.worldSize.width - viewport.width)
        let maxY = max(0, Self.worldSize.height - viewport.height)

        return CGPoint(
            x: min(max(playerPosition.x - viewport.width / 2, 0), maxX),
            y: min(max(playerPosition.y - viewport.height / 2, 0), maxY)
        )
    }

    func saveProgress() {
        defaults.set(Array(collectedIDs).sorted(), forKey: savePrefix + "collected")
        defaults.set(Double(playerPosition.x), forKey: savePrefix + "playerX")
        defaults.set(Double(playerPosition.y), forKey: savePrefix + "playerY")
    }

    func resetProgress() {
        collectedIDs.removeAll()
        playerPosition = CGPoint(
            x: Self.worldSize.width * 0.5,
            y: Self.worldSize.height * 0.5
        )
        message = "A fresh adventure begins!"
        defaults.removeObject(forKey: savePrefix + "collected")
        saveProgress()
    }
}

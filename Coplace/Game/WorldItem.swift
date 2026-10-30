import CoreGraphics

struct WorldItem: Identifiable {
    let id: Int
    let position: CGPoint
    let symbol: String
    let title: String
    let description: String
}

struct WorldDecoration: Identifiable {
    let id: Int
    let position: CGPoint
    let symbol: String
    let size: CGFloat

    static let all: [WorldDecoration] = [
        .init(id: 1, position: CGPoint(x: 170, y: 210), symbol: "🌳", size: 37),
        .init(id: 2, position: CGPoint(x: 420, y: 160), symbol: "🌲", size: 30),
        .init(id: 3, position: CGPoint(x: 680, y: 270), symbol: "🌳", size: 34),
        .init(id: 4, position: CGPoint(x: 980, y: 170), symbol: "🌲", size: 36),
        .init(id: 5, position: CGPoint(x: 1330, y: 230), symbol: "🌳", size: 38),
        .init(id: 6, position: CGPoint(x: 1600, y: 180), symbol: "🌲", size: 31),
        .init(id: 7, position: CGPoint(x: 250, y: 560), symbol: "🌲", size: 32),
        .init(id: 8, position: CGPoint(x: 580, y: 760), symbol: "🌳", size: 39),
        .init(id: 9, position: CGPoint(x: 900, y: 1010), symbol: "🌲", size: 34),
        .init(id: 10, position: CGPoint(x: 1450, y: 900), symbol: "🌳", size: 40),
        .init(id: 11, position: CGPoint(x: 1660, y: 1120), symbol: "🌲", size: 33),
        .init(id: 12, position: CGPoint(x: 300, y: 1080), symbol: "🌳", size: 36)
    ]
}

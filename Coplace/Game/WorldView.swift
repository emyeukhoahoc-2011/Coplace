import SwiftUI

struct WorldView: View {
    @EnvironmentObject private var game: GameModel

    var body: some View {
        GeometryReader { proxy in
            let viewport = proxy.size
            let camera = game.cameraOrigin(viewport: viewport)

            ZStack(alignment: .topLeading) {
                Canvas { context, canvasSize in
                    drawMeadow(
                        in: &context,
                        size: canvasSize,
                        camera: camera
                    )
                }

                ForEach(WorldDecoration.all) { decoration in
                    Text(decoration.symbol)
                        .font(.system(size: decoration.size))
                        .position(
                            x: decoration.position.x - camera.x,
                            y: decoration.position.y - camera.y
                        )
                }

                ForEach(game.collectibles) { item in
                    if !game.isCollected(item.id) {
                        Text(item.symbol)
                            .font(.system(size: 27))
                            .shadow(color: .black.opacity(0.25), radius: 5, y: 3)
                            .position(
                                x: item.position.x - camera.x,
                                y: item.position.y - camera.y
                            )
                    }
                }

                PlayerSprite()
                    .position(
                        x: game.playerPosition.x - camera.x,
                        y: game.playerPosition.y - camera.y
                    )

                locationBadge
                    .padding(12)
            }
            .frame(width: viewport.width, height: viewport.height)
            .clipped()
        }
    }

    private var locationBadge: some View {
        Label("SUNNY MEADOW", systemImage: "sun.max.fill")
            .font(.system(size: 10, weight: .heavy, design: .rounded))
            .tracking(1.1)
            .padding(.horizontal, 11)
            .padding(.vertical, 8)
            .background(.black.opacity(0.25), in: Capsule())
            .foregroundStyle(.white)
    }

    private func drawMeadow(
        in context: inout GraphicsContext,
        size: CGSize,
        camera: CGPoint
    ) {
        let bounds = CGRect(origin: .zero, size: size)
        context.fill(
            Path(bounds),
            with: .color(Color(red: 0.24, green: 0.43, blue: 0.30))
        )

        for index in 0..<54 {
            let worldX = CGFloat((index * 157 + 61) % 1760) + 20
            let worldY = CGFloat((index * 239 + 83) % 1260) + 20
            let rect = CGRect(
                x: worldX - camera.x - 25,
                y: worldY - camera.y - 18,
                width: 50,
                height: 36
            )

            guard rect.intersects(bounds) else { continue }

            let opacity = index.isMultiple(of: 2) ? 0.045 : 0.075
            context.fill(
                Path(ellipseIn: rect),
                with: .color(.white.opacity(opacity))
            )
        }

        var path = Path()
        path.move(to: CGPoint(x: -camera.x - 80, y: 760 - camera.y))
        path.addCurve(
            to: CGPoint(x: 1880 - camera.x, y: 500 - camera.y),
            control1: CGPoint(x: 510 - camera.x, y: 420 - camera.y),
            control2: CGPoint(x: 1120 - camera.x, y: 1010 - camera.y)
        )

        context.stroke(
            path,
            with: .color(Color(red: 0.69, green: 0.59, blue: 0.39).opacity(0.9)),
            style: StrokeStyle(lineWidth: 48, lineCap: .round)
        )
        context.stroke(
            path,
            with: .color(Color(red: 0.88, green: 0.80, blue: 0.61).opacity(0.65)),
            style: StrokeStyle(lineWidth: 2, dash: [8, 9])
        )
    }
}

private struct PlayerSprite: View {
    var body: some View {
        VStack(spacing: -5) {
            Text("🧢")
                .font(.system(size: 25))
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.84, blue: 0.60),
                                Color(red: 0.92, green: 0.65, blue: 0.39)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 27, height: 27)
                    .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 2))

                Image(systemName: "face.smiling")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.brown)
            }
        }
        .shadow(color: .black.opacity(0.28), radius: 5, y: 4)
        .accessibilityLabel("Player")
    }
}

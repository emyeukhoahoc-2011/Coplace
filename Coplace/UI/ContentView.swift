import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var game: GameModel

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.055, green: 0.105, blue: 0.13),
                    Color(red: 0.08, green: 0.18, blue: 0.16)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                header

                WorldView()
                    .clipShape(RoundedRectangle(cornerRadius: 23, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: 23, style: .continuous)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    }
                    .padding(.horizontal, 13)
                    .padding(.top, 13)
                    .padding(.bottom, 10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                footer
            }
            .padding(.top, 6)
        }
        .sheet(isPresented: $game.isMapPresented) {
            MapSheet()
                .environmentObject(game)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("COPLACE")
                    .font(.system(size: 22, weight: .black, design: .rounded))
                    .tracking(3)
                Text("A little world, waiting for you")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.62))
            }

            Spacer(minLength: 6)

            HStack(spacing: 6) {
                Text("✨")
                Text("\(game.collectedCount)/\(game.totalCollectibles)")
                    .font(.system(.subheadline, design: .rounded).bold())
                    .monospacedDigit()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .background(.white.opacity(0.11), in: Capsule())

            Button {
                game.isMapPresented = true
            } label: {
                Image(systemName: "map")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 39, height: 39)
                    .background(.white.opacity(0.11), in: Circle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open map")
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 19)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text(game.message)
                    .font(.system(.subheadline, design: .rounded).semibold())
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)

                Text("Move around and get close to an item to collect it.")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Joystick()
                .frame(width: 112, height: 100)
        }
        .padding(.horizontal, 19)
        .padding(.top, 1)
        .padding(.bottom, 7)
    }
}

private struct Joystick: View {
    @EnvironmentObject private var game: GameModel
    @State private var knobOffset = CGSize.zero

    private let radius: CGFloat = 28

    var body: some View {
        GeometryReader { proxy in
            let center = CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2)

            ZStack {
                Circle()
                    .fill(.white.opacity(0.085))
                    .overlay(Circle().stroke(.white.opacity(0.2), lineWidth: 1))

                Circle()
                    .fill(.white.opacity(0.22))
                    .frame(width: 43, height: 43)
                    .overlay(Circle().stroke(.white.opacity(0.38), lineWidth: 1))
                    .offset(knobOffset)

                Image(systemName: "circle.grid.cross")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.35))
                    .allowsHitTesting(false)
            }
            .contentShape(Circle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        let distance = hypot(dx, dy)
                        let clampedDistance = min(distance, radius)

                        if distance > 0 {
                            knobOffset = CGSize(
                                width: dx / distance * clampedDistance,
                                height: dy / distance * clampedDistance
                            )
                            game.setMovement(
                                CGVector(dx: dx / radius, dy: dy / radius)
                            )
                        } else {
                            knobOffset = .zero
                            game.setMovement(.zero)
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.68)) {
                            knobOffset = .zero
                        }
                        game.stopMovement()
                    }
            )
        }
        .onDisappear {
            game.stopMovement()
        }
        .accessibilityLabel("Movement joystick")
    }
}

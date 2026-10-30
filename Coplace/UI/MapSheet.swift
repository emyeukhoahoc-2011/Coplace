import SwiftUI

struct MapSheet: View {
    @EnvironmentObject private var game: GameModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    mapPreview

                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Discoveries")
                                .font(.headline)
                            Spacer()
                            Text("\(game.collectedCount) / \(game.totalCollectibles)")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                                .monospacedDigit()
                        }

                        ProgressView(
                            value: Double(game.collectedCount),
                            total: Double(max(game.totalCollectibles, 1))
                        )
                        .tint(.green)

                        ForEach(game.collectibles) { item in
                            HStack(spacing: 11) {
                                Text(item.symbol)
                                    .font(.title2)
                                    .frame(width: 38, height: 38)
                                    .background(.white.opacity(0.07), in: RoundedRectangle(cornerRadius: 11))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.title)
                                        .font(.subheadline.weight(.semibold))
                                    Text(game.isCollected(item.id) ? item.description : "Not discovered yet")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }

                                Spacer(minLength: 4)

                                Image(systemName: game.isCollected(item.id) ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(game.isCollected(item.id) ? .green : .secondary)
                            }
                            .padding(.vertical, 3)
                        }
                    }
                    .padding(15)
                    .background(.white.opacity(0.045), in: RoundedRectangle(cornerRadius: 18))

                    Button(role: .destructive) {
                        game.resetProgress()
                    } label: {
                        Label("Reset adventure", systemImage: "arrow.counterclockwise")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Explorer's map")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var mapPreview: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(red: 0.18, green: 0.34, blue: 0.25))

            Image(systemName: "map.fill")
                .font(.system(size: 80))
                .foregroundStyle(.white.opacity(0.09))

            VStack(spacing: 13) {
                Text("🌳       🌼       🌲")
                Text("     🧢          💎")
                Text("🍄             ⭐")
                Text("          🦋")
            }
            .font(.system(size: 24))
        }
        .frame(height: 185)
        .accessibilityLabel("Map of Sunny Meadow")
    }
}

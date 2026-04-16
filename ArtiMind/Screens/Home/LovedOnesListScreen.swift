import SwiftUI

struct LovedOnesListScreen: View {
    @Environment(AppState.self) private var appState

    private let sampleLovedOnes: [LovedOne] = {
        let a = LovedOne(name: "Grandma Rose", relationship: .grandmother)
        let b = LovedOne(name: "Dad", relationship: .father)
        return [a, b]
    }()

    var body: some View {
        ZStack {
            LinearGradient.pastelBackground
                .ignoresSafeArea()

            Group {
                if sampleLovedOnes.isEmpty {
                    emptyState
                } else {
                    companionList
                }
            }
        }
        .navigationTitle("Loved Ones")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: UploadPhotoScreen()) {
                    Image(systemName: "plus")
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var companionList: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleLovedOnes) { lovedOne in
                    NavigationLink(destination: UploadPhotoScreen()) {
                        LovedOneRow(lovedOne: lovedOne)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }

    private var emptyState: some View {
        VStack {
            Spacer()
            GlassCard(cornerRadius: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 48, weight: .light))
                        .foregroundStyle(.tertiary)

                    Text("No companions yet")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text("Tap the + button to create your first companion.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            }
            .padding(.horizontal, 40)
            Spacer()
        }
    }
}

private struct LovedOneRow: View {
    let lovedOne: LovedOne

    var body: some View {
        GlassCard(cornerRadius: 20) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.purple.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: lovedOne.relationship.icon)
                        .font(.title3)
                        .foregroundStyle(.purple)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(lovedOne.name.isEmpty ? "Unnamed" : lovedOne.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(lovedOne.relationship.displayName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: lovedOne.isGenerated ? "checkmark.circle.fill" : "clock.fill")
                        .foregroundStyle(lovedOne.isGenerated ? .green : .orange)

                    Text(lovedOne.isGenerated ? "Ready" : "In Progress")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}

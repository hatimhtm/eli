import SwiftUI
import Sparkle

/// Wraps Sparkle so updates are completely hands-off for the writer: Eli checks
/// in the background, and when Hatim pushes a release the toolbar button lights
/// up. One click downloads, installs, and relaxes — no Finder, no dragging.
final class UpdaterModel: NSObject, ObservableObject, SPUUpdaterDelegate {
    static let shared = UpdaterModel()

    @Published var updateAvailable = false
    private var controller: SPUStandardUpdaterController!

    private override init() {
        super.init()
        controller = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: self, userDriverDelegate: nil)
    }

    /// Opens Sparkle's update flow (download → install → relaunch).
    func checkForUpdates() { controller.checkForUpdates(nil) }

    // Background check found a release → light the button up.
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        DispatchQueue.main.async { self.updateAvailable = true }
    }
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        DispatchQueue.main.async { self.updateAvailable = false }
    }
}

/// The one button. Quiet when up to date; glowing accent capsule when an update
/// is ready. Clicking always works (also lets you check manually).
struct UpdateButton: View {
    @ObservedObject var updater: UpdaterModel
    @State private var pulse = false

    var body: some View {
        Button {
            updater.checkForUpdates()
        } label: {
            if updater.updateAvailable {
                Label("Update Available", systemImage: "arrow.down.circle.fill")
                    .padding(.horizontal, 4)
            } else {
                Label("Check for Updates", systemImage: "arrow.triangle.2.circlepath")
            }
        }
        .buttonStyle(.borderedProminent)
        .tint(updater.updateAvailable ? Color.accentColor : Color.secondary.opacity(0.25))
        .foregroundStyle(updater.updateAvailable ? .white : .primary)
        .scaleEffect(pulse ? 1.05 : 1.0)
        .help(updater.updateAvailable
              ? "A new version is ready — click to update Eli"
              : "Eli is up to date — click to check")
        .onChange(of: updater.updateAvailable) { available in
            if available {
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
            } else {
                withAnimation(.default) { pulse = false }
            }
        }
    }
}

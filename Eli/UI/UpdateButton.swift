import SwiftUI
import Sparkle

/// In-app updates via Sparkle — **manual only** (no background checks;
/// `SUEnableAutomaticChecks` is false). Clicking checks the EdDSA-signed appcast
/// on GitHub Releases and, if a newer build exists, offers a one-click
/// download → install → relaunch. Works without Apple notarization — Sparkle
/// verifies its own signature. (Same approach as Relay.)
@MainActor
final class UpdaterModel: ObservableObject {
    static let shared = UpdaterModel()
    let controller: SPUStandardUpdaterController

    private init() {
        controller = SPUStandardUpdaterController(startingUpdater: true,
                                                  updaterDelegate: nil,
                                                  userDriverDelegate: nil)
    }

    var canCheck: Bool { controller.updater.canCheckForUpdates }
    func checkForUpdates() { controller.checkForUpdates(nil) }
}

/// Toolbar button: one click checks GitHub and installs an update if there is one.
struct UpdateButton: View {
    @ObservedObject var updater: UpdaterModel

    var body: some View {
        Button { updater.checkForUpdates() } label: {
            Label("Check for Updates", systemImage: "arrow.down.circle")
        }
        .disabled(!updater.canCheck)
        .help("Check GitHub for a new version and install it")
    }
}

/// `Eli ▸ Check for Updates…` menu command.
struct CheckForUpdatesCommand: View {
    @ObservedObject private var updater = UpdaterModel.shared
    var body: some View {
        Button("Check for Updates…") { updater.checkForUpdates() }
            .disabled(!updater.canCheck)
    }
}

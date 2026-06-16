import SwiftUI

/// A timed writing sprint — pick a length, write, see how much you got down.
/// Beloved, low-pressure, NaNoWriMo-style. No penalties, ever.
final class SprintTimer: ObservableObject {
    @Published var isRunning = false
    @Published var finished = false
    @Published var remaining = 0
    @Published var wordsWritten = 0

    private var startWords = 0
    private var timer: Timer?
    private var liveWordCount: () -> Int = { 0 }

    func start(minutes: Int, wordCount: @escaping () -> Int) {
        liveWordCount = wordCount
        startWords = wordCount()
        remaining = minutes * 60
        wordsWritten = 0
        isRunning = true
        finished = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
    }

    func stop() { finish() }

    func reset() { isRunning = false; finished = false; remaining = 0; wordsWritten = 0 }

    private func tick() {
        remaining -= 1
        wordsWritten = max(0, liveWordCount() - startWords)
        if remaining <= 0 { finish() }
    }

    private func finish() {
        timer?.invalidate(); timer = nil
        wordsWritten = max(0, liveWordCount() - startWords)
        isRunning = false
        finished = true
        if wordsWritten > 0 { WritingDays.recordToday() }
    }
}

/// Forgiving streak: just the set of days writing happened. We show "X of the
/// last 30 days" — never a fragile consecutive counter (those backfire).
enum WritingDays {
    private static let key = "activity.days"

    private static func today(_ now: Date = Date()) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        return f.string(from: now)
    }

    static func recordToday(_ now: Date = Date()) {
        var days = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        days.insert(today(now))
        UserDefaults.standard.set(Array(days), forKey: key)
    }

    static func daysInLast(_ n: Int, now: Date = Date()) -> Int {
        let days = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; f.locale = Locale(identifier: "en_US_POSIX")
        let cal = Calendar.current
        var count = 0
        for offset in 0..<n {
            if let day = cal.date(byAdding: .day, value: -offset, to: now), days.contains(f.string(from: day)) {
                count += 1
            }
        }
        return count
    }
}

struct SprintView: View {
    @ObservedObject var sprint: SprintTimer
    let wordCount: () -> Int

    private var clock: String {
        String(format: "%d:%02d", sprint.remaining / 60, sprint.remaining % 60)
    }
    private var streak: Int { WritingDays.daysInLast(30) }

    var body: some View {
        VStack(spacing: 16) {
            if sprint.isRunning {
                Text(clock).font(.system(size: 44, weight: .semibold, design: .rounded)).monospacedDigit()
                Text("\(sprint.wordsWritten) words so far").foregroundStyle(.secondary)
                Button("Stop", role: .destructive) { sprint.stop() }
                    .buttonStyle(.bordered)
            } else if sprint.finished {
                Image(systemName: "checkmark.seal.fill").font(.system(size: 36)).foregroundStyle(.tint)
                Text("Nice work").font(.headline)
                Text("You wrote \(sprint.wordsWritten) \(sprint.wordsWritten == 1 ? "word" : "words").")
                    .foregroundStyle(.secondary)
                Button("Done") { sprint.reset() }.buttonStyle(.borderedProminent)
            } else {
                Text("Writing Sprint").font(.headline)
                Text("Pick a length and just write.").font(.caption).foregroundStyle(.secondary)
                HStack {
                    ForEach([10, 15, 25], id: \.self) { minutes in
                        Button("\(minutes) min") { sprint.start(minutes: minutes, wordCount: wordCount) }
                            .buttonStyle(.bordered)
                    }
                }
                Divider().padding(.vertical, 4)
                Label("Written \(streak) of the last 30 days", systemImage: "flame")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(width: 280)
    }
}

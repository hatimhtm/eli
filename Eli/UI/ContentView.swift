import SwiftUI
import AppKit

enum EditorMode: String, CaseIterable, Identifiable {
    case write, translate
    var id: String { rawValue }
    var label: String { self == .write ? "Write" : "Translate" }
    var symbol: String { self == .write ? "pencil" : "character.book.closed" }
}

/// The editable unit behind the current selection — a scene-less chapter or a scene.
private struct UnitBindings {
    let id: UUID
    let title: Binding<String>
    let source: Binding<String>
    let translation: Binding<String?>
    let wordCount: Int
}

/// What the detail pane should show for the current selection.
private enum Resolved {
    case unit(UnitBindings)
    case chapterOverview(Int)
}

/// The book window: a binder sidebar of chapters + the writing/translation surface.
struct ContentView: View {
    @Binding var book: Book
    var onClose: () -> Void
    @State private var selection: UUID?
    @State private var mode: EditorMode = .write
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var sprint = SprintTimer()
    @State private var showingSprint = false
    @State private var columns: NavigationSplitViewVisibility = .all

    // Editor preferences, persisted across launches.
    @AppStorage("editor.theme") private var themeRaw = EditorThemeID.cream.rawValue
    @AppStorage("editor.font") private var fontRaw = FontChoice.serif.rawValue
    @AppStorage("editor.fontSize") private var fontSize = 18.0
    @AppStorage("editor.lineSpacing") private var lineSpacing = 6.0
    @AppStorage("editor.paragraphSpacing") private var paragraphSpacing = 12.0
    @AppStorage("editor.measure") private var measure = 680.0
    @AppStorage("editor.typewriter") private var typewriter = false
    @AppStorage("editor.focusMode") private var focusMode = false
    @AppStorage("export.useTranslation") private var exportTranslation = true
    @AppStorage("editor.accent") private var accentRaw = AccentChoice.burgundy.rawValue

    private var theme: EditorThemeID { EditorThemeID(rawValue: themeRaw) ?? .system }
    private var fontChoice: FontChoice { FontChoice(rawValue: fontRaw) ?? .serif }
    private var palette: EditorPalette { theme.palette }
    private var accent: AccentChoice { AccentChoice(rawValue: accentRaw) ?? .burgundy }

    var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            Binder(book: $book, selection: $selection)
        } detail: {
            Group {
                switch selection.flatMap(resolve) {
                case .chapterOverview(let ci):
                    ChapterOverview(title: $book.chapters[ci].title,
                                    sceneCount: book.chapters[ci].scenes.count,
                                    palette: palette)
                case .unit(let unit):
                    switch mode {
                    case .write:
                        WritingSurface(
                            title: unit.title,
                            source: unit.source,
                            wordCount: unit.wordCount,
                            palette: palette,
                            font: fontChoice.nsFont(size: fontSize),
                            lineSpacing: lineSpacing,
                            paragraphSpacing: paragraphSpacing,
                            measure: measure,
                            typewriter: typewriter,
                            focusMode: focusMode
                        )
                        .id(unit.id)
                    case .translate:
                        TranslationView(
                            source: unit.source,
                            translation: unit.translation,
                            sourceLanguage: book.manifest.sourceLanguage,
                            targetLanguage: book.manifest.targetLanguage,
                            glossary: book.glossary,
                            previousTail: previousTail(for: unit.id),
                            palette: palette,
                            font: fontChoice.nsFont(size: fontSize),
                            lineSpacing: lineSpacing,
                            paragraphSpacing: paragraphSpacing
                        )
                        .id(unit.id)
                    }
                case .none:
                    EmptyChapterState(palette: palette)
                }
            }
            .toolbar { detailToolbar }
        }
        .tint(accent.color)
        .preferredColorScheme(palette.preferredScheme)
        .animation(Motion.fluid, value: themeRaw)
        .animation(Motion.fluid, value: accentRaw)
        .animation(Motion.select, value: mode)
        .onAppear {
            if selection == nil { selection = book.chapters.first?.id }
        }
        .onChange(of: scenePhase) { phase in
            // Auto-backup whenever the app is closed or switched away from.
            if phase != .active { BackupManager.backUp(book) }
        }
    }

    /// Resolve the selected id to what to show: a scene-less chapter or a scene
    /// (both editable units), or a scened chapter's overview.
    private func resolve(_ id: UUID) -> Resolved? {
        if let ci = book.chapters.firstIndex(where: { $0.id == id }) {
            if book.chapters[ci].hasScenes { return .chapterOverview(ci) }
            return .unit(UnitBindings(
                id: book.chapters[ci].id,
                title: $book.chapters[ci].title,
                source: $book.chapters[ci].source,
                translation: $book.chapters[ci].translation,
                wordCount: book.chapters[ci].wordCount))
        }
        for ci in book.chapters.indices {
            if let si = book.chapters[ci].scenes.firstIndex(where: { $0.id == id }) {
                return .unit(UnitBindings(
                    id: book.chapters[ci].scenes[si].id,
                    title: $book.chapters[ci].scenes[si].title,
                    source: $book.chapters[ci].scenes[si].source,
                    translation: $book.chapters[ci].scenes[si].translation,
                    wordCount: book.chapters[ci].scenes[si].wordCount))
            }
        }
        return nil
    }

    /// The end of the previous unit's translation (scene or chapter), so the
    /// model keeps voice and terminology consistent across boundaries.
    private func previousTail(for id: UUID) -> String? {
        var units: [(id: UUID, translation: String?)] = []
        for chapter in book.chapters {
            if chapter.hasScenes {
                for scene in chapter.scenes { units.append((scene.id, scene.translation)) }
            } else {
                units.append((chapter.id, chapter.translation))
            }
        }
        guard let idx = units.firstIndex(where: { $0.id == id }), idx > 0,
              let previous = units[idx - 1].translation, !previous.isEmpty else { return nil }
        return String(previous.suffix(600))
    }

    @ToolbarContentBuilder
    private var detailToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button { onClose() } label: {
                Label("Library", systemImage: "books.vertical")
            }
            .help("Back to your books")
        }

        ToolbarItem(placement: .principal) {
            Picker("Mode", selection: $mode) {
                ForEach(EditorMode.allCases) { Label($0.label, systemImage: $0.symbol).tag($0) }
            }
            .pickerStyle(.segmented)
            .help("Switch between writing and translation")
        }

        ToolbarItem(placement: .automatic) {
            UpdateButton(updater: UpdaterModel.shared)
        }

        ToolbarItemGroup {
            Button {
                showingSprint = true
            } label: {
                Label("Sprint", systemImage: sprint.isRunning ? "timer.circle.fill" : "timer")
            }
            .help("Start a timed writing sprint")
            .popover(isPresented: $showingSprint, arrowEdge: .bottom) {
                SprintView(sprint: sprint, wordCount: { book.chapters.reduce(0) { $0 + $1.wordCount } })
            }

            Toggle(isOn: $typewriter) {
                Label("Typewriter", systemImage: "text.aligncenter")
            }
            .help("Typewriter mode — keep the current line centered")

            Toggle(isOn: $focusMode) {
                Label("Focus", systemImage: "circle.lefthalf.filled")
            }
            .help("Focus mode — dim everything but the current paragraph")

            Menu {
                Menu("Theme") {
                    ForEach(EditorThemeID.allCases) { t in
                        Button { themeRaw = t.rawValue } label: {
                            Label(t.label, systemImage: themeRaw == t.rawValue ? "checkmark" : "circle")
                        }
                    }
                }
                Menu("Accent") {
                    ForEach(AccentChoice.allCases) { c in
                        Button { accentRaw = c.rawValue } label: {
                            Label(c.label, systemImage: accentRaw == c.rawValue ? "checkmark" : "circle.fill")
                        }
                    }
                }
                Menu("Font") {
                    ForEach(FontChoice.allCases) { f in
                        Button { fontRaw = f.rawValue } label: {
                            Label(f.label, systemImage: fontRaw == f.rawValue ? "checkmark" : "textformat")
                        }
                    }
                }
                Divider()
                Stepper("Text size: \(Int(fontSize))", value: $fontSize, in: 12...30, step: 1)
                Stepper("Line spacing: \(Int(lineSpacing))", value: $lineSpacing, in: 0...16, step: 1)
                Stepper("Paragraph spacing: \(Int(paragraphSpacing))", value: $paragraphSpacing, in: 0...32, step: 2)
                Stepper("Line width: \(Int(measure))", value: $measure, in: 480...900, step: 20)
            } label: {
                Label("Display", systemImage: "textformat.size")
            }
            .help("Theme, font, and layout")

            Menu {
                Toggle("Export the translation", isOn: $exportTranslation)
                Divider()
                ForEach(ExportFormat.allCases) { format in
                    Button(format.label) { export(format) }
                }
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .help("Export the whole book")

            Button {
                withAnimation(Motion.surface) {
                    columns = (columns == .detailOnly) ? .all : .detailOnly
                }
            } label: {
                Label("Compose", systemImage: columns == .detailOnly ? "sidebar.left" : "rectangle.center.inset.filled")
            }
            .help("Compose mode — hide the sidebar for distraction-free writing")
            .keyboardShortcut("\r", modifiers: [.command, .shift])
        }
    }

    private func export(_ format: ExportFormat) {
        let exporter = BookExporter(book: book, useTranslation: exportTranslation)
        do {
            let data = try exporter.data(for: format)
            let panel = NSSavePanel()
            let base = book.manifest.title.isEmpty ? "Untitled Book" : book.manifest.title
            panel.nameFieldStringValue = "\(base).\(format.fileExtension)"
            panel.allowedContentTypes = [format.contentType]
            if panel.runModal() == .OK, let url = panel.url {
                try data.write(to: url)
            }
        } catch {
            NSApp.presentError(error)
        }
    }
}

// MARK: - Binder (chapter sidebar)

private struct Binder: View {
    @Binding var book: Book
    @Binding var selection: UUID?
    @State private var showingInfo = false
    @State private var showingGlossary = false
    @State private var showingFindReplace = false
    @State private var showingRestore = false
    @State private var showingSearch = false
    @State private var backupNote = false

    // "Words today" — baseline is the manuscript size at the first open each day.
    // (Single-book assumption; fine for one manuscript at a time.)
    @AppStorage("session.day") private var sessionDay = ""
    @AppStorage("session.baseline") private var sessionBaseline = 0

    private var totalWords: Int {
        book.chapters.reduce(0) { $0 + $1.wordCount }
    }
    private var wordsToday: Int { max(0, totalWords - sessionBaseline) }

    private static func todayString() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                Section("Manuscript") {
                    ForEach($book.chapters) { $chapter in
                        if chapter.scenes.isEmpty {
                            BinderRow(icon: "doc.text",
                                      title: chapter.title.isEmpty ? "Untitled" : chapter.title,
                                      status: chapter.status)
                                .tag(chapter.id)
                                .contextMenu {
                                    Button("Add Scene") { addScene(toChapterID: chapter.id) }
                                    statusMenu { setChapterStatus(chapter.id, $0) }
                                }
                        } else {
                            DisclosureGroup {
                                ForEach($chapter.scenes) { $scene in
                                    BinderRow(icon: "circle.dashed",
                                              title: scene.title.isEmpty ? "Untitled scene" : scene.title,
                                              status: scene.status)
                                        .tag(scene.id)
                                        .contextMenu {
                                            statusMenu { setSceneStatus(scene.id, $0) }
                                            Button("Delete Scene", role: .destructive) {
                                                deleteScene(scene.id)
                                            }
                                        }
                                }
                            } label: {
                                BinderRow(icon: "doc.on.doc",
                                          title: chapter.title.isEmpty ? "Untitled" : chapter.title,
                                          status: chapter.status)
                                    .tag(chapter.id)
                                    .contextMenu {
                                        Button("Add Scene") { addScene(toChapterID: chapter.id) }
                                        statusMenu { setChapterStatus(chapter.id, $0) }
                                    }
                            }
                        }
                    }
                    .onMove { from, to in
                        book.chapters.move(fromOffsets: from, toOffset: to)
                    }
                    .onDelete { offsets in
                        book.chapters.remove(atOffsets: offsets)
                        if let selection, !chapterOrSceneExists(selection) {
                            self.selection = book.chapters.first?.id
                        }
                    }
                }
            }
            .listStyle(.sidebar)

            Divider().opacity(0.5)
            Button(action: addChapter) {
                Label("Add Chapter", systemImage: "plus.circle.fill")
                    .font(.callout.weight(.medium))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(Color.accentColor)
            .help("Add a new chapter")

            ProgressFooter(totalWords: totalWords, wordsToday: wordsToday, goal: book.manifest.settings.wordCountGoal)
        }
        .navigationSplitViewColumnWidth(min: 220, ideal: 250, max: 340)
        .navigationTitle(book.manifest.title.isEmpty ? "Untitled Book" : book.manifest.title)
        .onAppear {
            let today = Self.todayString()
            if sessionDay != today { sessionDay = today; sessionBaseline = totalWords }
        }
        .onChange(of: totalWords) { _ in
            if wordsToday > 0 { WritingDays.recordToday() } // count today as a writing day
        }
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button("Book Info…") { showingInfo = true }
                    Button("Glossary…") { showingGlossary = true }
                    Button("Find & Replace…") { showingFindReplace = true }
                    Button("Search Book…") { showingSearch = true }
                    Divider()
                    Button("Back Up Now") {
                        BackupManager.backUp(book)
                        backupNote = true
                    }
                    Button("Earlier Versions…") { showingRestore = true }
                } label: {
                    Label("Book", systemImage: "ellipsis.circle")
                }
                .help("Book info, glossary, find & replace, and backups")
            }
        }
        .sheet(isPresented: $showingInfo) {
            BookInfoSheet(book: $book)
        }
        .sheet(isPresented: $showingGlossary) {
            GlossaryEditor(glossary: $book.glossary)
        }
        .sheet(isPresented: $showingFindReplace) {
            FindReplaceSheet(book: $book)
        }
        .sheet(isPresented: $showingSearch) {
            SearchSheet(book: book) { id in selection = id }
        }
        .sheet(isPresented: $showingRestore) {
            RestoreSheet { snapshot in
                BackupManager.backUp(book)            // safety: keep the current version too
                book.manifest = snapshot.manifest
                book.chapters = snapshot.chapters
                book.glossary = snapshot.glossary
                selection = book.chapters.first?.id
            }
        }
        .alert("Backed up", isPresented: $backupNote) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("A copy of your book was saved. Find it under Book ▸ Earlier Versions.")
        }
    }

    private func addChapter() {
        let new = Chapter(title: "Chapter \(book.chapters.count + 1)")
        book.chapters.append(new)
        selection = new.id
    }

    private func chapterOrSceneExists(_ id: UUID) -> Bool {
        book.chapters.contains { $0.id == id || $0.scenes.contains { $0.id == id } }
    }

    @ViewBuilder
    private func statusMenu(_ set: @escaping (WritingStatus) -> Void) -> some View {
        Menu("Mark as") {
            ForEach(WritingStatus.allCases) { status in
                Button(status.label) { set(status) }
            }
        }
    }

    private func setChapterStatus(_ id: UUID, _ status: WritingStatus) {
        if let ci = book.chapters.firstIndex(where: { $0.id == id }) {
            book.chapters[ci].status = status
        }
    }

    private func setSceneStatus(_ id: UUID, _ status: WritingStatus) {
        for ci in book.chapters.indices {
            if let si = book.chapters[ci].scenes.firstIndex(where: { $0.id == id }) {
                book.chapters[ci].scenes[si].status = status
                return
            }
        }
    }

    /// Adds a scene to a chapter. On the first scene, the chapter's existing text
    /// is moved into "Scene 1" so nothing is ever lost.
    private func addScene(toChapterID id: UUID) {
        guard let ci = book.chapters.firstIndex(where: { $0.id == id }) else { return }
        if book.chapters[ci].scenes.isEmpty {
            let hadBody = !book.chapters[ci].source.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                || (book.chapters[ci].translation?.isEmpty == false)
            if hadBody {
                book.chapters[ci].scenes.append(BookScene(
                    title: "Scene 1",
                    source: book.chapters[ci].source,
                    translation: book.chapters[ci].translation))
            }
            book.chapters[ci].source = ""
            book.chapters[ci].translation = nil
        }
        let next = BookScene(title: "Scene \(book.chapters[ci].scenes.count + 1)")
        book.chapters[ci].scenes.append(next)
        selection = next.id
    }

    private func deleteScene(_ id: UUID) {
        for ci in book.chapters.indices {
            if let si = book.chapters[ci].scenes.firstIndex(where: { $0.id == id }) {
                book.chapters[ci].scenes.remove(at: si)
                if selection == id {
                    selection = book.chapters[ci].scenes.first?.id ?? book.chapters[ci].id
                }
                return
            }
        }
    }
}

/// A binder row: icon, title, and a trailing status dot (faint while a draft).
private struct BinderRow: View {
    let icon: String
    let title: String
    let status: WritingStatus

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon).foregroundStyle(.secondary)
            Text(title)
            Spacer(minLength: 6)
            Circle()
                .fill(status.color)
                .frame(width: 7, height: 7)
                .opacity(status == .draft ? 0.0 : 1)
        }
        .font(.callout)
    }
}

private struct ProgressFooter: View {
    let totalWords: Int
    let wordsToday: Int
    let goal: Int?

    private var todaySuffix: String { wordsToday > 0 ? " · \(wordsToday) today" : "" }

    var body: some View {
        VStack(spacing: 4) {
            if let goal, goal > 0 {
                ProgressView(value: min(Double(totalWords), Double(goal)), total: Double(goal))
                Text("\(totalWords) / \(goal) words\(todaySuffix)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } else {
                Text("\(totalWords) \(totalWords == 1 ? "word" : "words")\(todaySuffix)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Writing surface

private struct WritingSurface: View {
    @Binding var title: String
    @Binding var source: String
    let wordCount: Int
    let palette: EditorPalette
    let font: NSFont
    let lineSpacing: CGFloat
    let paragraphSpacing: CGFloat
    let measure: CGFloat
    let typewriter: Bool
    let focusMode: Bool

    var body: some View {
        VStack(spacing: 0) {
            TextField("Title", text: $title)
                .font(.system(.largeTitle, design: .serif).weight(.semibold))
                .textFieldStyle(.plain)
                .foregroundStyle(palette.text)
                .frame(maxWidth: measure)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 28)
                .padding(.top, 28)
                .padding(.bottom, 4)

            EditorTextView(
                text: $source,
                palette: palette,
                font: font,
                lineSpacing: lineSpacing,
                paragraphSpacing: paragraphSpacing,
                measureWidth: measure,
                typewriter: typewriter,
                focusMode: focusMode
            )

            WordCountBar(count: wordCount, palette: palette)
        }
        .background(palette.background)
    }
}

/// Shown when a chapter that has scenes is selected — edit its title and a hint
/// to pick a scene. (A chapter with scenes has no body of its own.)
private struct ChapterOverview: View {
    @Binding var title: String
    let sceneCount: Int
    let palette: EditorPalette

    var body: some View {
        VStack(spacing: 16) {
            TextField("Chapter title", text: $title)
                .font(.system(.largeTitle, design: .serif).weight(.semibold))
                .textFieldStyle(.plain)
                .multilineTextAlignment(.center)
                .foregroundStyle(palette.text)
                .frame(maxWidth: 520)
            Text("\(sceneCount) \(sceneCount == 1 ? "scene" : "scenes") — select one in the sidebar to write.")
                .font(.system(.body, design: .serif))
                .foregroundStyle(palette.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
        .background(palette.background)
    }
}

private struct WordCountBar: View {
    let count: Int
    let palette: EditorPalette

    var body: some View {
        VStack(spacing: 0) {
            Divider().opacity(0.4)
            HStack {
                Spacer()
                Text("\(count) \(count == 1 ? "word" : "words")")
                    .font(.caption)
                    .foregroundStyle(palette.text.opacity(0.55))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
            }
        }
        .background(palette.background)
    }
}

private struct EmptyChapterState: View {
    let palette: EditorPalette

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "book.closed")
                .font(.system(size: 40, weight: .light))
                .foregroundStyle(palette.text.opacity(0.35))
            Text("Select a chapter to start writing")
                .font(.system(.title3, design: .serif))
                .foregroundStyle(palette.text.opacity(0.6))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.background)
    }
}

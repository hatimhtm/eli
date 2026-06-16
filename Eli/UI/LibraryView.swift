import SwiftUI

/// App root: shows the library shelf, or the open book's editor. The writer
/// never picks a file — Eli manages everything.
struct RootView: View {
    @StateObject private var library = LibraryStore()
    @State private var openBookID: UUID?

    @AppStorage("editor.accent") private var accentRaw = AccentChoice.burgundy.rawValue
    @AppStorage("hasOnboarded") private var hasOnboarded = false
    @State private var showWelcome = false

    var body: some View {
        Group {
            if let id = openBookID, library.exists(id) {
                BookHost(id: id, library: library, onClose: {
                    openBookID = nil
                    library.reload()
                })
            } else {
                LibraryView(library: library, onOpen: { openBookID = $0 })
            }
        }
        .tint((AccentChoice(rawValue: accentRaw) ?? .burgundy).color)
        .frame(minWidth: 880, minHeight: 600)
        .onAppear { if !hasOnboarded { showWelcome = true } }
        .sheet(isPresented: $showWelcome) {
            WelcomeView { hasOnboarded = true; showWelcome = false }
        }
    }
}

/// The shelf of books.
struct LibraryView: View {
    @ObservedObject var library: LibraryStore
    var onOpen: (UUID) -> Void

    private let columns = [GridItem(.adaptive(minimum: 200, maximum: 240), spacing: 22)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Eli").font(.system(size: 34, design: .serif).weight(.bold))
                    Text("Your books").font(.title3).foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                LazyVGrid(columns: columns, alignment: .leading, spacing: 22) {
                    NewBookCard { onOpen(library.createBook()) }
                    ForEach(library.items) { item in
                        BookCard(item: item)
                            .onTapGesture { onOpen(item.id) }
                            .contextMenu {
                                Button("Open") { onOpen(item.id) }
                                Button("Delete Book", role: .destructive) { library.delete(item.id) }
                            }
                    }
                }
            }
            .padding(32)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .toolbar {
            ToolbarItem(placement: .automatic) { UpdateButton(updater: UpdaterModel.shared) }
            ToolbarItem(placement: .primaryAction) {
                Button { onOpen(library.createBook()) } label: {
                    Label("New Book", systemImage: "plus")
                }
            }
        }
        .onAppear { library.reload() }
    }
}

private struct BookCard: View {
    let item: LibraryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            LinearGradient(colors: [Color.accentColor, Color.accentColor.opacity(0.78)],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .frame(height: 124)
                .overlay(alignment: .bottomLeading) {
                    Text(item.title)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .padding(12)
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "book.closed.fill")
                        .foregroundStyle(.white.opacity(0.35))
                        .padding(10)
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(item.author.isEmpty ? "No author yet" : item.author)
                    .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                Text("\(item.chapterCount) \(item.chapterCount == 1 ? "chapter" : "chapters") · \(item.modified.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2).foregroundStyle(.tertiary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
        .background(Color(nsColor: .controlBackgroundColor),
                    in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: Radius.card, style: .continuous).strokeBorder(.quaternary))
        .clipShape(RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
        .contentShape(Rectangle())
    }
}

private struct NewBookCard: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: "plus").font(.system(size: 26, weight: .medium))
                Text("New Book").font(.headline)
            }
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 196)
            .background(Color.accentColor.opacity(0.06),
                        in: RoundedRectangle(cornerRadius: Radius.card, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Radius.card, style: .continuous)
                    .strokeBorder(Color.accentColor.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
            )
        }
        .buttonStyle(.plain)
    }
}

/// Loads a book from the library, hands it to the editor, and auto-saves on a
/// short debounce + on close + when the app is backgrounded.
struct BookHost: View {
    let id: UUID
    @ObservedObject var library: LibraryStore
    var onClose: () -> Void

    @State private var book: Book?
    @State private var saveTask: Task<Void, Never>?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if let binding = Binding($book) {
                ContentView(book: binding, onClose: { saveNow(); onClose() })
            } else {
                ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear { if book == nil { book = library.load(id) ?? Book() } }
        .onChange(of: book) { _ in scheduleSave() }
        .onChange(of: scenePhase) { phase in if phase != .active { saveNow() } }
        .onDisappear { saveTask?.cancel(); saveNow() }
    }

    private func scheduleSave() {
        saveTask?.cancel()
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            if Task.isCancelled { return }
            await MainActor.run { saveNow() }
        }
    }

    private func saveNow() { if let book { library.save(book, id: id) } }
}

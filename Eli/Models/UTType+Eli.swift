import UniformTypeIdentifiers

extension UTType {
    /// The `.eli` book package. Declared in Info.plist (UTExportedTypeDeclarations)
    /// and conforms to `com.apple.package`, so Finder treats the folder as one file.
    static let eliBook = UTType(exportedAs: "com.hatimhtm.eli.book")
}

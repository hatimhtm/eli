import Foundation

/// Minimal store-only (no compression) ZIP writer — enough to build a valid
/// EPUB without any third-party dependency. Validated against `unzip -t`.
enum CRC32 {
    static let table: [UInt32] = (0..<256).map { i -> UInt32 in
        var c = UInt32(i)
        for _ in 0..<8 { c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1) }
        return c
    }
    static func checksum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xFFFFFFFF
        for byte in data { crc = table[Int((crc ^ UInt32(byte)) & 0xFF)] ^ (crc >> 8) }
        return crc ^ 0xFFFFFFFF
    }
}

private func put16(_ d: inout Data, _ v: UInt16) { var x = v.littleEndian; withUnsafeBytes(of: &x) { d.append(contentsOf: $0) } }
private func put32(_ d: inout Data, _ v: UInt32) { var x = v.littleEndian; withUnsafeBytes(of: &x) { d.append(contentsOf: $0) } }

struct ZipArchive {
    private struct Entry { let name: String; let data: Data; let crc: UInt32; let offset: UInt32 }
    private var out = Data()
    private var entries: [Entry] = []

    mutating func add(_ name: String, _ data: Data) {
        let crc = CRC32.checksum(data)
        let offset = UInt32(out.count)
        let nameBytes = Array(name.utf8)
        put32(&out, 0x04034b50)
        put16(&out, 20); put16(&out, 0); put16(&out, 0)   // version, flags, method=store
        put16(&out, 0); put16(&out, 0)                    // mod time/date
        put32(&out, crc)
        put32(&out, UInt32(data.count)); put32(&out, UInt32(data.count))
        put16(&out, UInt16(nameBytes.count)); put16(&out, 0)
        out.append(contentsOf: nameBytes)
        out.append(data)
        entries.append(Entry(name: name, data: data, crc: crc, offset: offset))
    }

    mutating func finalize() -> Data {
        let cdStart = UInt32(out.count)
        for e in entries {
            let nameBytes = Array(e.name.utf8)
            put32(&out, 0x02014b50)
            put16(&out, 20); put16(&out, 20); put16(&out, 0); put16(&out, 0)
            put16(&out, 0); put16(&out, 0)
            put32(&out, e.crc)
            put32(&out, UInt32(e.data.count)); put32(&out, UInt32(e.data.count))
            put16(&out, UInt16(nameBytes.count)); put16(&out, 0); put16(&out, 0)
            put16(&out, 0); put16(&out, 0)
            put32(&out, 0)
            put32(&out, e.offset)
            out.append(contentsOf: nameBytes)
        }
        let cdSize = UInt32(out.count) - cdStart
        put32(&out, 0x06054b50)
        put16(&out, 0); put16(&out, 0)
        put16(&out, UInt16(entries.count)); put16(&out, UInt16(entries.count))
        put32(&out, cdSize); put32(&out, cdStart)
        put16(&out, 0)
        return out
    }
}

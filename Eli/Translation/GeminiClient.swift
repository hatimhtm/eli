import Foundation

enum TranslationError: LocalizedError {
    case missingKey
    case emptyResponse
    case truncated
    case api(String)

    var errorDescription: String? {
        switch self {
        case .missingKey:    return "Add your Gemini API key in Settings (⌘,) to translate."
        case .emptyResponse: return "The model returned no text. Try again, or switch model in Settings."
        case .truncated:     return "The chapter was too long and the translation was cut off. Split it into shorter chapters and try again."
        case .api(let m):    return "Translation failed: \(m)"
        }
    }
}

/// Thin client over the Gemini `generateContent` REST endpoint.
///
/// NOTE: Gemini 3.x models spend output tokens on internal "thinking", so we
/// request a generous `maxOutputTokens` — too small a budget truncates the
/// translation mid-sentence (confirmed during research).
struct GeminiClient {
    var apiKey: String
    var model: String

    func generate(
        systemInstruction: String,
        prompt: String,
        temperature: Double = 0.7,
        maxOutputTokens: Int = 8192
    ) async throws -> String {
        guard let url = URL(string:
            "https://generativelanguage.googleapis.com/v1beta/models/\(model):generateContent")
        else { throw TranslationError.api("Invalid request URL.") }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-goog-api-key") // key in header, not URL
        request.httpBody = try JSONEncoder().encode(RequestBody(
            system_instruction: .init(parts: [.init(text: systemInstruction)]),
            contents: [.init(parts: [.init(text: prompt)])],
            generationConfig: .init(temperature: temperature, maxOutputTokens: maxOutputTokens)
        ))

        let (data, response) = try await URLSession.shared.data(for: request)

        // Surface transport/HTTP errors before attempting to decode JSON.
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            let serverMessage = (try? JSONDecoder().decode(ResponseBody.self, from: data))?.error?.message
            throw TranslationError.api(serverMessage ?? "HTTP \(http.statusCode)")
        }

        let decoded = try JSONDecoder().decode(ResponseBody.self, from: data)
        if let message = decoded.error?.message {
            throw TranslationError.api(message)
        }

        let candidate = decoded.candidates?.first
        let text = candidate?.content?.parts?.compactMap { $0.text }.joined() ?? ""
        if text.isEmpty { throw TranslationError.emptyResponse }
        // The model hit the output-token ceiling — the result is cut off.
        if candidate?.finishReason == "MAX_TOKENS" { throw TranslationError.truncated }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: Wire format

    private struct RequestBody: Encodable {
        let system_instruction: Instruction
        let contents: [Instruction]
        let generationConfig: GenerationConfig

        struct Instruction: Encodable { let parts: [Part] }
        struct Part: Encodable { let text: String }
        struct GenerationConfig: Encodable {
            let temperature: Double
            let maxOutputTokens: Int
        }
    }

    private struct ResponseBody: Decodable {
        let candidates: [Candidate]?
        let error: APIError?

        struct Candidate: Decodable { let content: Content?; let finishReason: String? }
        struct Content: Decodable { let parts: [Part]? }
        struct Part: Decodable { let text: String? }
        struct APIError: Decodable { let message: String? }
    }
}

import Foundation

struct SpiceAIInfo: Codable {
    let latinName: String
    let about: String
    let storageMethod: String
    let storageIcon: String
    let regionalNames: [RegionalName]
    let alternatives: [AlternativeSpice]
    
    enum CodingKeys: String, CodingKey {
        case latinName = "latin_name"
        case about
        case storageMethod = "storage_method"
        case storageIcon = "storage_icon"
        case regionalNames = "regional_names"
        case alternatives
    }
}

actor AIService {
    static let shared = AIService()
    
    private let endpoint = "https://oss.dicoding-ai.dev/v1/chat/completions"
    private let model = "openai/gpt-oss-20b"
    
    func fetchSpiceInfo(for spiceName: String) async throws -> SpiceAIInfo {
        let prompt = """
        Berikan informasi singkat tentang rempah "\(spiceName)" dalam Bahasa Indonesia.
        Jawab HANYA dalam JSON format persis seperti ini:
        {
          "latin_name": "...",
          "about": "2-3 kalimat penjelasan tentang rempah ini.",
          "storage_method": "Cara menyimpan yang baik.",
          "storage_icon": "thermometer.snowflake",
          "regional_names": [
            {"language": "Jawa", "name": "..."},
            {"language": "Sunda", "name": "..."}
          ],
          "alternatives": [
            {"name": "Nama Rempah Alternatif 1", "reason": "Alasan singkat mengapa bisa menjadi alternatif."},
            {"name": "Nama Rempah Alternatif 2", "reason": "Alasan singkat mengapa bisa menjadi alternatif."}
          ]
        }
        Catatan untuk storage_icon: Gunakan nama SF Symbol yang valid (contoh: thermometer.snowflake, leaf, leaf.fill, drop.fill, dll).
        """
        
        guard let url = URL(string: endpoint) else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that only outputs valid JSON."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            if let str = String(data: data, encoding: .utf8) {
                print("API Error: \\(str)")
            }
            throw URLError(.badServerResponse)
        }
        
        // Parse OpenAI Chat Completion response
        struct ChatResponse: Codable {
            struct Choice: Codable {
                struct Message: Codable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let contentString = chatResponse.choices.first?.message.content else {
            throw URLError(.cannotParseResponse)
        }
        
        // Clean up markdown code blocks if any
        let cleanString = contentString.replacingOccurrences(of: "```json", with: "")
                                       .replacingOccurrences(of: "```", with: "")
                                       .trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = cleanString.data(using: .utf8) else {
            throw URLError(.cannotParseResponse)
        }
        
        let info = try JSONDecoder().decode(SpiceAIInfo.self, from: jsonData)
        return info
    }
}

//
//  ChatbotService.swift
//  PHAInspection
//
//  API service for AWS Bedrock RAG chatbot
//

import Foundation

struct ChatbotMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp = Date()
}

struct ChatbotQueryRequest: Codable {
    let question: String
}

struct ChatbotQueryResponse: Codable {
    let question: String
    let answer: String
}

class ChatbotService {
    static let shared = ChatbotService()
    private init() {}

    func query(question: String) async throws -> String {
        guard let token = AuthManager.shared.token else {
            throw NetworkError.unauthorized
        }

        let urlString = APIConfig.baseURL + "/chatbot/query"
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(APIConfig.Headers.applicationJSON, forHTTPHeaderField: APIConfig.Headers.contentType)
        request.setValue(APIConfig.Headers.bearerToken(token), forHTTPHeaderField: APIConfig.Headers.authorization)
        request.timeoutInterval = 30

        let body = ChatbotQueryRequest(question: question)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.serverError("Failed to get chatbot response")
        }

        let result = try JSONDecoder().decode(ChatbotQueryResponse.self, from: data)
        return result.answer
    }
}

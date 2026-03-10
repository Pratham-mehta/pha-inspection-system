//
//  ChatbotView.swift
//  PHAInspection
//
//  Floating chatbot bubble + chat sheet powered by AWS Bedrock RAG
//

import SwiftUI

// MARK: - Floating Chat Button
struct ChatbotFAB: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: { isPresented = true }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [.locomexPrimary, .locomexDark]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .shadow(color: Color.locomexDark.opacity(0.4), radius: 8, x: 0, y: 4)

                        Image(systemName: "message.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.trailing, 24)
                .padding(.bottom, 32)
            }
        }
    }
}

// MARK: - Chat Sheet
struct ChatbotSheet: View {
    @Binding var isPresented: Bool
    @State private var messages: [ChatbotMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @FocusState private var isInputFocused: Bool

    private let welcomeMessage = ChatbotMessage(
        text: "Hi! I'm your PHA Inspection Assistant. Ask me anything about inspection procedures, deficiencies, activity codes, or housing standards.",
        isUser: false
    )

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            // Welcome message
                            ChatBubble(message: welcomeMessage)

                            ForEach(messages) { message in
                                ChatBubble(message: message)
                                    .id(message.id)
                            }

                            if isLoading {
                                TypingIndicator()
                                    .id("typing")
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .onChange(of: messages.count) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                    .onChange(of: isLoading) { _ in
                        scrollToBottom(proxy: proxy)
                    }
                }

                Divider()

                // Suggested questions (shown when no messages)
                if messages.isEmpty {
                    suggestedQuestions
                }

                // Input bar
                inputBar
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("PHA Assistant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                    .foregroundColor(.locomexPrimary)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: clearChat) {
                        Image(systemName: "trash")
                            .foregroundColor(.locomexPrimary)
                    }
                    .disabled(messages.isEmpty)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    // MARK: - Suggested Questions
    private var suggestedQuestions: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Suggested questions")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { suggestion in
                        Button(action: { sendMessage(suggestion) }) {
                            Text(suggestion)
                                .font(.system(size: 13))
                                .foregroundColor(.locomexDark)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.locomexBackground)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.locomexPrimary.opacity(0.4), lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)
            }
        }
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 12) {
            TextField("Ask about inspections...", text: $inputText, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(UIColor.systemBackground))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.locomexPrimary.opacity(0.3), lineWidth: 1)
                )
                .focused($isInputFocused)
                .onSubmit { sendCurrentMessage() }

            Button(action: sendCurrentMessage) {
                Image(systemName: isLoading ? "ellipsis" : "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(canSend ? .locomexPrimary : .secondary)
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Helpers
    private var canSend: Bool {
        !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }

    private var suggestions: [String] {
        [
            "What are common kitchen deficiencies?",
            "What is RRP?",
            "Bathroom leakage issue?",
            "Activity code for plumbing?",
            "What is a PMI inspection?",
            "Smoke detector requirements?"
        ]
    }

    private func sendCurrentMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        sendMessage(text)
    }

    private func sendMessage(_ text: String) {
        let userMessage = ChatbotMessage(text: text, isUser: true)
        messages.append(userMessage)
        isLoading = true
        isInputFocused = false

        Task {
            do {
                let answer = try await ChatbotService.shared.query(question: text)
                await MainActor.run {
                    messages.append(ChatbotMessage(text: answer, isUser: false))
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    messages.append(ChatbotMessage(
                        text: "Sorry, I couldn't get a response. Please try again.",
                        isUser: false
                    ))
                    isLoading = false
                }
            }
        }
    }

    private func clearChat() {
        messages = []
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if isLoading {
            withAnimation { proxy.scrollTo("typing", anchor: .bottom) }
        } else if let last = messages.last {
            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
        }
    }
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatbotMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser { Spacer(minLength: 60) }

            if !message.isUser {
                // Bot avatar
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.locomexPrimary, .locomexDark]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 32, height: 32)
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
            }

            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.system(size: 15))
                    .foregroundColor(message.isUser ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(message.isUser
                        ? AnyView(LinearGradient(
                            gradient: Gradient(colors: [.locomexPrimary, .locomexDark]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                          ))
                        : AnyView(Color(UIColor.systemBackground))
                    )
                    .cornerRadius(18)
                    .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

                Text(timeString(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.isUser { Spacer(minLength: 0) }
            if !message.isUser { Spacer(minLength: 60) }
        }
    }

    private func timeString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [.locomexPrimary, .locomexDark]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 32, height: 32)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
            }

            HStack(spacing: 4) {
                ForEach(0..<3) { i in
                    Circle()
                        .fill(Color.secondary.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.2 : 0.8)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(i) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(18)
            .shadow(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

            Spacer(minLength: 60)
        }
        .onAppear { animating = true }
    }
}

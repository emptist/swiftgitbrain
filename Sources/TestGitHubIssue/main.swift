import Foundation
import GitBrainSwift

@main
struct TestGitHubIssue {
    static func main() async {
        print("Testing GitHub Issue sending...")
        print()

        guard let token = ProcessInfo.processInfo.environment["GITHUB_TOKEN"] else {
            print("Error: GITHUB_TOKEN environment variable not set")
            print("Please set your GitHub Personal Access Token:")
            print("  export GITHUB_TOKEN=your_token_here")
            exit(1)
        }

        let owner = ProcessInfo.processInfo.environment["GITHUB_OWNER"] ?? "your-username"
        let repo = ProcessInfo.processInfo.environment["GITHUB_REPO"] ?? "gitbrainswift"

        print("GitHub Configuration:")
        print("  Owner: \(owner)")
        print("  Repository: \(repo)")
        print("  Token: \(String(token.prefix(10)))...")
        print()

        let communication = GitHubCommunication(owner: owner, repo: repo, token: token)

        let testMessage = Message(
            id: UUID().uuidString,
            fromAI: "test",
            toAI: "coder",
            messageType: .task,
            content: ["message": "Test message from GitHub issue"],
            timestamp: ISO8601DateFormatter().string(from: Date()),
            priority: 0,
            metadata: [:]
        )

        print("Sending test message to GitHub...")
        do {
            let issueURL = try await communication.sendMessage(testMessage, from: "test", to: "coder")
            print("✓ Message sent successfully!")
            print("  Issue URL: \(issueURL.absoluteString)")
        } catch {
            print("✗ Failed to send message: \(error)")
            exit(1)
        }
    }
}

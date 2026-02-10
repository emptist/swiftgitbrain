import Foundation

public actor GitHubCommunication: CommunicationProtocol {
    private let owner: String
    private let repo: String
    private let token: String
    private let baseURL: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    
    public init(owner: String, repo: String, token: String) {
        self.owner = owner
        self.repo = repo
        self.token = token
        self.baseURL = "https://api.github.com/repos/\(owner)/\(repo)"
        self.session = URLSession.shared
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = .prettyPrinted
        self.decoder = JSONDecoder()
    }
    
    public func createIssue(
        title: String,
        body: String,
        labels: [String] = []
    ) async throws -> Issue {
        let url = URL(string: "\(baseURL)/issues")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let issueData: [String: Any] = [
            "title": title,
            "body": body,
            "labels": labels
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: issueData)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw GitHubError.requestFailed
        }
        
        let issue = try JSONDecoder().decode(Issue.self, from: data)
        return issue
    }
    
    public func createPullRequest(
        title: String,
        sourceBranch: String,
        targetBranch: String,
        body: String = ""
    ) async throws -> PullRequest {
        let url = URL(string: "\(baseURL)/pulls")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prData: [String: Any] = [
            "title": title,
            "head": sourceBranch,
            "base": targetBranch,
            "body": body
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: prData)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw GitHubError.requestFailed
        }
        
        let pr = try JSONDecoder().decode(PullRequest.self, from: data)
        return pr
    }
    
    public func addComment(
        toIssue issueNumber: Int,
        comment: String
    ) async throws {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)/comments")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let commentData: [String: String] = [
            "body": comment
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: commentData)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw GitHubError.requestFailed
        }
    }
    
    public func getIssues(
        state: String = "open",
        labels: [String] = []
    ) async throws -> [Issue] {
        var urlComponents = URLComponents(string: "\(baseURL)/issues")!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "state", value: state)
        ]
        
        if !labels.isEmpty {
            queryItems.append(URLQueryItem(name: "labels", value: labels.joined(separator: ",")))
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let issues = try JSONDecoder().decode([Issue].self, from: data)
        return issues
    }
    
    public func closeIssue(issueNumber: Int) async throws {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let issueData: [String: String] = [
            "state": "closed"
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: issueData)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
    }
    
    public func getPullRequests(state: String = "open") async throws -> [PullRequest] {
        var urlComponents = URLComponents(string: "\(baseURL)/pulls")!
        urlComponents.queryItems = [
            URLQueryItem(name: "state", value: state)
        ]
        
        guard let url = urlComponents.url else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let prs = try JSONDecoder().decode([PullRequest].self, from: data)
        return prs
    }
    
    public func mergePullRequest(pullNumber: Int) async throws {
        let url = URL(string: "\(baseURL)/pulls/\(pullNumber)/merge")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let mergeData: [String: String] = [:]
        request.httpBody = try JSONSerialization.data(withJSONObject: mergeData)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
    }
    
    public func updatePullRequest(
        pullNumber: Int,
        title: String? = nil,
        body: String? = nil,
        state: String? = nil
    ) async throws -> PullRequest {
        let url = URL(string: "\(baseURL)/pulls/\(pullNumber)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var updateData: [String: Any] = [:]
        
        if let title = title {
            updateData["title"] = title
        }
        
        if let body = body {
            updateData["body"] = body
        }
        
        if let state = state {
            updateData["state"] = state
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: updateData)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let pr = try JSONDecoder().decode(PullRequest.self, from: data)
        return pr
    }
    
    public func getPullRequest(pullNumber: Int) async throws -> PullRequest {
        let url = URL(string: "\(baseURL)/pulls/\(pullNumber)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let pr = try JSONDecoder().decode(PullRequest.self, from: data)
        return pr
    }
    
    public func addLabel(
        toIssue issueNumber: Int,
        label: String
    ) async throws {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)/labels")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let labelData: [String: [String]] = ["labels": [label]]
        request.httpBody = try JSONSerialization.data(withJSONObject: labelData)
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
    }
    
    public func removeLabel(
        fromIssue issueNumber: Int,
        label: String
    ) async throws {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)/labels/\(label)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
    }
    
    public func getIssue(issueNumber: Int) async throws -> Issue {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let issue = try JSONDecoder().decode(Issue.self, from: data)
        return issue
    }
    
    public func updateIssue(
        issueNumber: Int,
        title: String? = nil,
        body: String? = nil,
        state: String? = nil,
        labels: [String]? = nil
    ) async throws -> Issue {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var updateData: [String: Any] = [:]
        
        if let title = title {
            updateData["title"] = title
        }
        
        if let body = body {
            updateData["body"] = body
        }
        
        if let state = state {
            updateData["state"] = state
        }
        
        if let labels = labels {
            updateData["labels"] = labels
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: updateData)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let issue = try JSONDecoder().decode(Issue.self, from: data)
        return issue
    }
    
    public func getIssueComments(issueNumber: Int) async throws -> [IssueComment] {
        let url = URL(string: "\(baseURL)/issues/\(issueNumber)/comments")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let comments = try JSONDecoder().decode([IssueComment].self, from: data)
        return comments
    }
    
    public func getRepository() async throws -> Repository {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let repository = try JSONDecoder().decode(Repository.self, from: data)
        return repository
    }
    
    public func getBranches() async throws -> [Branch] {
        let url = URL(string: "\(baseURL)/branches")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let branches = try JSONDecoder().decode([Branch].self, from: data)
        return branches
    }
    
    public func createBranch(
        branchName: String,
        fromBranch: String = "main"
    ) async throws -> Branch {
        let url = URL(string: "\(baseURL)/git/refs")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let ref = "refs/heads/\(fromBranch)"
        let branchData: [String: Any] = [
            "ref": "refs/heads/\(branchName)",
            "sha": ref
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: branchData)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 201 else {
            throw GitHubError.requestFailed
        }
        
        let branch = try JSONDecoder().decode(Branch.self, from: data)
        return branch
    }
    
    public func deleteBranch(branchName: String) async throws {
        let url = URL(string: "\(baseURL)/git/refs/heads/\(branchName)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (_, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 204 else {
            throw GitHubError.requestFailed
        }
    }
    
    public func getFileContent(path: String, ref: String = "main") async throws -> FileContent {
        let url = URL(string: "\(baseURL)/contents/\(path)")!
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = [
            URLQueryItem(name: "ref", value: ref)
        ]
        
        guard let url = urlComponents.url else {
            throw GitHubError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let content = try JSONDecoder().decode(FileContent.self, from: data)
        return content
    }
    
    public func createOrUpdateFile(
        path: String,
        content: String,
        message: String = "Update file",
        branch: String = "main",
        sha: String? = nil
    ) async throws -> FileContent {
        let url = URL(string: "\(baseURL)/contents/\(path)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let contentData = Data(content.utf8).base64EncodedString()
        var fileData: [String: Any] = [
            "message": message,
            "content": contentData,
            "branch": branch
        ]
        
        if let sha = sha {
            fileData["sha"] = sha
        }
        
        request.httpBody = try JSONSerialization.data(withJSONObject: fileData)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            throw GitHubError.requestFailed
        }
        
        let result = try JSONDecoder().decode(FileContent.self, from: data)
        return result
    }
    
    public func getRateLimit() async throws -> RateLimit {
        let url = URL(string: "https://api.github.com/rate_limit")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw GitHubError.requestFailed
        }
        
        let rateLimit = try JSONDecoder().decode(RateLimit.self, from: data)
        return rateLimit
    }
    
    public func sendMessage(_ message: Message, from: String, to: String) async throws -> URL {
        let messageData = try encoder.encode(message)
        let messageJSON = String(data: messageData, encoding: .utf8) ?? "{}"
        
        let title = "[\(to)] \(message.messageType.rawValue): \(message.id.prefix(8))"
        let body = """
        **From:** \(from)
        **To:** \(to)
        **Type:** \(message.messageType.rawValue)
        **Timestamp:** \(message.timestamp)
        **Priority:** \(message.priority)
        
        ```json
        \(messageJSON)
        ```
        """
        
        let labels = [
            "gitbrain",
            "message-\(message.messageType.rawValue)",
            "to-\(to)"
        ]
        
        let issue = try await createIssue(title: title, body: body, labels: labels)
        return URL(string: issue.url)!
    }
    
    public func receiveMessages(for role: String) async throws -> [Message] {
        let issues = try await getIssues(state: "open", labels: ["to-\(role)"])
        
        var messages: [Message] = []
        var issueNumbersToClose: [Int] = []
        
        for issue in issues {
            if let body = issue.body,
               let jsonStart = body.range(of: "```json"),
               let jsonEnd = body.range(of: "```", range: jsonStart.upperBound..<body.endIndex) {
                
                let jsonString = String(body[jsonStart.upperBound..<jsonEnd.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if let data = jsonString.data(using: .utf8) {
                    do {
                        let message = try decoder.decode(Message.self, from: data)
                        messages.append(message)
                        issueNumbersToClose.append(issue.number)
                    } catch {
                        print("Failed to decode message from issue #\(issue.number): \(error)")
                    }
                }
            }
        }
        
        for issueNumber in issueNumbersToClose {
            try? await closeIssue(issueNumber: issueNumber)
        }
        
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    public func getMessageCount(for role: String) async throws -> Int {
        let issues = try await getIssues(state: "open", labels: ["to-\(role)"])
        return issues.count
    }
    
    public func clearMessages(for role: String) async throws -> Int {
        let issues = try await getIssues(state: "open", labels: ["to-\(role)"])
        var count = 0
        
        for issue in issues {
            try? await closeIssue(issueNumber: issue.number)
            count += 1
        }
        
        return count
    }
}

public struct Issue: Codable, Sendable, Identifiable {
    public let id: Int
    public let number: Int
    public let title: String
    public let body: String?
    public let state: String
    public let labels: [Label]
    public let createdAt: String
    public let updatedAt: String
    public let url: String
    
    enum CodingKeys: String, CodingKey {
        case id, number, title, body, state, labels, url
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct Label: Codable, Sendable {
    public let name: String
    public let color: String
}

public struct PullRequest: Codable, Sendable, Identifiable {
    public let id: Int
    public let number: Int
    public let title: String
    public let body: String?
    public let state: String
    public let head: BranchRef
    public let base: BranchRef
    public let createdAt: String
    public let updatedAt: String
    public let url: String
    public let merged: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id, number, title, body, state, head, base, url, merged
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct BranchRef: Codable, Sendable {
    public let label: String
    public let ref: String
    public let sha: String
}

public enum GitHubError: Error, LocalizedError {
    case requestFailed
    case invalidURL
    case unauthorized
    case notFound
    case rateLimitExceeded
    
    public var errorDescription: String? {
        switch self {
        case .requestFailed:
            return "GitHub API request failed"
        case .invalidURL:
            return "Invalid GitHub API URL"
        case .unauthorized:
            return "Unauthorized: Invalid GitHub token"
        case .notFound:
            return "Resource not found"
        case .rateLimitExceeded:
            return "GitHub API rate limit exceeded"
        }
    }
}

public struct IssueComment: Codable, Sendable, Identifiable {
    public let id: Int
    public let user: GitHubUser
    public let createdAt: String
    public let updatedAt: String
    public let body: String
    
    enum CodingKeys: String, CodingKey {
        case id, user, body
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct GitHubUser: Codable, Sendable {
    public let login: String
    public let id: Int
    public let type: String
}

public struct Repository: Codable, Sendable {
    public let id: Int
    public let name: String
    public let fullName: String
    public let isPrivate: Bool
    public let owner: GitHubUser
    public let createdAt: String
    public let updatedAt: String
    public let url: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, owner, url
        case isPrivate = "private"
        case fullName = "full_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

public struct Branch: Codable, Sendable, Identifiable {
    public let id: String
    public let name: String
    public let commit: BranchCommit
    public let protected: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, commit, protected
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.commit = try container.decode(BranchCommit.self, forKey: .commit)
        self.protected = try container.decode(Bool.self, forKey: .protected)
        self.id = name
    }
}

public struct BranchCommit: Codable, Sendable {
    public let sha: String
    public let url: String
}

public struct FileContent: Codable, Sendable {
    public let name: String
    public let path: String
    public let sha: String
    public let size: Int
    public let url: String
    public let htmlURL: String
    public let gitURL: String
    public let content: String
    public let encoding: String
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, size, url, content, encoding
        case htmlURL = "html_url"
        case gitURL = "git_url"
    }
}

public struct RateLimit: Codable, Sendable {
    public let resources: RateLimitResources
    
    public struct RateLimitResources: Codable, Sendable {
        public let core: RateLimitInfo
        public let search: RateLimitInfo
        public let graphql: RateLimitInfo
        public let integrationManifest: RateLimitInfo
        public let codeScanningUpload: RateLimitInfo
    }
}

public struct RateLimitInfo: Codable, Sendable {
    public let limit: Int
    public let used: Int
    public let remaining: Int
    public let reset: Int
}
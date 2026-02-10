import Foundation

public actor GitHubCommunication {
    private let owner: String
    private let repo: String
    private let token: String
    private let baseURL: String
    private let session: URLSession
    
    public init(owner: String, repo: String, token: String) {
        self.owner = owner
        self.repo = repo
        self.token = token
        self.baseURL = "https://api.github.com/repos/\(owner)/\(repo)"
        self.session = URLSession.shared
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
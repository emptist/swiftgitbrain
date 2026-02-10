import Foundation
import Combine
import Observation

@Observable
public class GitBrainSystemViewModel: @unchecked Sendable {
    public private(set) var system: SystemConfig
    public private(set) var communication: any CommunicationProtocol
    public private(set) var memoryManager: BrainStateManager
    public private(set) var coderViewModel: CoderAIViewModel
    public private(set) var overseerViewModel: OverseerAIViewModel
    public private(set) var isRunning: Bool = false
    public private(set) var isLoading: Bool = false
    public private(set) var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(
        system: SystemConfig,
        communication: any CommunicationProtocol,
        memoryManager: BrainStateManager
    ) {
        self.system = system
        self.communication = communication
        self.memoryManager = memoryManager
        
        let coderRoleConfig = system.getRoleConfig(roleName: "coder") ?? RoleConfig(
            name: "coder",
            roleType: .coder,
            enabled: true,
            mailbox: "coder",
            brainstateFile: "coder_state.json",
            capabilities: []
        )
        
        let overseerRoleConfig = system.getRoleConfig(roleName: "overseer") ?? RoleConfig(
            name: "overseer",
            roleType: .overseer,
            enabled: true,
            mailbox: "overseer",
            brainstateFile: "overseer_state.json",
            capabilities: []
        )
        
        let memoryStore = MemoryStore()
        let knowledgeBase = KnowledgeBase(base: URL(fileURLWithPath: system.brainstateBase))
        
        let coder = CoderAI(
            system: system,
            roleConfig: coderRoleConfig,
            communication: communication,
            memoryManager: memoryManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )
        
        let overseer = OverseerAI(
            system: system,
            roleConfig: overseerRoleConfig,
            communication: communication,
            memoryManager: memoryManager,
            memoryStore: memoryStore,
            knowledgeBase: knowledgeBase
        )
        
        self.coderViewModel = CoderAIViewModel(coder: coder)
        self.overseerViewModel = OverseerAIViewModel(overseer: overseer)
    }
    
    public func initialize() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        try await coderViewModel.initialize()
        try await overseerViewModel.initialize()
        
        isRunning = true
    }
    
    public func loadAllMessages() async throws {
        isLoading = true
        errorMessage = nil
        
        defer {
            isLoading = false
        }
        
        try await coderViewModel.loadMessages()
        try await overseerViewModel.loadMessages()
    }
    
    public func refreshAllStatuses() async {
        await coderViewModel.refreshStatus()
        await overseerViewModel.refreshStatus()
    }
    
    public func getSystemStatus() async -> [String: Any] {
        return [
            "name": system.name,
            "version": system.version,
            "brainstate_base": system.brainstateBase,
            "is_running": isRunning,
            "coder_status": await coderViewModel.coder.getStatus(),
            "overseer_status": await overseerViewModel.overseer.getStatus()
        ]
    }
    
    public func getMessageCount(roleName: String) async -> Int {
        do {
            return try await communication.getMessageCount(for: roleName)
        } catch {
            return 0
        }
    }
    
    public func cleanup() async {
        await coderViewModel.cleanup()
        await overseerViewModel.cleanup()
        cancellables.removeAll()
        isRunning = false
    }
}
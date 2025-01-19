import Foundation
import Combine
import SwiftUI

enum SocialDataType {
    case friends
    case pendingRequests
    case monthlyStats(String, String) // friendId, yearMonth
    case friendTodos(String, String) // friendId, date
}

/// 소셜 기능 화면의 상태와 로직을 관리하는 ViewModel
///
/// 친구 관리, 검색, 통계 데이터 공유 기능을 제공합니다.
///
/// ## 주요 기능
/// - 친구 검색 및 요청 관리
/// - 친구 통계 데이터 조회
/// - 친구 요청 수락/거절 처리
///
/// ## 상태 프로퍼티
/// ```swift
/// @Published var friends: [User]           // 친구 목록
/// @Published var searchResults: [User]     // 검색 결과
/// @Published var pendingRequests: [FriendRequest] // 대기중인 요청
/// ```
@MainActor
class SocialViewModel: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    // MARK: - UI State
    
    // 메인 뷰 상태
    @Published var friends: [User] = []
    @Published var selectedFriend: User?
    @Published var friendDailyStats: [DailyStat] = []
    @Published var currentDate: Date = Date().koreanDate
    
    // 친구 요청 목록 상태
    @Published var pendingRequests: [FriendRequest] = []
     
    // 친구 검색 상태
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    
    // UI 컨트롤 상태
    @Published var isLoading = false
    @Published var isDetailSectionPresent: Bool = false
    
    // 세부 정보 상태
    var dailyStatForDate: DailyStat = .empty
    var todosForDate: [Todo] = []
    
    // MARK: - UseCases
    private let userUseCase: UserUseCaseProtocol
    private let todoUseCase: TodoUseCaseProtocol
    private let dailyStatUseCase: DailyStatUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        userUseCase: UserUseCaseProtocol = UserUseCase(),
        todoUseCase: TodoUseCaseProtocol = TodoUseCase(),
        dailyStatUseCase: DailyStatUseCaseProtocol = DailyStatUseCase()
    ) {
        self.userUseCase = userUseCase
        self.todoUseCase = todoUseCase
        self.dailyStatUseCase = dailyStatUseCase
        
        initialize()
        setupSearchSubscription()
    }
    
    // MARK: - Public Methods
    
    func initialize() {
        Task {
            await fetchData(.friends)
            await fetchData(.pendingRequests)
        }
    }
    
    func fetchPendingRequests() {
        Task {
            await fetchData(.pendingRequests)
        }
    }
    
    func handleUserButtonClick(_ selectedUser: SearchResult) {
        Task {
            if selectedUser.isPending {
                ToastManager.shared.show(.friendAlreadyRequested(selectedUser.username))
            } else {
                if selectedUser.isFriend {
                    selectFriend(User(
                        id: selectedUser.id,
                        username: selectedUser.username,
                        email: selectedUser.email
                    ))
                    navigationPath.removeLast()
                } else {
                    await requestFriend(selectedUser)
                }
            }
        }
    }
    
    func selectFriend(_ friend: User) {
        selectedFriend = friend
        currentDate = Date().koreanDate
        
        Task {
            if let friendId = selectedFriend?.id {
                await fetchData(.monthlyStats(friendId, currentDate.apiFormat.prefix(7).description))
            }
        }
    }
    
    func selectCalendarDate(_ date: Date) {
        guard let index = friendDailyStats.firstIndex(where: { date.apiFormat == $0.date}),
              let friendId = selectedFriend?.id else { return }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            dailyStatForDate = friendDailyStats[index]
            
            await fetchData(.friendTodos(friendId, date.apiFormat))
            
            isDetailSectionPresent = true
        }
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await userUseCase.acceptFriendRequest(request.id)
                ToastManager.shared.show(.friendRequestAccepted(request.fromUser.username))
                
                pendingRequests.removeAll { $0.id == request.id }
                
                await fetchData(.friends)
            } catch {
                print("Accept friend request error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func setupSearchSubscription() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .filter { !$0.isEmpty }
            .sink { [weak self] query in
                Task {
                    await self?.performSearch(query)
                }
            }
            .store(in: &cancellables)
    }
    
    private func fetchData(_ dataType: SocialDataType) async {
        do {
            switch dataType {
            case .friends:
                friends = try await userUseCase.getFriends()
                
                if selectedFriend == nil, let firstFriend = friends.first {
                    selectFriend(firstFriend)
                } else if let selected = selectedFriend,
                          !friends.contains(where: { $0.id == selected.id }) {
                    selectedFriend = nil
                }
                
            case .pendingRequests:
                pendingRequests = try await userUseCase.getPendingRequests()
                
            case .monthlyStats(let friendId, let yearMonth):
                friendDailyStats = try await dailyStatUseCase.getMonthStats(in: yearMonth, for: friendId)
                
            case .friendTodos(let friendId, let date):
                todosForDate = try await todoUseCase.getTodos(in: date, for: friendId)
            }
        } catch {
            print("Error fetching \(dataType): \(error)")
        }
    }
    
    private func performSearch(_ query: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            searchResults = try await userUseCase.searchUsers(query: query)
        } catch {
            print("Search error: \(error)")
            searchResults = []
        }
    }
    
    private func requestFriend(_ user: SearchResult) async {
        isLoading = true
        defer { isLoading = false }
        
        Task {
            do {
                try await userUseCase.requestFriend(userId: user.id)
                if let index = searchResults.firstIndex(where: { $0.id == user.id }) {
                    searchResults[index].isPending = true
                }
                ToastManager.shared.show(.friendRequested(user.username))
            } catch {
                print("Request friend error: \(error)")
                ToastManager.shared.show(.error(error.localizedDescription))
            }
        }
    }
}

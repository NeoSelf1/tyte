import Foundation
import Combine
import Alamofire
import SwiftUI

class SocialViewModel: ObservableObject {
    let appState = AppState.shared
    
    // MARK: 소셜(메인)뷰에 필요
    @Published var friends: [User] = []
    @Published var selectedFriend: User?
    @Published var currentMonth: Date = Date().koreanDate
    @Published var friendDailyStats: [DailyStat] = []
    
    // MARK: 캘린더 아이템 클릭 시 세부 정보창 조회 위해 필요
    @Published var isDetailViewPresented: Bool = false
    @Published var dailyStatForDate: DailyStat = dummyDailyStat // TODO: 세부 아이템으로 변경가능
    @Published var todosForDate: [Todo] = []
    
    // MARK: Request List에 필요
    @Published var pendingRequests: [FriendRequest] = []
    
    // MARK: 친구 탐색창에 필요
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var selectedUser: SearchResult?
    @Published var isLoading = false
    
    private let dailyStatService: DailyStatService
    private let todoService: TodoService
    private let authService: AuthService
    private let socialService: SocialService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        dailyStatService: DailyStatService = DailyStatService.shared,
        authService: AuthService = AuthService.shared,
        todoService: TodoService = TodoService.shared,
        socialService:SocialService = SocialService.shared
    ) {
        self.dailyStatService = dailyStatService
        self.todoService = todoService
        self.authService = authService
        self.socialService = socialService
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                if !query.isEmpty {
                    self?.performSearch(query)
                }
            }
            .store(in: &cancellables)
    }
    
    func selectFriend(_ friend: User) {
        selectedFriend = friend
        fetchFriendDailyStats(friendId: friend.id)
    }
    
    func fetchFriendDailyStats(friendId: String) {
        let calendar = Calendar.current
        let currentDate = Date().koreanDate
        let startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        
        socialService.getFriendDailyStats(
            friendId: friendId,
            range: "\(startDate.apiFormat),\(currentDate.apiFormat)"
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                self.appState.currentToast = .error(error.localizedDescription)
            }
        } receiveValue: { [weak self] stats in
            self?.friendDailyStats = stats
        }
        .store(in: &cancellables)
    }
    
    func fetchPendingRequests() {
        socialService.getPendingRequests()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] requests in
                self?.pendingRequests = requests
            }
            .store(in: &cancellables)
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        socialService.acceptFriendRequest(requestId: request.id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    self.appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                self?.pendingRequests.removeAll { $0.id == request.id }
                self?.fetchFriends()
                self?.appState.currentToast = .friendRequestAccepted(request.fromUser.username)
            }
            .store(in: &cancellables)
    }
    
    func fetchFriends() {
        isLoading = true
        
        socialService.getFriends()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] fetchedFriends in
                self?.friends = fetchedFriends
                
                // 만약 선택된 친구가 없고, 친구 목록이 있다면 첫 번째 친구를 선택
                if self?.selectedFriend == nil, let firstFriend = fetchedFriends.first {
                    self?.selectFriend(firstFriend)
                }
                // 선택된 친구가 있지만 더 이상 친구 목록에 없는 경우 선택 해제
                else if let selected = self?.selectedFriend,
                        !fetchedFriends.contains(where: { $0.id == selected.id }) {
                    self?.selectedFriend = nil
                }
            }
            .store(in: &cancellables)
    }
    
    func selectUser(_ _selectedUser: SearchResult) {
        if _selectedUser.isPending{
            appState.currentToast = .friendAlreadyRequested(_selectedUser.username)
        } else {
            if _selectedUser.isFriend {
                // TODO: 친구 캘린더로 바로 이동
            } else {
                requestFriend(searchedUser: _selectedUser)
            }
        }
    }
    
    func requestFriend(searchedUser:SearchResult) {
        socialService.requestFriend(userId:searchedUser.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] requestedFriendId in
                guard let self = self else { return }
                isLoading = false
                if let index = searchResults.firstIndex(where: {requestedFriendId == $0.id}){
                    searchResults[index].isPending = true
                }
                appState.currentToast = .friendRequested(searchedUser.username)
            }
            .store(in: &cancellables)
    }
    
    func selectDateForInsightData(date: Date) {
        guard let index = friendDailyStats.firstIndex(where: { date.apiFormat == $0.date}) else {return}
        dailyStatForDate = friendDailyStats[index]
        fetchTodosForDate(date.apiFormat)
    }
    
    //MARK: 특정 날짜에 대한 Todo들 fetch
    func fetchTodosForDate(_ deadline: String) {
        todoService.fetchTodosForDate(deadline: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] todos in
                self?.isLoading = false
                guard let self = self else { return }
                self.todosForDate = todos
                isDetailViewPresented = true
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ query: String) {
        socialService.searchUser(searchQuery: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.appState.currentToast = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }
}

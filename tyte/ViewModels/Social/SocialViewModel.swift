import Foundation
import Combine
import Alamofire

class SocialViewModel: ObservableObject {
    private let appState: AppState
    
    // MARK: 소셜(메인)뷰에 필요
    @Published var friends: [User] = []
    @Published var selectedFriend: User?
    @Published var currentMonth: Date = Date().koreanDate
    @Published var friendDailyStats: [DailyStat] = []
    
    // MARK: 캘린더 아이템 클릭 시 세부 정보창 조회 위해 필요
    @Published var isDetailViewPresented: Bool = false
    @Published var dailyStatForDate: DailyStat = .initial
    @Published var todosForDate: [Todo] = []
    
    // MARK: Request List에 필요
    @Published var pendingRequests: [FriendRequest] = []
     
    // MARK: 친구 탐색창에 필요
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var selectedUser: SearchResult?
    @Published var isLoading = false
    
    private let todoService: TodoServiceProtocol
    private let dailyStatService: DailyStatServiceProtocol
    private let socialService: SocialServiceProtocol
    
    init(
        dailyStatService: DailyStatServiceProtocol = DailyStatService(),
        todoService: TodoServiceProtocol = TodoService(),
        socialService:SocialServiceProtocol = SocialService(),
        appState: AppState = .shared
    ) {
        self.dailyStatService = dailyStatService
        self.todoService = todoService
        self.socialService = socialService
        self.appState = appState
        
        fetchInitialData()
        
        $searchText
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                if query.isEmpty {
                    searchResults = []
                } else {
                    performSearch(query)
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    func fetchInitialData(){
        fetchPendingRequests()
        fetchFriends()
    }
    
    func selectDate(date: Date) {
        guard let index = friendDailyStats.firstIndex(where: { date.apiFormat == $0.date}) else {return}
        dailyStatForDate = friendDailyStats[index]
        fetchFriendTodosForDate(date.apiFormat)
    }
    
    func selectFriend(_ friend: User) {
        selectedFriend = friend
        fetchFriendDailyStats(friendId: friend.id)
    }
    
    //MARK: 친구의 특정 날짜에 대한 Todo들 fetch
    func fetchFriendTodosForDate(_ deadline: String) {
        guard let friend = selectedFriend else { return }
        todoService.fetchTodos(for: friend.id ,in: deadline)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                isLoading = false
                todosForDate = todos
                isDetailViewPresented = true
            }
            .store(in: &cancellables)
    }
    
    func fetchFriendDailyStats(friendId: String) {
        print("fetchFriendDailyStats")
        let calendar = Calendar.current
        let currentDate = Date().koreanDate
        let startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        
        dailyStatService.fetchMonthlyStats(
            for: friendId,
            in: "\(startDate.apiFormat),\(currentDate.apiFormat)"
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else {return}
            if case .failure(let error) = completion {
                appState.showToast(.error(error.localizedDescription))
            }
        } receiveValue: { [weak self] stats in
            self?.friendDailyStats = stats
        }
        .store(in: &cancellables)
    }
    
    func fetchPendingRequests() {
        socialService.getPendingRequests()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] requests in
                self?.pendingRequests = requests
            }
            .store(in: &cancellables)
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        socialService.acceptFriendRequest(requestId: request.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else {return}
                appState.showToast(.friendRequestAccepted(request.fromUser.username))
                pendingRequests.removeAll { $0.id == request.id }
                fetchFriends()
            }
            .store(in: &cancellables)
    }
    
    private func fetchFriends() {
        isLoading = true
        socialService.getFriends()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] fetchedFriends in
                self?.friends = fetchedFriends
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
            appState.showToast(.friendAlreadyRequested(_selectedUser.username))
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
                guard let self = self else {return}
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] res in
                guard let self = self else { return }
                isLoading = false
                if let index = searchResults.firstIndex(where: {res.id == $0.id}){
                    searchResults[index].isPending = true
                }
                appState.showToast(.friendRequested(searchedUser.username))
            }
            .store(in: &cancellables)
    }
    
    private func performSearch(_ query: String) {
        socialService.searchUsers(query: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] results in
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }
}

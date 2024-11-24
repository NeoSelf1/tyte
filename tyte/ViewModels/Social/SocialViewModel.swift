import Foundation
import Combine
import Alamofire
import SwiftUI // NavigationPath

class SocialViewModel: ObservableObject {
    private let appState: AppState
    
    @Published var navigationPath = NavigationPath()
    // MARK: 소셜(메인)뷰에 필요
    @Published var friends: [User] = []
    @Published var selectedFriend: User?
    @Published var friendDailyStats: [DailyStat] = []
    @Published var currentDate: Date = Date().koreanDate { didSet {
        getCalendarData(in:String( currentDate.apiFormat.prefix(7)))
    } }
    
    // MARK: 캘린더 아이템 클릭 시 세부 정보창 조회 위해 필요
    @Published var dailyStatForDate: DailyStat = .empty
    @Published var todosForDate: [Todo] = []
    
    // MARK: Request List에 필요
    @Published var pendingRequests: [FriendRequest] = []
     
    // MARK: 친구 탐색창에 필요
    @Published var searchText = ""
    @Published var searchResults: [SearchResult] = []
    @Published var selectedUser: SearchResult?
    
    @Published var isLoading = false
    @Published var isDetailViewPresent: Bool = false
    
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
        
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    // 친구 요청 조회 및 친구 조회
    func initialize(){
        fetchFriends()
        fetchPendingRequests()
        
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
    
    // 친구검색창 내부 유저 버튼 클릭처리
    func handleUserButtonClick(_ _selectedUser: SearchResult) {
        if _selectedUser.isPending{
            appState.showToast(.friendAlreadyRequested(_selectedUser.username))
        } else {
            if _selectedUser.isFriend {
                selectFriend(User(
                    id: _selectedUser.id,
                    username: _selectedUser.username,
                    email: _selectedUser.email
                ))
                navigationPath.removeLast()
            } else {
                requestFriend(searchedUser: _selectedUser)
            }
        }
    }
    
    func selectFriend(_ friend: User) {
        selectedFriend = friend
        currentDate = Date().koreanDate
    }
    
    // 친구 캘린더 아이템 클릭 시 호출
    func selectCalendarDate(_ date: Date) {
        guard let index = friendDailyStats.firstIndex(where: { date.apiFormat == $0.date}),
                let friend = selectedFriend else {return}
        isLoading = true
        dailyStatForDate = friendDailyStats[index]
        
        todoService.fetchTodos(for: friend.id ,in: date.apiFormat)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] todos in
                guard let self = self else { return }
                todosForDate = todos
                isDetailViewPresent = true
            }
            .store(in: &cancellables)
    }
    
    func fetchPendingRequests() {
        isLoading = true
        socialService.getPendingRequests()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.isLoading=false
                }
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] requests in
                self?.pendingRequests = requests
            }
            .store(in: &cancellables)
    }
    
    func acceptFriendRequest(_ request: FriendRequest) {
        isLoading = true
        socialService.acceptFriendRequest(requestId: request.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
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
    
    // MARK: - Private Method
    private func getCalendarData(in yearMonth: String){
        guard let friendId = selectedFriend?.id else { return }
        isLoading = true
        dailyStatService.fetchMonthlyStats(for: friendId, in: yearMonth)
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            guard let self = self else {return}
            isLoading = false
            if case .failure(let error) = completion {
                appState.showToast(.error(error.localizedDescription))
            }
        } receiveValue: { [weak self] stats in
            self?.friendDailyStats = stats
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
    
    private func requestFriend(searchedUser:SearchResult) {
        isLoading = true
        socialService.requestFriend(userId:searchedUser.id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
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
        isLoading = true
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

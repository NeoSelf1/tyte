import Foundation
import Combine
import Alamofire
import SwiftUI

class FriendViewModel: ObservableObject {
    let appState = AppState.shared
    @Published var searchResults: [SearchResult] = []
    @Published var friends: [User] = []
    @Published var isLoading = false
    
    private let friendService: FriendService = FriendService.shared
    @Published var searchText = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
    
    private func performSearch(_ query: String) {
        friendService.searchUser(searchQuery: query)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.appState.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] results in
                print("easdf")
                self?.searchResults = results
            }
            .store(in: &cancellables)
    }
}

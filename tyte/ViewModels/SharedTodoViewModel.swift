//
//  SharedTodoViewModel.swift
//  tyte
//
//  Created by 김 형석 on 9/17/24.
//

import Foundation
import Combine

class SharedTodoViewModel: ObservableObject {
    private let todoService: TodoService
    
    @Published var allTodos: [Todo] = []
    @Published var lastAddedTodoId: String?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    init(todoService: TodoService = TodoService()) {
        self.todoService = todoService
        fetchTodos()
    }

    func fetchTodos(mode: String = "default") {
        print("fetching Todos in SharedTodoViewModel")
        isLoading = true
        errorMessage = nil
        todoService.fetchAllTodos(mode: mode)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] todos in
                self?.allTodos = todos
            }
            .store(in: &cancellables)
    }
    //MARK: Todo 추가
    func addTodo(_ text: String) {
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newTodos in
                print("addedTodo in SHaredViewModel \(text)")
                guard let self = self else { return }
                self.lastAddedTodoId = newTodos.last?.id
            }
            .store(in: &cancellables)
    }
}

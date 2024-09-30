//
//  SharedTodoViewModel.swift
//  tyte
//
//  Created by 김 형석 on 9/17/24.
//

import Foundation
import Combine

class SharedTodoViewModel: ObservableObject {
    @Published var inProgressTodos: [Todo] = []
    @Published var completedTodos: [Todo] = []
    @Published var todosForDate: [Todo] = []
    @Published var tags: [Tag] = []
    
    @Published var lastAddedTodoId: String?
    @Published var lastUpdatedTagId: String?
    @Published var currentPopup: PopupType?
    
    private let todoService: TodoService
    private let tagService: TagService
    
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init(
        todoService: TodoService = TodoService(),
        tagService: TagService = TagService()
    ) {
        self.todoService = todoService
        self.tagService = tagService
        fetchTags()
    }
    
    //MARK: - 로컬변수 갱신 로직
    // MARK: 로컬 변수값만 교체 / 별도 fetch동작 없음.
    func updateTodoGlobal(_ updatedTodo: Todo) {
        // TodosInListView 갱신
        if let index = todosForDate.firstIndex(where: { $0.id == updatedTodo.id }) {
            todosForDate[index] = updatedTodo
        }
        // 변경된 Todo를 TodosInHome으로 할당
        if updatedTodo.isCompleted {
            inProgressTodos.removeAll { $0.id == updatedTodo.id }
            if !completedTodos.contains(where: { $0.id == updatedTodo.id }) {
                completedTodos.append(updatedTodo)
            }
        } else {
            completedTodos.removeAll { $0.id == updatedTodo.id }
            if !inProgressTodos.contains(where: { $0.id == updatedTodo.id }) {
                inProgressTodos.append(updatedTodo)
            }
        }
    }
    
    //MARK: Todo 추가
    func addTodo(_ text: String) {
        isLoading = true
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                isLoading = false
                if case .failure(let error) = completion {
                    switch error {
                    case .invalidTodo:
                        self.currentPopup = .invalidTodo
                    default:
                        self.currentPopup = .error(error.localizedDescription)
                    }
                }
            } receiveValue: { [weak self] newTodos in
                self?.isLoading = false
                guard let self = self else { return }
                if newTodos.count == 1 {
                    currentPopup = .todoAddedIn(newTodos[0].deadline)
                } else {
                    currentPopup = .todosAdded(newTodos.count)
                }
                // ListView에 있는 dailyStat 갱신과 fetchTodosForDate 호출 위해 필요. 통신용 => fetchTodosForDate가 여기에 있을 필요가?
                // fetchTodoForDate도 여기서 호출하고 dailyStat 갱신만 거기서 하기로
                // selectedDate에 대한 fetchTodosForDate가 필요하기 때문에 여기서 호출하기 부적절. 기각.
                // HomeView, ListView 갱신용
                
                self.lastAddedTodoId = newTodos.last?.id
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Tag 관련 메서드
    func fetchTags() {
        isLoading = true
        tagService.fetchAllTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
                print("tag fetched in Shared")
            }
            .store(in: &cancellables)
    }
    
    //MARK: Tag 추가
    func addTag(name: String, color: String) {
        tagService.createTag(name: name,color:color)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] newTagId in
                guard let self = self else { return }
                currentPopup = .tagAdded
                updateTagsGlobal(newTagId)
            }
            .store(in: &cancellables)
    }
    
    //MARK: Tag 삭제
    func deleteTag(id: String) {
        tagService.deleteTag(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] deletedTagId in
                guard let self = self else { return }
                currentPopup = .tagDeleted
                updateTagsGlobal(deletedTagId)
            }
            .store(in: &cancellables)
    }
    
    //MARK: Tag 수정
    func editTag(_ tag: Tag) {
        tagService.updateTag(tag: tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.currentPopup = .error(error.localizedDescription)
                }
            } receiveValue: { [weak self] updatedTagId in
                guard let self = self else { return }
                currentPopup = .tagEdited
                updateTagsGlobal(updatedTagId)
            }
            .store(in: &cancellables)
    }
    
    func updateTagsGlobal(_ updatedTagId: String) {
        fetchTags() // HomeView 갱신
        lastUpdatedTagId = updatedTagId // ListView 전달
    }
}

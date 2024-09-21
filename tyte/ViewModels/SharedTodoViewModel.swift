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
    private let tagService: TagService
    
    @Published var tags: [Tag] = []
    @Published var lastAddedTodoId: String?
    @Published var lastUpdatedTagId: String?
    @Published var todoAlertMessage: String?
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    
    init(
        todoService: TodoService = TodoService(),
        tagService: TagService = TagService()
    ) {
        self.todoService = todoService
        self.tagService = tagService
    }
    
    func fetchTags() {
        isLoading = true
        errorMessage = nil
        tagService.fetchAllTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }

    
    //MARK: Todo 추가
    func addTodo(_ text: String) {
        isLoading = true
        
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    self.todoAlertMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newTodos in
                guard let self = self else { return }
                if newTodos.count == 1 {
                    self.todoAlertMessage = "\(newTodos[0].deadline.parsedDate.formattedMonthDate)에 투두가 추가되었습니다."
                } else {
                    self.todoAlertMessage = "총 \(newTodos.count)개의 투두가 추가되었습니다."
                }
                
                self.lastAddedTodoId = newTodos.last?.id
            }
            .store(in: &cancellables)
    }
    
    //MARK: Tag 추가
    func addTag(name: String, color: String) {
        tagService.createTag(name: name,color:color)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newTagId in
                self?.fetchTags()
                self?.lastAddedTodoId = newTagId
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 삭제
    func deleteTag(id: String) {
        tagService.deleteTag(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] deletedTagId in
                self?.fetchTags()
                self?.lastAddedTodoId = deletedTagId
            }
            .store(in: &cancellables)
    }
    
    //MARK: Todo 수정
    func editTodo(_ tag: Tag) {
        tagService.updateTag(tag: tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTagId in
                self?.fetchTags()
                self?.lastAddedTodoId = updatedTagId
            }
            .store(in: &cancellables)
    }
}

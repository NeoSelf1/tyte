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
    @Published var alertMessage: String?
    
    private let todoService: TodoService
    private let tagService: TagService
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
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
    
    // MARK: listView에서 Todo를 조작 후 fetchTodosForDate 호출하면, homeView에 보이는 allTodos를 갱신
    // 불필요할듯. listview에서 fetch하는 경우는, 날짜 변경이기 때문에 전체 투두 내용 자체의 변화는 없음.
//    func updateTodosInHome(with newTodos: [Todo]) {
//        let dateString = newTodos.first?.deadline ?? ""
//        inProgressTodos.removeAll { $0.deadline == dateString }
//        completedTodos.removeAll { $0.deadline == dateString }
//        
//        for todo in newTodos {
//            if todo.isCompleted {
//                completedTodos.append(todo)
//            } else {
//                inProgressTodos.append(todo)
//            }
//        }
//    }
    
    //MARK: Todo 추가
    func addTodo(_ text: String) {
        isLoading = true
        todoService.createTodo(text: text)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    guard let self = self else { return }
                    alertMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newTodos in
                guard let self = self else { return }
                self.isLoading = false
                if newTodos.count == 1 {
                    alertMessage = "\(newTodos[0].deadline.parsedDate.formattedMonthDate)에 투두가 추가되었습니다."
                } else {
                    alertMessage = "총 \(newTodos.count)개의 투두가 추가되었습니다."
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
    
    // Fetch Tag
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
                    print(error.localizedDescription)
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] newTagId in
                self?.updateTagsGlobal(newTagId)
            }
            .store(in: &cancellables)
    }
    
    //MARK: tag 삭제
    func deleteTag(id: String) {
        tagService.deleteTag(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] deletedTagId in
                self?.updateTagsGlobal(deletedTagId)
            }
            .store(in: &cancellables)
    }
    
    //MARK: tag 수정
    func editTag(_ tag: Tag) {
        tagService.updateTag(tag: tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] updatedTagId in
                self?.updateTagsGlobal(updatedTagId)
            }
            .store(in: &cancellables)
    }
    
    func updateTagsGlobal(_ updatedTagId: String) {
        fetchTags() // HomeView 갱신
        lastUpdatedTagId = updatedTagId // ListView 전달
    }
}

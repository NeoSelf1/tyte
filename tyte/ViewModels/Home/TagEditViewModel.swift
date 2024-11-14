//
//  Untitled.swift
//  tyte
//
//  Created by Neoself on 10/21/24.
//

import Foundation
import Combine
import Alamofire
import SwiftUI

class TagEditViewModel: ObservableObject {
    private let appState: AppState
    
    @Published var tags: [Tag] = []
    @Published var isLoading: Bool = false
    @Published var tagInput = ""
    @Published var selectedColor: String = "FF0000"
    @Published var selectedTag: Tag?
    
    @Published var isDeleteConfirmationPresent = false
    @Published var isDuplicateWarningPresent = false
    
    @Published var isColorPickerPresented = false
    @Published var isEditBottomPresented = false
    
    private let tagService: TagServiceProtocol
    
    init(
        tagService: TagServiceProtocol = TagService(),
        appState: AppState = .shared
    ) {
        self.tagService = tagService
        self.appState = appState
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Method
    func fetchTags() {
        isLoading = true
        tagService.fetchTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }
    
    //MARK: Tag 추가
    func addTag() {
        if !tagInput.isEmpty {
            if tags.contains(where: { $0.name.lowercased() == tagInput.lowercased() }) {
                isDuplicateWarningPresent = true
            } else {
                tagService.createTag(name: tagInput,color:selectedColor)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        guard let self = self else {return}
                        if case .failure(let error) = completion {
                            appState.showToast(.error(error.localizedDescription))
                        }
                    } receiveValue: { [weak self] newTagId in
                        guard let self = self else { return }
                        appState.showToast(.tagAdded)
                        fetchTags()
                    }
                    .store(in: &cancellables)
                tagInput = ""
            }
        }
    }
    
    //MARK: Tag 삭제
    func deleteTag(id: String) {
        tagService.deleteTag(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] deletedTagId in
                guard let self = self else { return }
                appState.showToast(.tagDeleted)
                fetchTags()
            }
            .store(in: &cancellables)
    }
    
    //MARK: Tag 수정
    func editTag(_ tag: Tag) {
        tagService.updateTag(tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] updatedTagId in
                guard let self = self else { return }
                appState.showToast(.tagEdited)
                fetchTags()
            }
            .store(in: &cancellables)
    }
}

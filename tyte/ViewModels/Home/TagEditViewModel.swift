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
    
    @Published var selectedColor: String = "FF0000"
    @Published var tags: [Tag] = []
    @Published var selectedTag: Tag?
    @Published var tagInput = ""
    
    @Published var isDuplicateWarningPresent = false
    @Published var isEditBottomPresent = false
    
    @Published var isColorPickerPresent = false
    @Published var isLoading = false
    
    private let tagService: TagServiceProtocol
    
    init(
        tagService: TagServiceProtocol = TagService(),
        appState: AppState = .shared
    ) {
        self.tagService = tagService
        self.appState = appState
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Methodx[tx
    func initialize(){
        getTags()
    }
    
    func handleRefresh(){
        getTags()
    }
    
    func selectTag(_ tag :Tag){
        selectedTag = tag
        isEditBottomPresent = true
    }
    
    // Tag 추가
    func addTag() {
        isLoading = true
        if !tagInput.isEmpty {
            if tags.contains(where: { $0.name.lowercased() == tagInput.lowercased() }) {
                isDuplicateWarningPresent = true
            } else {
                tagService.createTag(name: tagInput,color:selectedColor)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        guard let self = self else {return}
                        isLoading = false
                        if case .failure(let error) = completion {
                            appState.showToast(.error(error.localizedDescription))
                        }
                    } receiveValue: { [weak self] newTagId in
                        guard let self = self else { return }
                        appState.showToast(.tagAdded)
                        tagInput = ""
                        handleRefresh()
                    }
                    .store(in: &cancellables)
            }
        }
    }
    
    // Tag 삭제
    func deleteTag(id: String) {
        isLoading = true
        tagService.deleteTag(id: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] deletedTagId in
                guard let self = self else { return }
                appState.showToast(.tagDeleted)
                tags = tags.filter{$0.id != deletedTagId.id}
            }
            .store(in: &cancellables)
    }
    
    // Tag 수정
    func editTag(_ tag: Tag) {
        isLoading = true
        tagService.updateTag(tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] updatedTagId in
                guard let self = self else { return }
                appState.showToast(.tagEdited)
                handleRefresh()
            }
            .store(in: &cancellables)
    }
    
    // Tag 서버에서 호출
    private func getTags() {
        isLoading = true
        tagService.fetchTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else {return}
                print("getTags done in TagEditView")
                isLoading = false
                if case .failure(let error) = completion {
                    appState.showToast(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }
}

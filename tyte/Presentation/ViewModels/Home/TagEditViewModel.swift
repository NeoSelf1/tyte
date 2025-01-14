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
    @Published var selectedColor: String = "FF0000"
    @Published var tags: [Tag] = []
    @Published var selectedTag: Tag?
    @Published var tagInput = ""
    
    @Published var isDuplicateWarningPresent = false
    @Published var isEditBottomPresent = false
    @Published var isColorPickerPresent = false
    @Published var isLoading = false
    
    private let syncService = CoreDataSyncService.shared
    
    init() {
        initialize()
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Methods
    func initialize(){
        refreshTags()
    }
    
    func handleRefresh(){
        refreshTags()
    }
    
    func selectTag(_ tag :Tag){
        selectedTag = tag
        isEditBottomPresent = true
    }
    
    /// Tag 추가
    func addTag() {
        guard !tagInput.isEmpty else { return }
        guard !tags.contains(where: { $0.name.lowercased() == tagInput.lowercased()}) else {
            isDuplicateWarningPresent = true
            return
        }
        
        isLoading = true
        syncService.createTag(name: tagInput,color:selectedColor)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion, case .networkError = error as? APIError {
                    ToastManager.shared.show(.error(error.localizedDescription))
                }
            } receiveValue: { [weak self] newTag in
                guard let self = self else { return }
                ToastManager.shared.show(.tagAdded)
                tagInput = ""
                selectedColor = "FF0000"
                refreshTags()
            }
            .store(in: &cancellables)
    }

    
    /// Tag 삭제
    func deleteTag(id: String) {
        isLoading = true
        
        syncService.deleteTag(id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
            } receiveValue: { [weak self] deletedTagId in
                guard let self = self else { return }
                ToastManager.shared.show(.tagDeleted)
                tags = tags.filter{$0.id != deletedTagId}
            }
            .store(in: &cancellables)
    }
    
    /// Tag 수정
    func editTag(_ tag: Tag) {
        isLoading = true
        
        syncService.updateTag(tag)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
            } receiveValue: { [weak self] updatedTag in
                guard let self = self else { return }
                ToastManager.shared.show(.tagEdited)
                refreshTags()
            }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Private Method
    
    private func refreshTags() {
        isLoading = true
        syncService.refreshTags()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.isLoading = false
            } receiveValue: { [weak self] tags in
                self?.tags = tags
            }
            .store(in: &cancellables)
    }
}

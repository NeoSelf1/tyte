import Foundation
import SwiftUI

/// 태그 관리 화면의 상태와 로직을 관리하는 ViewModel
///
/// 태그의 CRUD 작업과 관련 상태를 관리합니다.
///
/// ## 주요 기능
/// - 태그 CRUD 작업 처리
/// - 태그 색상 선택 처리
/// - 태그 중복 검사
///
/// ## 상태 프로퍼티
/// ```swift
/// @Published var tags: [Tag]              // 태그 목록
/// @Published var selectedColor: String    // 선택된 색상
/// @Published var tagInput: String         // 태그명 입력
/// ```
@MainActor
class TagEditViewModel: ObservableObject {
    
    // MARK: - UI State
    
    @Published var selectedColor: String = "FF0000"
    @Published var tags: [Tag] = []
    @Published var selectedTag: Tag?
    @Published var tagInput = ""
    
    @Published var isLoading = false
    @Published var isDuplicateWarningPresent = false
    @Published var isEditBottomPresent = false
    @Published var isColorPickerPresent = false
    
    // MARK: - UseCases
    
    private let tagUseCase: TagUseCaseProtocol
    
    init(tagUseCase: TagUseCaseProtocol = TagUseCase()) {
        self.tagUseCase = tagUseCase
        
        initialize()
    }
    
    // MARK: - Methods
    
    func initialize(){
        Task {
            await fetchTags()
        }
    }
    
    func handleRefresh(){
        Task {
            await fetchTags()
        }
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
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let newTag = try await tagUseCase.createTag(name: tagInput, color: selectedColor)
                tags.insert(newTag, at: 0)
                
                tagInput = ""
                selectedColor = "FF0000"
                
                ToastManager.shared.show(.tagAdded)
            } catch {
                print("Add Tag error: \(error)")
            }
        }
    }
    
    /// Tag 수정
    func editTag(_ tag: Tag) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await tagUseCase.updateTag(tag)
                
                /// 변경된 Todo가 선택된 날짜에 있을 경우, 상태변수를 직접 조작해 당장 보이는 UI를 업데이트합니다.
                /// - Note: 선택된 날짜 외의 날짜로 Todo 위치가 변경되었을 경우, 날짜 변경 시점에 Todo들을 로컬 및 리모트로부터 새로 불러오기 때문에 추가 구현이 불요합니다.
                if let index = tags.firstIndex(where: {$0.id == tag.id}) {
                    tags[index] = tag
                }
                
                ToastManager.shared.show(.tagEdited)
            } catch {
                print("Edit Todo error: \(error)")
            }
        }
    }
    
    /// Tag 삭제
    func deleteTag(id: String) {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                try await tagUseCase.deleteTag(id)
                
                tags = tags.filter{$0.id != id}
                
                ToastManager.shared.show(.tagDeleted)
            } catch {
                print("Delete Todo error: \(error)")
            }
        }
    }
    
    // MARK: - Private Method
    
    private func fetchTags() async {
        do {
            tags = try await tagUseCase.getAllTags()
        } catch {
            print("error refreshing: \(error)")
        }
    }
}

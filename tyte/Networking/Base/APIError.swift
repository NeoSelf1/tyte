import Foundation
import Alamofire

extension APIError {
    var requiresLogout: Bool {
        switch self {
        case .unauthorized:
            return true
        default:
            return false
        }
    }
    
    var isNetworkError: Bool {
        switch self {
        case .networkError, .serverError:
            return true
        default:
            return false
        }
    }
}

enum APIError: Error {
    case invalidURL
    case invalidTodo
    case decodingError
    case networkError(String)
    case serverError(String)
    case unauthorized
    
    case notFound
    case unknown
    case social
    
    case emailAlreadyExists
    case wrongPassword
    case invalidEmail
    
    case invalidUsername
    case invalidPassword
    case userNotFound
    
    init(afError: AFError) {
        switch afError {
        case .invalidURL(let url):
            self = .invalidURL
            print("Invalid URL: \(url)")
        case .responseSerializationFailed(reason: .decodingFailed(_)):
            self = .decodingError
        case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
            switch code {
            case 401:
                self = .unauthorized
            case 402:
                self = .invalidTodo
            case 404:
                self = .notFound
                //MARK: - Onboarding Error
            case 409:
                self = .emailAlreadyExists
            case 411:
                self = .wrongPassword
            case 422:
                self = .invalidEmail
            case 423:
                self = .invalidUsername
            case 424:
                self = .invalidPassword
            case 425:
                self = .userNotFound
            case 500...599:
                self = .serverError("Server error: \(code)")
            default:
                self = .networkError("Network error: \(code)")
            }
        default:
            self = .unknown
        }
    }
    
    var localizedDescription: String {
         switch self {
         case .invalidURL:
             return "죄송해요. 주소에 문제가 있어요. 잠시 후 다시 시도해 주세요."
         case .decodingError:
             return "서버에서 온 정보를 해석하는 데 문제가 있어요. 나중에 다시 시도해 주세요."
         case .networkError(let message):
             return "네트워크 연결에 문제가 있어요: \(message). 와이파이나 데이터 연결을 확인해 주세요."
         case .serverError(let message):
             return "서버에 문제가 생겼어요: \(message). 잠시 후에 다시 시도해 주세요."
         case .unauthorized:
             return "보안을 위해 다시 로그인해 주세요. 불편을 드려 죄송합니다."
         case .notFound:
             return "찾으시는 정보가 없어요. 주소를 다시 한 번 확인해 주시겠어요?"
         case .unknown:
             return "알 수 없는 문제가 발생했어요. 앱을 다시 실행해 보시겠어요?"
         case .emailAlreadyExists:
             return "이미 사용 중인 이메일이에요. 다른 이메일로 시도해 보시는 건 어떨까요?"
         case .userNotFound:
             return "등록된 사용자를 찾을 수 없어요. 회원가입을 하셨나요?"
         default:
             return ""
         }
     }
}

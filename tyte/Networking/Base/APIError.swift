import Foundation
import Alamofire

enum APIError: Error, Equatable {
    case invalidURL
    case decodingError
    
    case unauthorized
    case invalidTodo
    case serverDataInvalid
    case notFound
    case alreadyRequested

    case wrongPassword
    
    case guestMode
    case networkError
    case serverError(String)
    case unknown
    
    init(afError: AFError) {
        switch afError {
        case .invalidURL(let url):
            self = .invalidURL
            print("Invalid URL: \(url)")
            
        case .responseSerializationFailed(reason: .decodingFailed(_)):
            self = .decodingError
            
        case .sessionTaskFailed:
                self = .networkError
            
        case .responseValidationFailed(reason: .unacceptableStatusCode(let code)):
            switch code {
            case 401:
                self = .unauthorized
            case 402:
                self = .invalidTodo
            case 403:
                self = .serverDataInvalid
            case 404:
                self = .notFound
            case 405:
                self = .alreadyRequested
            case 406:
                self = .wrongPassword
            case 500...599:
                self = .serverError("Server error: \(code)")
            default:
                self = .networkError
            }
            
        default:
            self = .unknown
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            "죄송해요. 주소에 문제가 있어요. 잠시 후 다시 시도해 주세요."
        case .decodingError:
            "서버에서 온 정보를 해석하는 데 문제가 있어요. 나중에 다시 시도해 주세요."
        case .unauthorized:
            "보안을 위해 다시 로그인해 주세요. 불편을 드려 죄송합니다."
        case .invalidTodo:
            "앗! AI가 할 일 내용을 이해하지 못했어요. 다시 한 번 작성해 주시겠어요?"
        case .networkError:
            "네트워크 연결에 문제가 있어요. 와이파이나 데이터 연결을 확인해 주세요."
        case .serverError(let message):
            "서버에 문제가 생겼어요: \(message). 잠시 후에 다시 시도해 주세요."
        case .unknown:
            "알 수 없는 문제가 발생했어요. 앱을 다시 실행해 보시겠어요?"
        default:
            ""
        }
    }
}

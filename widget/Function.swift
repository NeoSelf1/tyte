//
//  Function.swift
//  tyte
//
//  Created by Neoself on 10/16/24.
//
import Alamofire

func fetchTodosForDate(deadline: String, completion: @escaping (Result<[SimplifiedTodo], Error>) -> Void) {
//    let baseURL = "http://43.201.140.227:8080/api"
    let baseURL = "http://localhost:8080/api"
    let endpoint = "/todo/\(deadline)/widget"
    let url = baseURL + endpoint
    let headers: HTTPHeaders = [
        "Authorization": "Bearer \(String(describing: getToken()))",
        "Content-Type": "application/json"
    ]
    
    AF.request(url,
               method: .get,
               encoding: URLEncoding.queryString,
               headers: headers)
        .validate()
        .responseDecodable(of: [SimplifiedTodo].self) { response in
            switch response.result {
            case .success(let todos):
                completion(.success(todos))
            case .failure(let error):
                print("Error fetching todos: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
}

// Helper function to get the token
private func getToken() -> String? {
    guard let email = UserDefaults.standard.string(forKey: "lastLoggedInEmail") else {
        return nil
    }
    
    do {
        return try retrieve(service: "com.tyte.authtoken",
                                            account: email)
    } catch {
        print("Failed to retrieve token: \(error.localizedDescription)")
        return nil
    }
}

private func retrieve(service: String, account: String) throws -> String {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrService as String: service,
        kSecAttrAccount as String: account,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnData as String: true
    ]

    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)

    guard status != errSecItemNotFound else {
        throw KeychainError.notFound
    }
    guard status == errSecSuccess else {
        throw KeychainError.unknown(status)
    }

    guard let data = result as? Data, let token = String(data: data, encoding: .utf8) else {
        throw KeychainError.unknown(status)
    }

    return token
}

enum KeychainError: Error {
    case unknown(OSStatus)
    case notFound
    case encodingError
}

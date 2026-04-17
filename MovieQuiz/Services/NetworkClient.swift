import Foundation

struct NetworkClient {
    
    private enum NetworkError: Error {
        case codeError
        case emptyData
    }
    
    private enum Constants {
        static let successCodeRange = 200..<300
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error {
                handler(.failure(error))
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !Constants.successCodeRange.contains(response.statusCode) {
                handler(.failure(NetworkError.codeError))
                return
            }
            
            guard let data else {
                handler(.failure(NetworkError.emptyData))
                return
            }
            
            handler(.success(data))
        }
        
        task.resume()
    }
}


import Foundation

protocol NetworkProtocol {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}

struct NetworkClient: NetworkProtocol {
    
    private enum NetworkError: Error {
        case invalidStatusCode
        case emptyData
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error {
                DispatchQueue.main.async {  handler(.failure(error)) }
                return
            }
            
            if let response = response as? HTTPURLResponse,
               !(200..<300).contains(response.statusCode) {
                DispatchQueue.main.async { handler(.failure(NetworkError.invalidStatusCode)) }
                return
            }
            
            guard let data else {
                DispatchQueue.main.async { handler(.failure(NetworkError.emptyData)) }
                return
            }
            
            DispatchQueue.main.async { handler(.success(data)) }
        }
        
        task.resume()
    }
}


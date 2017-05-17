import Foundation

enum Result<T> {
    case success(T)
    case failure(NetworkError)
}

enum NetworkError: Error {
    case unspecified
}

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask
}

struct NetworkClient {
    let session: URLSessionProtocol

    init(with session: URLSessionProtocol) {
        self.session = session
    }
    
    func get(resourceAt url: URL, completion: @escaping (Result<Data>) -> ()) {
        let dataTask = session.dataTask(with: url) { (data: Data?, urlResponse: URLResponse?, error: Error?) in
    
            guard error == nil else {
                completion(Result<Data>.failure(NetworkError.unspecified))
                return
            }
            
            completion(Result<Data>.success(data ?? Data()))
        }
        
        dataTask.resume()
    }
}

import Quick
import Nimble
@testable import Client

class ClientSpec: QuickSpec {
    override func spec() {
        describe("making a network request") {
            context("on success") {
                describe("the completion handler") {
                    it("invokes the completion handler with data") {
                        let session = URLSessionSpy()
                        let sessionTask = URLSessionDataTaskSpy()
                        session.dataTaskToReturn = sessionTask
                        session.completionHandlerArguments = (data: Data(), response: nil, error: nil)
                        
                        let client = NetworkClient(with: session)
                        var requestResult: Result<Data>?

                        client.get(resourceAt: URL(string: "http://www.example.com")!) { result in
                            requestResult = result
                        }
                        
                        guard let result = requestResult,
                            case let Result.success(data) = result,
                            data == Data() else {
                                fail("expected to get data, got \(String(describing: requestResult)) instead")
                                return 
                        }
                    }
                    
                    context("on failure") {
                        describe("the completion handler") {
                            it("invokes the completion handler with an error") {
                                let session = URLSessionSpy()
                                let sessionTask = URLSessionDataTaskSpy()
                                session.dataTaskToReturn = sessionTask
                                session.completionHandlerArguments = (data: nil, response: nil, error: NetworkError.unspecified)
                                
                                let client = NetworkClient(with: session)
                                var requestResult: Result<Data>?
                                
                                client.get(resourceAt: URL(string: "http://www.example.com")!) { result in
                                    requestResult = result
                                }
                                
                                guard let result = requestResult,
                                    case let Result.failure(error) = result,
                                    error == NetworkError.unspecified else {
                                        fail("expected to get data, got \(String(describing: requestResult)) instead")
                                        return
                                }
                            }
                        }
                    }
                }
                
                it("makes a network request with the URL") {
                    let session = URLSessionSpy()
                    let sessionTask = URLSessionDataTaskSpy()
                    session.dataTaskToReturn = sessionTask
                    session.completionHandlerArguments = (data: nil, response: nil, error: nil)
                    
                    let client = NetworkClient(with: session)
                    let expectedURL = URL(string: "http://www.example.com")!
                    
                    client.get(resourceAt: URL(string: "http://www.example.com")!) { _ in }
                    expect(session.dataTaskArguments?.url).to(equal(expectedURL))
                    expect(sessionTask.resumeWasInvoked).to(beTrue())
                }
            }
        }
    }
}

extension URLSession: URLSessionProtocol {}

class URLSessionSpy: URLSessionProtocol {
    var dataTaskArguments: (url: URL, completionHandler: (Data?, URLResponse?, Error?) -> ())?
    var dataTaskToReturn: URLSessionDataTask!
    var completionHandlerArguments: (data: Data?, response: URLResponse?, error: Error?)!
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskArguments = (url: url, completionHandler: completionHandler)
        
        completionHandler(completionHandlerArguments.data,
                          completionHandlerArguments.response,
                          completionHandlerArguments.error)
        
        return dataTaskToReturn
    }
}

class URLSessionDataTaskSpy: URLSessionDataTask {
    var resumeWasInvoked = false
    override func resume() {
        resumeWasInvoked = true
    }
}

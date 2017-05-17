import Quick
import Nimble

@testable import Client

class AsyncClientTests: QuickSpec {
    override func spec() {
        describe("making a network requst") {
            var session: URLSession!
            var client: NetworkClient!
            beforeEach {
                session = URLSession(configuration: .default)
                client = NetworkClient(with: session)
            }
            context("on success") {
                describe("the completion handler") {
                    it("invokes the completion handler with data") {
                        waitUntil(timeout: 10) { done in
                            
                            client.get(resourceAt: URL(string: "http://www.google.com")!) { result in
                                
                                defer{ done() }
                                
                                guard case Result.success(_) = result else {
                                    fail("expected to get data")
                                    return
                                }
                            }
                        }
                    }
                }
            }
            context("on failure") {
                describe("the completion handler") {
                    it("invokes the completion handler with an error") {
                        let session = URLSession(configuration: .default)
                        let client = NetworkClient(with: session)
                        
                        waitUntil(timeout: 10) { done in
                            
                            client.get(resourceAt: URL(string: "http://www.habskuyvabsibdkfhvbelasdkv.com")!) { result in
                                guard case Result.success(_) = result else {
                                    fail("expected to get data")
                                    return
                                }
                            }
                            done()
                        }
                    }
                }
            }
        }
    }
}

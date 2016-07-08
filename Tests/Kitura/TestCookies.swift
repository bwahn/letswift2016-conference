/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import XCTest
import Foundation

@testable import Kitura
@testable import KituraNet

#if os(Linux)
let cookie1Name = "KituraTest1"
let cookie1Value = "Testing-Testing-1-2-3"
let cookie2Name = "KituraTest2"
let cookie2Value = "Testing-Testing"
let cookie2ExpireExpected = NSDate(timeIntervalSinceNow: 600.0)
let cookie3Name = "KituraTest3"
let cookie3Value = "A-testing-we-go"

let cookieHost = "localhost"
#else
let cookie1Name = "KituraTest1" as NSString
let cookie1Value = "Testing-Testing-1-2-3"  as NSString
let cookie2Name = "KituraTest2"  as NSString
let cookie2Value = "Testing-Testing" as NSString
let cookie2ExpireExpected = NSDate(timeIntervalSinceNow: 600.0)
let cookie3Name = "KituraTest3" as NSString
let cookie3Value = "A-testing-we-go" as NSString

let cookieHost = "localhost" as NSString
#endif

class TestCookies : XCTestCase {

    static var allTests : [(String, (TestCookies) -> () throws -> Void)] {
        return [
            ("testCookieToServer", testCookieToServer),
            ("testCookieFromServer", testCookieFromServer)
        ]
    }

    override func tearDown() {
        doTearDown()
    }

    let router = TestCookies.setupRouter()

    func testCookieToServer() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/cookiedump", callback: {response in
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "cookiedump route did not match single path request")
                do {
                    let data = NSMutableData()
                    let count = try response!.readAllData(into: data)
                    XCTAssertEqual(count, 4, "Plover's value should have been four bytes")
                    if  let ploverValue = NSString(data: data, encoding: NSUTF8StringEncoding) {
                        XCTAssertEqual(ploverValue.bridge(), "qwer")
                    }
                    else {
                        XCTFail("Plover's value wasn't an UTF8 string")
                    }
                }
                catch {
                    XCTFail("Failed reading the body of the response")
                }
                expectation.fulfill()
            }, headers: ["Cookie": "Plover=qwer; Zxcv=tyuiop"])
        })
    }

    func testCookieFromServer() {
        performServerTest(router, asyncTasks: { expectation in
            self.performRequest("get", path: "/1/sendcookie", callback: {response in
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "/1/sendcookie route did not match single path request")

                let (cookie1, cookie1Expire) = self.cookieFrom(response: response!, named: cookie1Name as String)
                XCTAssert(cookie1 != nil, "Cookie \(cookie1Name) wasn't found in the response.")
                XCTAssertEqual(cookie1!.value, cookie1Value as String, "Value of Cookie \(cookie1Name) is not \(cookie1Value), was \(cookie1!.value)")
                XCTAssertEqual(cookie1!.path, "/", "Path of Cookie \(cookie1Name) is not (/), was \(cookie1!.path)")
                XCTAssertEqual(cookie1!.domain, cookieHost as String, "Domain of Cookie \(cookie1Name) is not \(cookieHost), was \(cookie1!.domain)")
                XCTAssertFalse(cookie1!.isSecure, "\(cookie1Name) was marked as secure. Should have not been marked so.")
                XCTAssertNil(cookie1Expire, "\(cookie1Name) had an expiration date. It shouldn't have had one")

                let (cookie2, cookie2Expire) = self.cookieFrom(response: response!, named: cookie2Name as String)
                XCTAssert(cookie2 != nil, "Cookie \(cookie2Name) wasn't found in the response.")
                XCTAssertEqual(cookie2!.value, cookie2Value as String, "Value of Cookie \(cookie2Name) is not \(cookie2Value), was \(cookie2!.value)")
                XCTAssertEqual(cookie2!.path, "/", "Path of Cookie \(cookie2Name) is not (/), was \(cookie2!.path)")
                XCTAssertEqual(cookie2!.domain, cookieHost as String, "Domain of Cookie \(cookie2Name) is not \(cookieHost), was \(cookie2!.domain)")
                XCTAssertFalse(cookie2!.isSecure, "\(cookie2Name) was marked as secure. Should have not been marked so.")
                XCTAssertNotNil(cookie2Expire, "\(cookie2Name) had no expiration date. It should have had one")
                XCTAssertEqual(cookie2Expire!, SPIUtils.httpDate(cookie2ExpireExpected))
                expectation.fulfill()
            })
        },
        { expectation in
            self.performRequest("get", path: "/2/sendcookie", callback: { response in
                XCTAssertEqual(response!.statusCode, HTTPStatusCode.OK, "/2/sendcookie route did not match single path request")

                let (cookie, cookieExpire) = self.cookieFrom(response: response!, named: cookie3Name as String)
                XCTAssertNotNil(cookie, "Cookie \(cookie3Name) wasn't found in the response.")
                XCTAssertEqual(cookie!.value, cookie3Value as String, "Value of Cookie \(cookie3Name) is not \(cookie3Value), was \(cookie!.value)")
                XCTAssertEqual(cookie!.path, "/", "Path of Cookie \(cookie3Name) is not (/), was \(cookie!.path)")
                XCTAssertEqual(cookie!.domain, cookieHost as String, "Domain of Cookie \(cookie3Name) is not \(cookieHost), was \(cookie!.domain)")
                XCTAssertTrue(cookie!.isSecure, "\(cookie3Name) wasn't marked as secure. It should have been marked so.")
                XCTAssertNil(cookieExpire, "\(cookie3Name) had an expiration date. It shouldn't have had one")
                expectation.fulfill()
            })
        })
    }

    func cookieFrom(response: ClientResponse, named: String) -> (NSHTTPCookie?, String?) {
        var resultCookie: NSHTTPCookie? = nil
        var resultExpire: String?
        for (headerKey, headerValues) in response.headers  {
            let lowercaseHeaderKey = headerKey.lowercased()
            if  lowercaseHeaderKey  ==  "set-cookie"  {
                for headerValue in headerValues {
                    let parts = headerValue.components(separatedBy: "; ")
                    let nameValue = parts[0].components(separatedBy: "=")
                    XCTAssertEqual(nameValue.count, 2, "Malformed Set-Cookie header \(headerValue)")

                    if  nameValue[0] == named  {
#if os(Linux)
                            var properties = [String: Any]()
                            let cookieName = nameValue[0]
                            let cookieValue = nameValue[1]
#else
                            var properties = [String: AnyObject]()
                            let cookieName = nameValue[0] as NSString
                            let cookieValue = nameValue[1] as NSString
#endif
                        properties[NSHTTPCookieName]  =  cookieName
                        properties[NSHTTPCookieValue] =  cookieValue

                        for  part in parts[1..<parts.count] {
                            var pieces = part.components(separatedBy: "=")
                            let piece = pieces[0].lowercased()
                            switch(piece) {
                                case "secure", "httponly":
                                    properties[NSHTTPCookieSecure] = "Yes"
                                case "path" where pieces.count == 2:
#if os(Linux)
                                    let path = pieces[1]
#else
                                    let path = pieces[1] as NSString
#endif
                                    properties[NSHTTPCookiePath] = path
                                case "domain" where pieces.count == 2:
#if os(Linux)
                                    let domain = pieces[1]
#else
                                    let domain = pieces[1] as NSString
#endif
                                    properties[NSHTTPCookieDomain] = domain
                                case "expires" where pieces.count == 2:
                                    resultExpire = pieces[1]
                                default:
                                    XCTFail("Malformed Set-Cookie header \(headerValue)")
                            }
                        }

                        XCTAssertNotNil(properties[NSHTTPCookieDomain], "Malformed Set-Cookie header \(headerValue)")
                        resultCookie = NSHTTPCookie(properties: properties)
                        break
                    }
                }
            }
        }

        return (resultCookie, resultExpire)
    }


    static func setupRouter() -> Router {
        let router = Router()

        router.get("/1/cookiedump") {request, response, next in
            response.status(HTTPStatusCode.OK)
            if  let ploverCookie = request.cookies["Plover"]  {
                response.send(ploverCookie.value)
            }

            next()
        }

        router.get("/1/sendcookie") {request, response, next in
            response.status(HTTPStatusCode.OK)

            let cookie1 = NSHTTPCookie(properties: [NSHTTPCookieName: cookie1Name,
                                                NSHTTPCookieValue: cookie1Value,
                                                NSHTTPCookieDomain: cookieHost,
                                                NSHTTPCookiePath: "/"])
            response.cookies[cookie1!.name] = cookie1
            let cookie2 = NSHTTPCookie(properties: [NSHTTPCookieName: cookie2Name,
                                                NSHTTPCookieValue: cookie2Value,
                                                NSHTTPCookieDomain: cookieHost,
                                                NSHTTPCookiePath: "/",
                                                NSHTTPCookieExpires: cookie2ExpireExpected])
            response.cookies[cookie2!.name] = cookie2

            next()
        }

        router.get("/2/sendcookie") {request, response, next in
            response.status(HTTPStatusCode.OK)

            let cookie = NSHTTPCookie(properties: [NSHTTPCookieName: cookie3Name,
                                                NSHTTPCookieValue: cookie3Value,
                                                NSHTTPCookieDomain: cookieHost,
                                                NSHTTPCookiePath: "/",
                                                NSHTTPCookieSecure: "Yes"])
            response.cookies[cookie!.name] = cookie

            next()
        }

        return router
    }
}

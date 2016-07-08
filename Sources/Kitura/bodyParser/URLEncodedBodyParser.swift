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

import Foundation

class URLEncodedBodyParser: BodyParserProtocol {
    func parse(_ data: NSData) -> ParsedBody? {
        var parsedBody = [String:String]()
        var success = true
        if let bodyAsString: String = String(data: data, encoding: NSUTF8StringEncoding) {
            let bodyAsArray = bodyAsString.components(separatedBy: "&")

            for element in bodyAsArray {
                let elementPair = element.components(separatedBy: "=")
                if elementPair.count == 2 {
                    parsedBody[elementPair[0]] = elementPair[1]
                } else {
                    success = false
                }
            }
            if success && parsedBody.count > 0 {
                return .urlEncoded(parsedBody)
            }
        }
        return nil
    }
}

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


import LoggerAPI
import Foundation

extension StaticFileServer {
    // MARK: FileServer
    class FileServer {
        //
        // Serve "index.html" files in response to a request on a directory.
        //
        private let serveIndexForDirectory: Bool

        //
        // Redirect to trailing "/" when the pathname is a dir.
        //
        private let redirect: Bool

        //
        // the path from where the files are served
        //
        private let servingFilesPath: String

        //
        // If a file is not found, the given extensions will be added to the file name and searched for.
        // The first that exists will be served.
        //
        private let possibleExtensions: [String]

        //
        // A setter for response headers.
        //
        private let responseHeadersSetter: ResponseHeadersSetter?

        init(serveIndexForDirectory: Bool, redirect: Bool,
             servingFilesPath: String, possibleExtensions: [String] = [String](),
             responseHeadersSetter: ResponseHeadersSetter? = nil) {
            self.possibleExtensions = possibleExtensions
            self.serveIndexForDirectory = serveIndexForDirectory
            self.redirect = redirect
            self.servingFilesPath = servingFilesPath
            self.responseHeadersSetter = responseHeadersSetter
        }

        func getFilePath(from request: RouterRequest) -> String? {
            var filePath = servingFilesPath
            guard let requestPath = request.parsedURL.path else {
                return nil
            }
            var matchedPath = request.matchedPath
            if matchedPath.hasSuffix("*") {
                matchedPath = String(matchedPath.characters.dropLast())
            }
            if !matchedPath.hasSuffix("/") {
                matchedPath += "/"
            }

            if requestPath.hasPrefix(matchedPath) {
                let url = String(requestPath.characters.dropFirst(matchedPath.characters.count))
                filePath += "/" + url
            }

            if filePath.hasSuffix("/") {
                if serveIndexForDirectory {
                    filePath += "index.html"
                } else {
                    return nil
                }
            }

            return filePath
        }

        func serveFile(_ filePath: String, requestPath: String, response: RouterResponse) {
            let fileManager = NSFileManager()
            var isDirectory = ObjCBool(false)

            if fileManager.fileExists(atPath: filePath, isDirectory: &isDirectory) {
                serveExistingFile(filePath, requestPath: requestPath,
                                  isDirectory: isDirectory.boolValue, response: response)
                return
            }

            tryToServeWithExtensions(filePath, response: response)
        }

        private func tryToServeWithExtensions(_ filePath: String, response: RouterResponse) {
            let filePathWithPossibleExtensions = possibleExtensions.map { filePath + "." + $0 }
            for filePathWithExtension in filePathWithPossibleExtensions {
                serveIfNonDirectoryFile(atPath: filePathWithExtension, response: response)
            }
        }

        private func serveExistingFile(_ filePath: String, requestPath: String, isDirectory: Bool,
                                       response: RouterResponse) {
            if isDirectory {
                if redirect {
                    do {
                        try response.redirect(requestPath + "/")
                    } catch {
                        response.error = Error.failedToRedirectRequest(path: requestPath + "/", chainedError: error)
                    }
                }
            } else {
                serveNonDirectoryFile(filePath, response: response)
            }
        }

        @discardableResult
        private func serveIfNonDirectoryFile(atPath path: String, response: RouterResponse) -> Bool {
            var isDirectory = ObjCBool(false)
            if NSFileManager().fileExists(atPath: path, isDirectory: &isDirectory) {
                if !isDirectory.boolValue {
                    serveNonDirectoryFile(path, response: response)
                    return true
                }
            }
            return false
        }

        private func serveNonDirectoryFile(_ filePath: String, response: RouterResponse) {
            if  !isValidFilePath(filePath) {
                return
            }

            do {
                let fileAttributes = try NSFileManager().attributesOfItem(atPath: filePath)
                responseHeadersSetter?.setCustomResponseHeaders(response: response,
                                                                filePath: filePath,
                                                                fileAttributes: fileAttributes)

                try response.send(fileName: filePath)
            } catch {
                Log.error("serving file at path \(filePath) error: \(error)")
            }
            response.statusCode = .OK
        }

        private func isValidFilePath(_ filePath: String) -> Bool {
            // Check that no-one is using ..'s in the path to poke around the filesystem
            let absoluteBasePath = NSURL(fileURLWithPath: servingFilesPath).absoluteString
            let absoluteFilePath = NSURL(fileURLWithPath: filePath).absoluteString

            return  absoluteFilePath.hasPrefix(absoluteBasePath)
        }
    }
}

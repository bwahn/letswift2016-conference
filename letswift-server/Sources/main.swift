import Foundation

import SwiftyJSON
import Kitura
import KituraNet

import LoggerAPI
import HeliumLogger

let router = Router()

Log.logger = HeliumLogger()

var objectivecCount = 0
var swiftCount = 0

router.get("/vote") { _, response, next in
    response.headers["Content-Type"] = "application/json"
    var errorResponse = JSON([:])
    errorResponse["error"].stringValue = "Failed to Get Vote result."
    
    var result = JSON([:])
    result["objective-c"].int = swiftCount
    result["swift"].int = swiftCount
    response.status(HTTPStatusCode.OK).send(json: result)
    next()    
}


router.put("/votes/objectivec_voted") { request, response, next in
    response.headers["Content-Type"] = "application/json"
    objectivecCount += 1
    
    try response.send("Got a PUT request").end()
}

router.put("/votes/swift_voted") { request, response, next in
    response.headers["Content-Type"] = "application/json"
    swiftCount += 1

    try response.send("Got a PUT request").end()
}

// Handles any errors that get set
router.error { request, response, next in
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    let errorDescription: String
    if let error = response.error {
        errorDescription = "\(error)"
    } else {
        errorDescription = "Unknown error"
    }
    try response.send("Caught the error: \(errorDescription)").end()
}

// A custom Not found handler
router.all { request, response, next in
    if  response.statusCode == .unknown  {
        // Remove this wrapping if statement, if you want to handle requests to / as well
        if  request.originalURL != "/"  &&  request.originalURL != ""  {
            try response.status(.notFound).send("Route not found in Sample application!").end()
        }
    }
    next()
}

// Add HTTP Server to listen on port 8090
Kitura.addHTTPServer(onPort: 8090, with: router)

// start the framework - the servers added until now will start listening
Kitura.run()

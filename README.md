# letswift2016-conference

SlideShare : http://www.slideshare.net/EricAhn/swift-serversidelet-swift2016

# VirtualBox ( local machine )

```
$ git clone https://github.com/bwahn/letswift2016-conference.git
$ cd letswift-server
$ vagrant up

$ vagrant ssh
vagrant@ $ git clone https://github.com/bwahn/letswift2016-conference.git
vagrant@ $ cd letswift2016-conference/letswift-server
vagrant@ $ swift build -Xcc -fblocks
vagrant@ $ .build/debug/letswift-api

```
letswift-api(backend service) can be requested at the following URL(s):
```
$ curl  http://192.168.99.100:8090/vote
{
  "swift": 0,
  "objective-c": 0
}
```

# For Docker

```
$ docker-machine create -d virtualbox default

$ docker-machine env default

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.99.100:2376"
export DOCKER_CERT_PATH="/Users/EricAhn/.docker/machine/machines/default"
export DOCKER_MACHINE_NAME="default"
# Run this command to configure your shell:
# eval $(docker-machine env default)

$ eval $(docker-machine env default)

$ docker-machine ip default
192.168.99.100

$ docker ps -a 
 ID        IMAGE               COMMAND                  CREATED             STATUS                       PORTS               NAMES
 
$ git clone https://github.com/bwahn/letswift2016-conference.git

$ docker build -t swift-api .
$ docker images
REPOSITORY             TAG                 IMAGE ID            CREATED             SIZE
swift-api              latest              39d4243ed71c        4 minutes ago       1.524 GB
ibmcom/kitura-ubuntu   latest              20cb1052cd2e        2 weeks ago         1.524 GB
ibmcom/swift-ubuntu    latest              b4daffd2bbaf        2 weeks ago         1.233 GB

$ docker run -d -p 8090:8090 --name api swift-api:latest

$ docker ps -a
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS                       PORTS               NAMES
c2c8fe350454        swift-api:latest    "/letswift-api/run_sw"   4 minutes ago       Up 56 seconds       0.0.0.0:8090->8090/tcp   api

$ docker logs -f c2
>> About to clone branch 'develop' for Kitura-Starter-Bluemix
Cloning into 'Kitura-Starter-Bluemix'...
>> About to build Kitura-Starter-Bluemix...
--- Fetching Kitura-Build submodule
git submodule update --init
Submodule 'Kitura-Build' (https://github.com/IBM-Swift/Kitura-Build.git) registered for path 'Kitura-Build'
Cloning into 'Kitura-Build'...
Submodule path 'Kitura-Build': checked out 'b676611b130fad65172230c346eed088972383f6'
--- Running build on Linux
--- Build scripts directory: Kitura-Build/build
--- Checking swift version
swift --version
Swift version 3.0-dev (LLVM cb08d1dbbd, Clang 383859a9c4, Swift 9e8266aaeb)
Target: x86_64-unknown-linux-gnu
--- Checking swiftc version
swiftc --version
Swift version 3.0-dev (LLVM cb08d1dbbd, Clang 383859a9c4, Swift 9e8266aaeb)
Target: x86_64-unknown-linux-gnu
--- Checking git version
git --version
git version 2.5.0
--- Checking git revision and branch
git rev-parse HEAD
14d53acf87dd3ee4ceee6db2b04a29c5a85020a4
git rev-parse --abbrev-ref HEAD
develop
--- Checking Linux release
lsb_release -d
make: lsb_release: Command not found
Kitura-Build/build/Makefile:37: recipe for target 'build' failed
make: [build] Error 127 (ignored)
--- Invoking swift build
swift build -Xcc -fblocks -Xlinker -rpath -Xlinker .build/debug
Cloning https://github.com/IBM-Swift/Kitura.git
HEAD is now at 9bce21b Merge branch 'develop' of https://github.com/IBM-Swift/Kitura into develop
Resolved version: 0.19.4
Cloning https://github.com/IBM-Swift/Kitura-net.git
HEAD is now at c18958a Migrated to 05-31 swift snapshot (#36)
Resolved version: 0.19.0
Cloning https://github.com/IBM-Swift/Kitura-sys.git
HEAD is now at 81b9b3b Updated dependency version
Resolved version: 0.17.1
Cloning https://github.com/IBM-Swift/LoggerAPI.git
HEAD is now at 9b30704 Merge pull request #8 from tkhuran/develop
Resolved version: 0.8.0
Cloning https://github.com/IBM-Swift/BlueSocket.git
HEAD is now at 6e8915c Added blurb about BlueSSLService add-on.
Resolved version: 0.5.20
Cloning https://github.com/IBM-Swift/CCurl.git
HEAD is now at 3330699 Removed use of pkgConfig and added system declaration
Resolved version: 0.2.1
Cloning https://github.com/IBM-Swift/CHTTPParser.git
HEAD is now at 41daabb IBM-Swift/Kitura#365 Removed references to code installed externally and the pkgConfig file that is no longer needed.
Resolved version: 0.1.1
Cloning https://github.com/IBM-Swift/SwiftyJSON.git
HEAD is now at 3dc35da IBM-Swift/Kitura#504 updates to work on linux os for 31-05 migration (#5)
Resolved version: 9.0.0
Cloning https://github.com/IBM-Swift/Kitura-TemplateEngine.git
HEAD is now at 1fe55ef Merge remote-tracking branch 'origin/develop'
Resolved version: 0.16.0
Cloning https://github.com/IBM-Swift/HeliumLogger.git
HEAD is now at 5fc6385 Merge branch 'develop'
Resolved version: 0.10.1
Cloning https://github.com/IBM-Swift/Swift-cfenv
HEAD is now at eefdf83 Migrating code to swift 06-06.
Resolved version: 1.3.0
Compile CHttpParser http_parser.c
Compile CHttpParser utils.c
Compile Swift Module 'LoggerAPI' (1 sources)
clang: warning: argument unused during compilation: '-Xcc'
Compile Swift Module 'Socket' (3 sources)
Compile Swift Module 'SwiftyJSON' (2 sources)
clang: warning: argument unused during compilation: '-Xcc'
Compile Swift Module 'KituraTemplateEngine' (1 sources)
Compile Swift Module 'KituraSys' (3 sources)
Compile Swift Module 'HeliumLogger' (1 sources)
Linking CHttpParser
Compile Swift Module 'KituraNet' (12 sources)
Compile Swift Module 'CloudFoundryEnv' (7 sources)
Compile Swift Module 'Kitura' (35 sources)
Compile Swift Module 'Kitura_Starter_Bluemix' (1 sources)
Linking .build/debug/Kitura-Starter-Bluemix
>> Build for Kitura-Starter-Bluemix completed (see above for results).
>> About to test Kitura...
...
...
VERBOSE: run() Kitura.swift line 44 - Staring Kitura framework...
 VERBOSE: run() Kitura.swift line 46 - Starting an HTTP Server on port 8090...
 INFO: listen(socket:port:) HTTPServer.swift line 149 - Listening on port 8090
 INFO: listen(socket:port:) HTTPServer.swift line 154 - Accepted connection from: 192.168.99.1:54075
 WARNING: init() ContentType.swift line 52 - Loading embedded MIME types.
```


letswift-api(backend service) can be requested at the following URL(s):
```
$ curl  http://192.168.99.100:8090/vote
{
  "swift": 0,
  "objective-c": 0
}
```


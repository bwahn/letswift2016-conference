![Kitura](https://raw.githubusercontent.com/IBM-Swift/Kitura/master/Documentation/KituraLogo.png)

**A Swift Web Framework and HTTP Server**

[![Build Status - Master](https://travis-ci.org/IBM-Swift/Kitura.svg?branch=master)](https://travis-ci.org/IBM-Swift/Kitura)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)
![Apache 2](https://img.shields.io/badge/license-Apache2-blue.svg?style=flat)
[![Join the chat at https://gitter.im/IBM-Swift/Kitura](https://badges.gitter.im/IBM-Swift/Kitura.svg)](https://gitter.im/IBM-Swift/Kitura?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

## Summary

Kitura is a web framework and web server that is created for web services written in Swift.

## Table of Contents
* [Summary](#summary)
* [Features](#features)
* [Swift version](#swift-version)
* [Installation (Docker development environment)](#installation-docker-development-environment)
* [Installation (Vagrant development environment)](#installation-vagrant-development-environment)
* [Installation (macOS)](#installation-macos)
* [Installation (Linux, Apt-based)](#installation-linux-apt-based)
* [Developing Kitura applications](#developing-kitura-applications)
* [Kitura Wiki](#kitura-wiki)
* [Developing Kitura](#developing-kitura)
* [License](#license)

## Features:

- URL routing (GET, POST, PUT, DELETE)
- URL parameters
- Static file serving
- JSON parsing
- Pluggable middleware

## Swift version
This branch of Kitura requires the **`DEVELOPMENT-SNAPSHOT-2016-06-06-a`** version of Swift 3 trunk (master). You can download this version at [swift.org](https://swift.org/download/). *Kitura is unlikely to compile with any other version of Swift.*

## Installation (Docker development environment)

1. Install [Docker](https://docs.docker.com/engine/installation/) on your development system and start a Docker session/terminal.

2. From the Docker session, pull down the [kitura-ubuntu](https://hub.docker.com/r/ibmcom/kitura-ubuntu/) image from Docker Hub:

  `docker pull ibmcom/kitura-ubuntu:latest`

3. Create a Docker container using the `kitura-ubuntu` image you just downloaded and forward port 8090 on host to the container:

  `docker run -i -p 8090:8090 -t ibmcom/kitura-ubuntu:latest /bin/bash`

4. From within the Docker container, execute the `clone_build_test_kitura.sh` script to build Kitura and execute the test cases:

  `/root/clone_build_test_kitura.sh`

  The last output line from executing the `clone_build_test_kitura.sh` script should be similar to:

  `>> Finished execution of tests for Kitura (see above for results).`

5. You can now run the KituraSample executable inside the Docker container:

  `/root/start_kitura_sample.sh`

  You should see a message that says "Listening on port 8090".

## Installation (Vagrant development environment)

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads).

2. Install [Vagrant](https://www.vagrantup.com/downloads.html).

3. From the root of the Kitura folder containing the `vagrantfile`, create and configure a guest machine:

 `vagrant up`

4. SSH into the Vagrant machine:

 `vagrant ssh`

5. As needed for development, edit the `vagrantfile` to setup [Synced Folders](https://www.vagrantup.com/docs/synced-folders/basic_usage.html) to share files between your host and guest machine.

6. Now you are ready to develop your first Kitura App. Check [Kitura Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Developing Kitura applications](#developing-kitura-applications).

## Installation (macOS)

1. Install [Homebrew](http://brew.sh/) (if you don't already have it installed):

 `ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`

2. Install the necessary dependencies:

 `brew install curl`

3. Download and install the [supported Swift compiler](#swift-version).

 During installation if you are using the package installer make sure to select "all users" for the installation path in order for the correct toolchain version to be available for use with the terminal.

 After installation, make sure you update your PATH environment variable as described in the installation instructions (e.g. export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH)

4. Now you are ready to develop your first Kitura App. Check [Kitura Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Developing Kitura applications](#developing-kitura-applications).

## Installation (Linux, Apt-based)

1. Install the following system linux libraries:

 `sudo apt-get install autoconf libtool libkqueue-dev libkqueue0 libcurl4-openssl-dev libbsd-dev libblocksruntime-dev`

2. Install the [supported Swift compiler](#swift-version) for Linux.

 Follow the instructions provided on that page. After installing it (i.e. uncompressing the tar file), make sure you update your PATH environment variable so that it includes the extracted tools: `export PATH=/<path to uncompress tar contents>/usr/bin:$PATH`. To update the PATH env variable, you can update your [.bashrc file](http://www.joshstaiger.org/archives/2005/07/bash_profile_vs.html).

3. Clone, build and install the libdispatch library.
The complete instructions for building and installing this library are  [here](https://github.com/apple/swift-corelibs-libdispatch/blob/experimental/foundation/INSTALL), though, all you need to do is just this
 `git clone --recursive -b experimental/foundation https://github.com/apple/swift-corelibs-libdispatch.git && cd swift-corelibs-libdispatch && sh ./autogen.sh && ./configure --with-swift-toolchain=<path-to-swift>/usr --prefix=<path-to-swift>/usr && make && make install`

4. Now you are ready to develop your first Kitura App. Check [Kitura Sample](https://github.com/IBM-Swift/Kitura-Sample) or see [Developing Kitura applications](#developing-kitura-applications).

## Developing Kitura applications
Let's develop our first Kitura Web Application written in Swift!

1. First we create a new project directory

  ```bash
  mkdir myFirstProject
  ```

2. Next we initialize this project as a new Swift package project

  ```bash
  cd myFirstProject
  swift package init
  ```

  Now your directory structure under myFirstProject should look like this:
  <pre>
  myFirstProject
  ├── Package.swift
  ├── Sources
  │   └── main.swift
  └── Tests
      └── <i>empty</i>
  </pre>

  Note: For more information on the Swift Package Manager, go [here](https://swift.org/package-manager)

3. Now we add Kitura as a dependency for your project (Package.swift):

  ```swift
  import PackageDescription

  let package = Package(
      name: "myFirstProject",
      dependencies: [
          .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 0, minor: 20)
      ])
  ```

4. Import Kitura module in your code (Sources/main.swift):

  ```swift
  import Kitura
  ```
5. Add a router and a path:

  ```swift
  let router = Router()

  router.get("/") {
      request, response, next in
      response.send("Hello, World!")
      next()
  }
  ```

6. Add an HTTP Server to Kitura framework and start Kitura framework:

  ```swift
  Kitura.addHTTPServer(onPort: 8090, with: router)
  Kitura.run()
  ```

7. Sources/main.swift file should now look like this:

  ```swift
  import Kitura

  let router = Router()

  router.get("/") {
      request, response, next in
      response.send("Hello, World!")
      next()
  }

  Kitura.addHTTPServer(onPort: 8090, with: router)
  Kitura.run()
  ```

8. Optionally add logging

   In the code example above, no messages from Kitura will logged. You may want to add a logger to help diagnose problems that occur. This is
   completely optional, Kitura will run perfectly without a logger.
   
   You also need to add HeliumLogger to your `Package.swift` file. It should look like this:
   ```Swift
   import PackageDescription
   let package = Package(
    name: "myFirstProject",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 0, minor: 20),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger", majorVersion: 0, minor: 9),
    ])
   ```

   To add a logger simply add the following lines, after the `import Kitura` statement in the Sources/main.swift file shown above:

   ```swift
   import HeliumLogger

   HeliumLogger.use()
   ```

   The overall Sources/main.swift file would then be:

   ```swift
   import Kitura
   import HeliumLogger

   HeliumLogger.use()

   let router = Router()

   router.get("/") {
       request, response, next in
       response.send("Hello, World!")
       next()
   }

   Kitura.addHTTPServer(onPort: 8090, with: router)
   Kitura.run()
   ```

9. Compile your application:

  - macOS: `swift build`
  - Linux:  `swift build -Xcc -fblocks`

  Or copy [Makefile and build scripts](https://github.com/IBM-Swift/Kitura-Build/blob/master/build) to your project directory and run `make build`. You may want to customize this Makefile and use it for building, testing and running your application. For example, you can clean your build directory, refetch all the dependencies, build, test and run your application by running `make clean refetch test run`.

10. Now run your new web application:

  ```
  .build/debug/myFirstProject
  ```

11. Open your browser at [http://localhost:8090](http://localhost:8090)

## Kitura Wiki
Feel free to visit our [Wiki](https://github.com/IBM-Swift/Kitura/wiki) for our roadmap and some tutorials.

## Developing Kitura

1. Clone this repository, `master` branch
  `git clone -b master https://github.com/IBM-Swift/Kitura`
2. Build and run tests
  `make test`

 ### Notes
 * Homebrew by default installs libraries to `/usr/local`, if yours is different, change the path to find the curl library, in `Kitura-Build/build/Makefile`:

   ```Makefile
   SWIFTC_FLAGS = -Xswiftc -I/usr/local/include
   LINKER_FLAGS = -Xlinker -L/usr/local/lib
   ```

You can find info on contributing to Kitura in our [contributing guidelines](.github/CONTRIBUTING.md).

## License

This library is licensed under Apache 2.0. Full license text is available in [LICENSE](LICENSE.txt).

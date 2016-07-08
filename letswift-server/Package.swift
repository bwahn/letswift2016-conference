import PackageDescription

let package = Package(
    name: "letswift-api",
    targets: [
        Target(
            name: "letswift-api",
            dependencies: []
        )
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/Kitura.git", majorVersion: 0, minor: 21),
        .Package(url: "https://github.com/IBM-Swift/HeliumLogger.git", majorVersion: 0, minor: 10),
        //.Package(url: "https://github.com/IBM-Swift/Kitura-MustacheTemplateEngine.git", majorVersion: 0, minor: 13),
    ],
    exclude: ["Makefile", "Kitura-Build"])


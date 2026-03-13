// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "ClipboardHistory",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "ClipboardHistoryApp", targets: ["ClipboardHistoryApp"])
    ],
    targets: [
        .executableTarget(
            name: "ClipboardHistoryApp",
            path: "Sources/ClipboardHistoryApp",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ClipboardHistoryAppTests",
            dependencies: ["ClipboardHistoryApp"],
            path: "Tests/ClipboardHistoryAppTests"
        )
    ]
)

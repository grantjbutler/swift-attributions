import ArgumentParser
import Foundation
import System

@main
struct AttributionGenerator: AsyncParsableCommand {
    @Argument(transform: { try JSONDecoder().decode(PackageDesciption.self, from: Data($0.utf8)) })
    var packages: [PackageDesciption]
    
    @Option(transform: FilePath.init(_:))
    var outputPath = FilePath(FileManager.default.currentDirectoryPath)
    
    mutating func run() async throws {
        try? FileManager.default.removeItem(atPath: outputPath.string)
        
        try? FileManager.default.createDirectory(atPath: outputPath.string, withIntermediateDirectories: true)
        
        try packages.forEach(processPackage(_:))
    }
    
    func processPackage(_ description: PackageDesciption) throws {
        print("Processing package \(description.name) at \(description.path)")
        
        let licenseFiles = try FileManager.default.contentsOfDirectory(atPath: description.path)
            .filter { $0 == "LICENSE" || $0.hasPrefix("LICENSE.") }
        
        guard let licenseFileName = licenseFiles.first else {
            print("No license found for \(description.name). Skipping...")
            return
        }
        
        print("Found license file at \(licenseFileName)")
        
        let inputFile = FilePath(description.path).appending(licenseFileName)
        let path = outputPath.appending("\(description.name).txt")
        try FileManager.default.copyItem(atPath: inputFile.string, toPath: path.string)
    }
}

struct PackageDesciption: Codable {
    let name: String
    let path: String
}

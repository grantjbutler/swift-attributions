import Foundation

public struct Attribution: Identifiable, Sendable {
    public let id: UUID
    public let name: String
    public let licenseURL: URL
}

public actor AttributionsLoader {
    public init() {}
    
    public func loadAttributions() -> [Attribution] {
        guard let resourceURL = Bundle.main.resourceURL else { return [] }
        
        var attributionsFileURL: URL?
        
        guard let enumerator = FileManager.default.enumerator(at: resourceURL, includingPropertiesForKeys: [], options: [.skipsSubdirectoryDescendants]) else { return [] }
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "bundle" {
            let attributionsFileDirectory = fileURL.appending(path: "__Attribution-Licenses", directoryHint: .isDirectory)
            var isDirectory: ObjCBool = false
            if FileManager.default.fileExists(atPath: attributionsFileDirectory.path(), isDirectory: &isDirectory), isDirectory.boolValue {
                attributionsFileURL = attributionsFileDirectory
                break
            }
        }
        
        guard let attributionsFileURL else { return [] }
        
        guard let licenseEnumerator = FileManager.default.enumerator(at: attributionsFileURL, includingPropertiesForKeys: [], options: [.skipsSubdirectoryDescendants]) else { return [] }
        
        var attributions: [Attribution] = []
        for case let fileURL as URL in licenseEnumerator {
            attributions.append(Attribution(id: UUID(), name: fileURL.deletingPathExtension().lastPathComponent, licenseURL: fileURL))
        }
        
        return attributions.sorted(by: { $0.name < $1.name })
    }

    public func loadAttribution(at fileURL: URL) -> String {
        return (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
    }
}

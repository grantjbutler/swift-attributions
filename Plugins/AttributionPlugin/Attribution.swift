import Foundation
import PackagePlugin

@main
struct Attribution: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let packages = self.packages(for: target, in: context.package)
        
        let generatorTool = try context.tool(named: "AttributionGenerator")
        
        return [
            try self.createBuildCommand(
                for: context.package,
                packages: packages,
                outputDirectory: context.pluginWorkDirectoryURL.appending(
                    path: "__Attribution-Licenses",
                    directoryHint: .isDirectory
                ),
                with: generatorTool.url
            )
        ]
    }
    
    func packages(for target: Target, in package: Package) -> [Package] {
        let dependencies = target.sourceTargetDependencies
        let mapping = package.targetPackageMapping
        
        var visited = Set<Package.ID>()
        return dependencies.reduce(into: [Package]()) { packages, dependency in
            guard let dependecyPackage = mapping[dependency.id] else { return }
            guard visited.insert(dependecyPackage.id).inserted else { return }
            if dependecyPackage.id == package.id { return }
            packages.append(dependecyPackage)
        }
    }
}

extension Package {
    var targetPackageMapping: [String: Package] {
        var visited = Set<Package.ID>()
        func dependencyClosure(for `package`: Package, mapping: inout [Target.ID: Package]) {
            guard visited.insert(`package`.id).inserted else { return }
            
            mapping = `package`.targets.reduce(into: mapping) { mapping, target in
                mapping[target.id] = `package`
            }
            
            mapping = `package`.dependencies.reduce(into: mapping, { mapping, dependency in
                dependencyClosure(for: dependency.package, mapping: &mapping)
            })
        }
        
        func dependencyClosure(for dependency: Package) -> [Target.ID: Package] {
            var mapping = [Target.ID: Package]()
            dependencyClosure(for: self, mapping: &mapping)
            return mapping
        }
        
        return dependencyClosure(for: self)
    }
}

extension Target {
    var sourceTargetDependencies: [Target] {
        var visited = Set<Target.ID>()
        func dependencyClosure(for target: Target) -> [Target] {
            guard visited.insert(target.id).inserted else { return [] }
            guard let sourceModule = target.sourceModule else { return [] }
            guard sourceModule.kind == .generic else { return [] }
            return target.dependencies.flatMap { dependencyClosure(for: $0) } + [target]
        }
        func dependencyClosure(for dependency: TargetDependency) -> [Target] {
            switch dependency {
            case .target(let target):
                return dependencyClosure(for: target)
            case .product(let product):
                return product.targets.flatMap { dependencyClosure(for: $0) }
            @unknown default:
                return []
            }
        }
        return self.dependencies.flatMap { dependency -> [Target] in
            return dependencyClosure(for: dependency)
        }
    }
}

struct PackageDescription: Codable {
    let name: String
    let path: String
}

extension Attribution {
    func createBuildCommand(for package: Package, packages: [Package], outputDirectory: URL, with generatorToolURL: URL) throws -> Command {
        let resolvedPackagePath = package.directoryURL.appending(component: "Package.resolved")
        
        let arguments = try ["--output-path", outputDirectory.path()] + packages.map { package in
            let description = PackageDescription(name: package.displayName, path: package.directoryURL.path())
            let encodedDescription = try JSONEncoder().encode(description)
            return String(decoding: encodedDescription, as: UTF8.self)
        }
        
        return .buildCommand(
            displayName: "Generate Attribution Files",
            executable: generatorToolURL,
            arguments: arguments,
            inputFiles: [resolvedPackagePath],
            outputFiles: [outputDirectory]
        )
    }
}

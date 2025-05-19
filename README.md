# swift-attributions

swift-attributions is a package that automatically detects the licenses for your SPM packages, copies them into your application, and manages UI to render the licenses.

## Installation

### Xcode

You can add swift-attributions to your Xcode project by adding it as a package with the URL `https://github.com/grantjbutler/swift-attributions` and selecting the library for the UI framework of your project. After adding the package, add the `AttributionPlugin` as a plug-in in the "Run Build Tool Plug-ins" build phase of your Xcode project. This should be added to the root target of your project so it can detect all of the dependencies used by your project. 

### Swift Package Manager

If you want to use swift-attributions in an SPM package, add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/grantjbutler/swift-attributions", branch: "main")
]
```

Next, add the plug-in to the root target of your package so it can detect all of the dependencies used by your project:

```swift
plugins: [
    .plugin(name: "AttributionPlugin", package: "swift-attributions")
]
```

Finally, add the library for the UI framework of your project and add it to the target which will display this UI:

```swift
dependencies: [
    .product(name: "AttributionsSwiftUI", package: "swift-attributions")
]
```

## Usage

After adding the package and plug-in to your codebase, import the library that corresponds to your UI framework and create an instance of the base view. For SwiftUI, this is `AttributionsView`. For UIKit, this is `AttributionsViewController`. Insert this view into the appropriate place in your view hierarchy.

That's it! The view will automatically detect the bundled license files, display a list of them, and then display the licenes for that library when opened.


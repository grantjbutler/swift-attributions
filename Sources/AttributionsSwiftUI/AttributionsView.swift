import AttributionsCore
import SwiftUI

public struct AttributionsView: View {
    @State
    private var attributions: [Attribution] = []
    
    public init() { }
    
    public var body: some View {
        List {
            ForEach(attributions) { attribution in
                NavigationLink {
                    AttributionView(attribution: attribution)
                } label: {
                    Text(attribution.name)
                }
            }
        }
        .task {
            let loader = AttributionsLoader()
            attributions = await loader.loadAttributions()
        }
        .navigationTitle(Text("Attributions"))
    }
}

extension AttributionsView {
    struct AttributionView: View {
        private let attribution: Attribution
        
        @State
        private var licenseText = ""
        
        init(attribution: Attribution) {
            self.attribution = attribution
        }
        
        var body: some View {
            ScrollView {
                Text(licenseText)
                    .padding()
            }
            .task { @MainActor in
                let loader = AttributionsLoader()
                licenseText = await loader.loadAttribution(at: attribution.licenseURL)
            }
            .navigationTitle(Text(attribution.name))
        }
    }
}


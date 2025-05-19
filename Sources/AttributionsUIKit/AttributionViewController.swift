import AttributionsCore
import UIKit

final class AttributionViewController: UIViewController {
    let attribution: Attribution
    private var text: String = "" {
        didSet {
            guard isViewLoaded else { return }
            textView.text = text
        }
    }
    
    private let textView = UITextView()
    
    init(attribution: Attribution) {
        self.attribution = attribution
        
        super.init(nibName: nil, bundle: nil)
        
        title = attribution.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Task { @MainActor [weak self, attribution] in
            let loader = AttributionsLoader()
            self?.text = await loader.loadAttribution(at: attribution.licenseURL)
        }
        
        view.addSubview(textView)
        
        textView.text = text
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.frame = view.bounds
    }
}

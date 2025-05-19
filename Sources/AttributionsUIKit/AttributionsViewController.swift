import AttributionsCore
import UIKit

@MainActor
private let configuration = UICollectionView.CellRegistration<UICollectionViewListCell, Attribution> { cell, indexPath, itemIdentifier in
    var configuration = cell.defaultContentConfiguration()
    
    configuration.text = itemIdentifier.name
    
    cell.contentConfiguration = configuration
    cell.accessories = [.disclosureIndicator()]
}

public final class AttributionsViewController: UIViewController {
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout.list(
            using: .init(appearance: UICollectionLayoutListConfiguration.Appearance.insetGrouped)
        )
    )
    
    private var attributions: [Attribution] = [] {
        didSet {
            guard isViewLoaded else { return }
            collectionView.reloadData()
        }
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        commonInit()
    }
    
    private func commonInit() {
        title = String(localized: "Attributions")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        Task { @MainActor [weak self] in
            let loader = AttributionsLoader()
            self?.attributions = await loader.loadAttributions()
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.reloadData()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView.frame = view.bounds
    }
}

extension AttributionsViewController: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attributions.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueConfiguredReusableCell(using: configuration, for: indexPath, item: attributions[indexPath.row])
    }
}

extension AttributionsViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = AttributionViewController(attribution: attributions[indexPath.row])
        navigationController?.pushViewController(viewController, animated: true)
    }
}

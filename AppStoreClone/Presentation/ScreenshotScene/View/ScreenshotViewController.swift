//
//  ScreenshotViewController.swift
//  AppStoreClone
//
//  Created by Hyoju Son on 2022/08/09.
//

import Combine
import UIKit

final class ScreenshotViewController: UIViewController {
    // MARK: - Properties
    private let screenshotCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private var viewModel: ScreenshotViewModel!
    private var screenshotURLs = [String]()
    private let rightBarButtonDidTap = PassthroughSubject<Void, Never>()
    private var cancellableBag = Set<AnyCancellable>()
    
    // MARK: - Initializers
    convenience init(viewModel: ScreenshotViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    // MARK: - Lifecycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        bind()
    }

    // MARK: - Methods
    private func configureUI() {
        configureNavigationBar()
        configureHierarchy()
        configureCollectionView()
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.hidesBackButton = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: Text.rightBarButtonItemTitle,
            style: .done,
            target: self,
            action: #selector(confirmButtonDidTap)
        )
    }
    
    @objc
    private func confirmButtonDidTap() {
        rightBarButtonDidTap.send(())
    }
    
    private func configureHierarchy() {
        view.addSubview(screenshotCollectionView)
        
        NSLayoutConstraint.activate([
            screenshotCollectionView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16
            ),
            screenshotCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            screenshotCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            screenshotCollectionView.bottomAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12
            ),
        ])
    }
    
    private func configureCollectionView() {
        screenshotCollectionView.register(cellType: ScreenshotCell.self)
        screenshotCollectionView.dataSource = self
        screenshotCollectionView.collectionViewLayout = createCollectionViewLayout()
    }
    
    private func createCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ -> NSCollectionLayoutSection? in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let horizontalInset: CGFloat = 8
            item.contentInsets = NSDirectionalEdgeInsets(
                top: 0,
                leading: horizontalInset,
                bottom: 0,
                trailing: horizontalInset
            )
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.85),
                heightDimension: .fractionalHeight(0.9)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            
            return section
        }
        
        return layout
    }
}

// MARK: - Combine Binding Methods
extension ScreenshotViewController {
    private func bind() {
        let input = ScreenshotViewModel.Input(
            rightBarButtonDidTap: rightBarButtonDidTap.eraseToAnyPublisher()
        )

        guard let output = viewModel?.transform(input) else { return }

        configureCollectionView(with: output.screenshotURLsAndIndex)
    }
    
    private func configureCollectionView(with outputPublisher: AnyPublisher<([String], Int), Never>) {
        outputPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { [weak self] screenshotURLsAndIndex in
                let (screenshotURLs, currentIndex) = screenshotURLsAndIndex
                self?.screenshotURLs = screenshotURLs
                let currentSection = 0
                
                self?.screenshotCollectionView.reloadData()
                self?.screenshotCollectionView.scrollToItem(
                    at: IndexPath(item: currentIndex, section: currentSection),
                    at: .centeredVertically,
                    animated: false
                )
            })
            .store(in: &cancellableBag)
    }
}

// MARK: - CollectionView DataSource
extension ScreenshotViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return screenshotURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withClass: ScreenshotCell.self, for: indexPath)
        cell.apply(screenshotURL: screenshotURLs[indexPath.row])
        
        return cell
    }
}

// MARK: - NameSpaces
extension ScreenshotViewController {
    private enum Text {
        static let rightBarButtonItemTitle: String = "완료"
    }
}

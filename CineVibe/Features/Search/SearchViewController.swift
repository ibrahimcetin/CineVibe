//
//  SearchViewController.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import Combine
import SnapKit
import UIKit

final class SearchViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: SearchViewModel
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createCollectionViewLayout())
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)

        collectionView.delegate = self

        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Movie>!

    enum Section: CaseIterable {
        case searchResult
        case genAIResult
    }

    private lazy var searchTextField: UITextField = {
        let textField = UITextField()

        textField.placeholder = NSLocalizedString(
            "search.genai.placeholder",
            comment: "Placeholder text for AI movie search"
        )
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .search

        textField.leftViewMode = .always
        textField.rightViewMode = .unlessEditing
        textField.clearButtonMode = .whileEditing

        textField.delegate = self

        return textField
    }()

    private lazy var genAIToggle: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("AI", for: .normal)
        button.addTarget(self, action: #selector(toggleGenAI), for: .touchUpInside)
        return button
    }()

    private lazy var progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var isGenAIActive = true {
        didSet {
            updateSearchUIForCurrentMode()
        }
    }

    private func updateSearchUIForCurrentMode() {
        // Update button appearance
        genAIToggle.tintColor = isGenAIActive ? .systemBlue : .gray

        // Update placeholder text
        searchTextField.placeholder = isGenAIActive
            ? NSLocalizedString("search.genai.placeholder", comment: "Placeholder text for AI movie search")
            : NSLocalizedString("search.standard.placeholder", comment: "Placeholder text for standard movie search")

        // Update leading icon
        let iconName = isGenAIActive ? "text.page" : "magnifyingglass"
        let iconImageView = UIImageView(image: UIImage(systemName: iconName))
        iconImageView.tintColor = .gray
        searchTextField.leftView = iconImageView
    }

    private let defaultInset: CGFloat = 20
    private var bottomConstraint: Constraint?

    // MARK: - Initialization

    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        setupDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        registerForKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterForKeyboardNotifications()
    }

    // MARK: - Setup

    private func setupUI() {
        navigationItem.title = NSLocalizedString("search.title", comment: "Search screen title")

        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)
        view.addSubview(searchTextField)
        view.addSubview(progressIndicator)

        searchTextField.leftView = UIImageView(image: UIImage(systemName: "text.page"))
        searchTextField.leftView?.tintColor = .gray
        searchTextField.rightView = genAIToggle

        setupConstraints()
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(searchTextField.snp.top).offset(-defaultInset)
        }

        searchTextField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(defaultInset)
            bottomConstraint = make.bottom.equalTo(view.safeAreaLayoutGuide).inset(defaultInset).constraint
        }

        progressIndicator.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.searchResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let result else { return }

                var snapshot = NSDiffableDataSourceSnapshot<Section, Movie>()
                snapshot.appendSections(Section.allCases)

                switch result {
                case let .standard(movies):
                    snapshot.appendItems(movies, toSection: .searchResult)
                case let .genAI(movies):
                    snapshot.appendItems(movies, toSection: .genAIResult)
                }

                self?.dataSource.apply(snapshot)
            }
            .store(in: &cancellables)

        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.progressIndicator.startAnimating()
                } else {
                    self?.progressIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)

        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, movie in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MovieCell.reuseIdentifier,
                    for: indexPath
                ) as? MovieCell else {
                    fatalError("Cannot show movie cell")
                }

                cell.configure(with: movie)

                return cell
            }
        )
    }

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]

            return switch section {
            case .genAIResult:
                self.createGenAILayoutSection()
            case .searchResult:
                self.createSearchResultLayoutSection()
            }
        }
    }

    private func createGenAILayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.9),
                heightDimension: .fractionalWidth(1.35)
            ),
            subitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.interGroupSpacing = 10

        return section
    }

    private func createSearchResultLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )
        item.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(0.75)
            ),
            subitem: item,
            count: 2
        )

        let section = NSCollectionLayoutSection(group: group)

        return section
    }

    @objc private func toggleGenAI() {
        isGenAIActive = !isGenAIActive
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(
            title: NSLocalizedString("error.alert.title", comment: "Title for error alert"),
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let query = textField.text, !query.isEmpty else { return true }

        viewModel.search(query: query, isGenAIEnabled: isGenAIActive)

        textField.resignFirstResponder()

        return true
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }

        let movieDetails = MovieDetailsViewController(movie: movie)

        navigationController?.pushViewController(movieDetails, animated: true)

        searchTextField.resignFirstResponder()
    }
}

// MARK: - Keyboard Handling

extension SearchViewController {
    private func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func unregisterForKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = keyboardFrame(from: notification) else {
            return
        }

        let bottomInset = (keyboardFrame.height - view.safeAreaInsets.bottom) + defaultInset
        bottomConstraint?.update(inset: bottomInset)

        UIView.animate(withDuration: animationDuration(from: notification)) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        // Reset to default inset
        bottomConstraint?.update(inset: defaultInset)

        UIView.animate(withDuration: animationDuration(from: notification)) {
            self.view.layoutIfNeeded()
        }
    }

    private func keyboardFrame(from notification: Notification) -> CGRect? {
        notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
    }

    private func animationDuration(from notification: Notification) -> TimeInterval {
        notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController(
        viewModel: SearchViewModel(
            tmdbService: TMDBService(),
            genAIService: GenAIService()
        )
    )
}

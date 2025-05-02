//
//  HomeViewController.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 26.04.2025.
//

import Combine
import SnapKit
import UIKit

final class HomeViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: HomeViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: createCollectionViewLayout()
        )
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(CarouselCell.self, forCellWithReuseIdentifier: CarouselCell.reuseIdentifier)
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: MovieCell.reuseIdentifier)
        collectionView.register(
            HeaderView.self,
            forSupplementaryViewOfKind: HeaderView.elementKind,
            withReuseIdentifier: HeaderView.reuseIdentifier
        )

        collectionView.delegate = self

        return collectionView
    }()

    private var dataSource: UICollectionViewDiffableDataSource<Section, Movie>!

    enum Section: CaseIterable {
        case popular
        case nowPlaying
        case topRated
        case upcoming

        var rawValue: String {
            switch self {
            case .popular:
                NSLocalizedString("section.popular", comment: "Popular Movies section title")
            case .nowPlaying:
                NSLocalizedString("section.nowPlaying", comment: "Now Playing Movies section title")
            case .topRated:
                NSLocalizedString("section.topRated", comment: "Top Rated Movies section title")
            case .upcoming:
                NSLocalizedString("section.upcoming", comment: "Upcoming Movies section title")
            }
        }
    }

    // MARK: - Initialization

    init(viewModel: HomeViewModel) {
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
        viewModel.fetchMovies()
    }

    // MARK: - Setup

    private func setupUI() {
        navigationItem.title = "CineVibe"
        tabBarItem.title = NSLocalizedString("tab.home", comment: "Home tab title")

        view.backgroundColor = .systemBackground

        view.addSubview(collectionView)

        setupConstraints()
    }

    private func setupConstraints() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, movie in
                let section = Section.allCases[indexPath.section]

                switch section {
                case .popular:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: CarouselCell.reuseIdentifier,
                        for: indexPath
                    ) as? CarouselCell else {
                        fatalError("Cannot show carousel cell")
                    }

                    cell.configure(with: movie)

                    return cell
                default:
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: MovieCell.reuseIdentifier,
                        for: indexPath
                    ) as? MovieCell else {
                        fatalError("Cannot show movie cell")
                    }

                    cell.configure(with: movie)

                    return cell
                }
            }
        )

        dataSource.supplementaryViewProvider = { collectionView, _, indexPath in
            guard let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: HeaderView.elementKind,
                withReuseIdentifier: HeaderView.reuseIdentifier,
                for: indexPath
            ) as? HeaderView else {
                fatalError("Cannot show header")
            }

            let section = Section.allCases[indexPath.section]
            headerView.configure(with: section.rawValue)

            return headerView
        }
    }

    private func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section = Section.allCases[sectionIndex]

            return switch section {
            case .popular:
                self.createCarouselViewLayout()
            case .nowPlaying:
                self.createMovieLayout()
            case .topRated:
                self.createMovieLayout()
            case .upcoming:
                self.createMovieLayout()
            }
        }
    }

    private func createCarouselViewLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            ),
            elementKind: HeaderView.elementKind,
            alignment: .top
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.90),
                heightDimension: .fractionalWidth(2 / 3)
            ),
            subitem: item,
            count: 1
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)

        return section
    }

    private func createMovieLayout() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(120),
                heightDimension: .absolute(180)
            ),
            subitem: item,
            count: 1
        )

        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            ),
            elementKind: HeaderView.elementKind,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 0, leading: 10, bottom: 0, trailing: 10)

        return section
    }

    private func setupBindings() {
        // Bind movies to sections
        // Create a single snapshot for all sections
        let moviePublishers = [
            viewModel.$nowPlayingMovies.map { (Section.nowPlaying, $0) },
            viewModel.$popularMovies.map { (.popular, $0) },
            viewModel.$topRatedMovies.map { (.topRated, $0) },
            viewModel.$upcomingMovies.map { (.upcoming, $0) }
        ]

        // Combine all publishers to update the snapshot
        Publishers.MergeMany(moviePublishers)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] section, movies in
                guard let self else { return }

                var snapshot = dataSource.snapshot()

                // If section doesn't exist, append it
                if !snapshot.sectionIdentifiers.contains(section) {
                    snapshot.appendSections([section])
                }

                snapshot.appendItems(movies, toSection: section)

                dataSource.apply(snapshot, animatingDifferences: false)
            }
            .store(in: &cancellables)

        // Bind errors
        viewModel.$error
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    // MARK: - Helper Methods

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

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let movie = dataSource.itemIdentifier(for: indexPath) else { return }

        let movieDetails = MovieDetailsViewController(movie: movie)

        navigationController?.pushViewController(movieDetails, animated: true)
    }
}

@available(iOS 17.0, *)
#Preview {
    HomeViewController(viewModel: .init(tmdbService: TMDBService()))
}

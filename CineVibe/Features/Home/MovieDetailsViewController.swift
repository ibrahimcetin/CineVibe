//
//  MovieDetailsViewController.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import Kingfisher
import SnapKit
import UIKit

final class MovieDetailsViewController: UIViewController {
    // MARK: - Properties

    private var movie: Movie?

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()

    private lazy var contentView = UIView()

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .title2)
        label.numberOfLines = 2
        return label
    }()

    private lazy var infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        return stackView
    }()

    private lazy var releaseDateView: InfoView = {
        let view = InfoView()
        view.icon = UIImage(systemName: "calendar")
        return view
    }()

    private lazy var ratingView: InfoView = {
        let view = InfoView()
        view.icon = UIImage(systemName: "star")
        return view
    }()

    private lazy var languageView: InfoView = {
        let view = InfoView()
        view.icon = UIImage(systemName: "globe")
        return view
    }()

    private lazy var overviewCard: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.layer.cornerCurve = .continuous
        return view
    }()

    private lazy var overviewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Overview"
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .headline)
        return label
    }()

    private lazy var overviewLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Initialization

    init(movie: Movie? = nil) {
        self.movie = movie
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
        configure(with: movie)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never

        // Add scroll view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add poster image
        contentView.addSubview(posterImageView)

        // Add title
        contentView.addSubview(titleLabel)

        // Add info stack
        contentView.addSubview(infoStackView)
        infoStackView.addArrangedSubview(releaseDateView)
        infoStackView.addArrangedSubview(ratingView)
        infoStackView.addArrangedSubview(languageView)

        // Add overview card
        contentView.addSubview(overviewCard)
        overviewCard.addSubview(overviewTitleLabel)
        overviewCard.addSubview(overviewLabel)

        setupConstraints()
    }

    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }

        posterImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(300)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(posterImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        infoStackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        overviewCard.snp.makeConstraints { make in
            make.top.equalTo(infoStackView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
        }

        overviewTitleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        overviewLabel.snp.makeConstraints { make in
            make.top.equalTo(overviewTitleLabel.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    // MARK: - Configuration

    func configure(with movie: Movie?) {
        guard let movie else { return }

        titleLabel.text = movie.title
        releaseDateView.text = movie.releaseDateFormatted
        ratingView.text = String(format: "%.1f", movie.voteAverage)
        languageView.text = movie.originalLanguage.uppercased()
        overviewLabel.text = movie.overview

        if let posterURL = movie.posterURL {
            posterImageView.kf.setImage(
                with: posterURL,
                placeholder: UIImage(systemName: "popcorn"),
                options: [.cacheOriginalImage]
            )
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    MovieDetailsViewController(movie: .sampleMovies.first!)
}

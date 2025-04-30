//
//  CarouselCell.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 28.04.2025.
//

import Kingfisher
import SnapKit
import UIKit

final class CarouselCell: UICollectionViewCell {
    // MARK: - Properties

    static let reuseIdentifier = "CarouselCell"

    // MARK: - UI Components

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.tintColor = .label
        return imageView
    }()

    private lazy var gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor.black.withAlphaComponent(0.0).cgColor,
            UIColor.black.withAlphaComponent(0.5).cgColor
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradient
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()

        label.textColor = .white
        label.font = .preferredFont(forTextStyle: .title3)
        label.numberOfLines = 2

        // Add shadow
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.shadowRadius = 2
        label.layer.shadowOpacity = 0.7

        return label
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        contentView.addSubview(posterImageView)
        posterImageView.layer.addSublayer(gradientLayer)
        posterImageView.addSubview(titleLabel)

        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.trailing.equalTo(posterImageView.snp.centerX)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = posterImageView.bounds
    }

    // MARK: - Configuration

    func configure(with movie: Movie) {
        titleLabel.text = movie.title

        if let imageURL = movie.backdropURL ?? movie.posterURL {
            posterImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "popcorn"),
                options: [.cacheOriginalImage],
                completionHandler: { [weak self] result in
                    if case .success = result {
                        self?.posterImageView.contentMode = .scaleAspectFill
                    }
                }
            )
        } else {
            posterImageView.image = UIImage(systemName: "popcorn")
        }
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
        posterImageView.contentMode = .scaleAspectFit
        titleLabel.text = nil
    }
}

@available(iOS 17.0, *)
#Preview {
    let cell = CarouselCell()
    cell.configure(with: .sampleMovies.first!)

    return cell
}

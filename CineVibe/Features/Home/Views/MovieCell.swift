//
//  MovieCell.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import Kingfisher
import SnapKit
import UIKit

final class MovieCell: UICollectionViewCell {
    static let reuseIdentifier = "MovieCell"

    private lazy var posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.cornerCurve = .continuous
        imageView.tintColor = .label
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    private func setupUI() {
        contentView.addSubview(posterImageView)

        posterImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with movie: Movie) {
        if let imageURL = movie.posterURL {
            posterImageView.kf.setImage(
                with: imageURL,
                placeholder: UIImage(systemName: "popcorn"),
                options: [.cacheOriginalImage]
            )
        } else {
            posterImageView.image = UIImage(systemName: "popcorn")
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        posterImageView.kf.cancelDownloadTask()
        posterImageView.image = nil
    }
}

@available(iOS 17.0, *)
#Preview(traits: .fixedLayout(width: 120, height: 180)) {
    let cell = MovieCell()
    cell.configure(with: .sampleMovies.first!)

    return cell
}

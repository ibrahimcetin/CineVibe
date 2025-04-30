//
//  InfoView.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 30.04.2025.
//

import SnapKit
import UIKit

final class InfoView: UIView {
    // MARK: - Properties

    var icon: UIImage? {
        didSet {
            iconImageView.image = icon
        }
    }

    var text: String? {
        didSet {
            textLabel.text = text
        }
    }

    // MARK: - UI Components

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .preferredFont(forTextStyle: .body)
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
        addSubview(iconImageView)
        addSubview(textLabel)

        iconImageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        iconImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
        }

        textLabel.snp.makeConstraints { make in
            make.leading.equalTo(iconImageView.snp.trailing).offset(4)
            make.trailing.centerY.equalToSuperview()
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let infoView = InfoView()
    infoView.icon = .init(systemName: "star")
    infoView.text = "4.5/5"
    return infoView
}

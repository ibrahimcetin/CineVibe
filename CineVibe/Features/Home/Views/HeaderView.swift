//
//  HeaderView.swift
//  CineVibe
//
//  Created by İbrahim Çetin on 29.04.2025.
//

import SnapKit
import UIKit

final class HeaderView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderView"
    static let elementKind = "header"

    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        addSubview(label)

        label.font = .preferredFont(forTextStyle: .headline)

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }

    func configure(with text: String) {
        label.text = text
    }
}

@available(iOS 17.0, *)
#Preview {
    let header = HeaderView()
    header.configure(with: "Popular Movies")

    return header
}

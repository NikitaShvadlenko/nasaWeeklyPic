//
//  PicCell.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.08.2021.
//

import UIKit
import SnapKit
import Moya

class PicCell: UITableViewCell {
    
    private lazy var nasaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var aspectRatioConstraint: NSLayoutConstraint?
    
    private lazy var activityIndicator = UIActivityIndicatorView()
    
    private lazy var activityIndicatorContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .green
        view.isHidden = true
        return view
    }()
    
    private let imageProvider = MoyaProvider<NASAImageRoute>()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setActivityIndicatorHidden(true)
        nasaImageView.image = nil
        aspectRatioConstraint?.isActive = false
        aspectRatioConstraint = nil
    }
    
    func configure(model: ApodModel) {
        loadImage(url: model.url)
    }
}

private extension PicCell {
    func setupView() {
        contentView.addSubview(nasaImageView)
        contentView.addSubview(activityIndicatorContainer)
        activityIndicatorContainer.addSubview(activityIndicator)
        nasaImageView.snp.makeConstraints { (make: ConstraintMaker) in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(4)
            make.height.greaterThanOrEqualTo(10)
        }
        
        activityIndicatorContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func loadImage(url: URL) {
        // TODO: show loading indicator here
        setActivityIndicatorHidden(false)
        imageProvider.request(.image(url: url)) { [weak self] result in
            guard let self = self else { return }
            // TODO: hide loading indicator here, as by this moment image loading has finished
            self.setActivityIndicatorHidden(true)
            switch result {
            case let .success(response):
                do {
                    let image = try response.mapImage()
                    let aspectRatio = image.size.height / image.size.width
                    self.aspectRatioConstraint = self.nasaImageView.heightAnchor.constraint(equalTo: self.nasaImageView.widthAnchor, multiplier: aspectRatio)
                    self.aspectRatioConstraint?.isActive = true
                    self.nasaImageView.image = image
                } catch {
                    print(error)
                }
                
            case let .failure(error):
                print(error)
            }
        }
    }
    
    func setActivityIndicatorHidden(_ hidden: Bool) {
        activityIndicatorContainer.isHidden = hidden
        if hidden {
            activityIndicator.stopAnimating()
        } else {
            activityIndicator.startAnimating()
        }
    }
}

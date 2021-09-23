//
//  PicCell.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.08.2021.
//

import UIKit
import SnapKit
import Moya

let cacheProvider = CacheProvider()

protocol PicCellDelegate: AnyObject {
    func picCell(_ picCell: PicCell, needsUpdateWith closure: () -> Void)
}

class PicCell: UITableViewCell {
    private lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.backgroundColor = .black
        return dateLabel
    }()
    private lazy var nasaImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var aspectRatioConstraint: NSLayoutConstraint? {
        didSet {
            if let oldConstraint = oldValue {
                nasaImageView.removeConstraint(oldConstraint)
            }
            
            if let newConstraint = aspectRatioConstraint {
                newConstraint.isActive = true
            }
        }
    }
    
    private lazy var activityIndicator = UIActivityIndicatorView()
    
    private lazy var activityIndicatorContainer: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .gray
        view.isHidden = true
        return view
    }()
    
    private let imageProvider = MoyaProvider<NASAImageRoute>()
    
    private weak var delegate: PicCellDelegate?
    
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
        aspectRatioConstraint = nil
    }
    
    func configure(model: ApodModel, delegate: PicCellDelegate?) {
        self.delegate = delegate
        loadImage(url: model.url)
    }
}

private extension PicCell {
    func setupView() {
        contentView.addSubview(nasaImageView)
        contentView.addSubview(activityIndicatorContainer)
        activityIndicatorContainer.addSubview(activityIndicator)
        nasaImageView.snp.makeConstraints { (make: ConstraintMaker) in
            make.leading.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().offset(4)
            make.bottom.equalToSuperview().inset(4).priority(.high)
            make.height.greaterThanOrEqualTo(30)
        }
        
        activityIndicatorContainer.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(nasaImageView)
        }
        
      /*  activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        } - Это одни и те же констрейнтсы прописанные дважды?*/
    }
    
    func loadImage(url: URL) {
        if let imageData = cacheProvider.retrieve(key: url.absoluteString) {
            //ТУТ НЕ IMAGE DATA должно быть
            let image = UIImage(data: imageData)
            nasaImageView.image = image
            print("retrieved")
            return
        }
        // TODO: show loading indicator here
        setActivityIndicatorHidden(false)
        imageProvider.request(.image(url: url)) { [weak self] result in
            guard let self = self else { return }
            // TODO: hide loading indicator here, as by this moment image loading has finished
            self.setActivityIndicatorHidden(true)
            switch result {
            case let .success(response):
                do {
                    cacheProvider.save(key: url.absoluteString, value: response.data)
                    print("Saved to cache")
                    let image = try response.mapImage()
                    self.delegate?.picCell(self, needsUpdateWith: { [weak self] in
                        guard let self = self else { return }
                        let aspectRatio = image.size.height / image.size.width
                        let aspectRatioConstraint = self.nasaImageView.heightAnchor.constraint(equalTo:
                        //возможно, ошибка вот тут. Будто не хватает одного шага. 
                        self.nasaImageView.widthAnchor, multiplier: aspectRatio)
                        self.aspectRatioConstraint = aspectRatioConstraint
                        self.nasaImageView.image = image
                    })
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

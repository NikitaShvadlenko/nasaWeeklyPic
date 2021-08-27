//
//  ViewController.swift
//  nasaWeeklyPic
//
//  Created by Nikita Shvad on 24.08.2021.
//
import Moya
import UIKit
import SnapKit

class ViewController: UIViewController {
 
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.register(PicCell.self, forCellReuseIdentifier: "\(PicCell.self)")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 100
        return tableView
    }()
    
    private let nasaProvider = MoyaProvider<OpenNasaRoute>()
    
    var apodModels: [ApodModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchData()
    }
}

// MARK: - Private methods
private extension ViewController {
    func setupView() {
        navigationController?.tabBarItem.image = UIImage(systemName: "list.bullet")
        title = "List"
        view.backgroundColor = .white
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func fetchData() {
        nasaProvider.request(.apod(startDateString: "2021-08-20", endDateString: "2021-08-27")) { [weak self] result in
            switch result {
            case let .success(response):
                do {
                    let apodModels = try response.map([ApodModel].self)
                    self?.apodModels = apodModels
                    self?.tableView.reloadData()
                } catch {
                    print(error)
                }
                
                
            case .failure(let error):
               print (error)
                break
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apodModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(PicCell.self)", for: indexPath) as? PicCell
        
        let model = apodModels[indexPath.row]
        cell?.configure(model: model, delegate: self)
        
        guard let safeCell = cell else {
            fatalError("Can not deque Cell")
        }
        return safeCell
    }
    
}

// MARK: - PicCellDelegate
extension ViewController: PicCellDelegate {
    func picCell(_ picCell: PicCell, needsUpdateWith closure: () -> Void) {
        tableView.beginUpdates()
        closure()
        tableView.endUpdates()
    }
}

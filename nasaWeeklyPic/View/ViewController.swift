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
        tableView.backgroundColor = .blue
        tableView.dataSource = self
        tableView.register(PicCell.self, forCellReuseIdentifier: "\(PicCell.self)")
        tableView.rowHeight = UITableView.automaticDimension
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

private extension ViewController {
    func setupView() {
        tabBarItem.image = UIImage(systemName: "list.bullet")
        title = "List"
        view.backgroundColor = .red
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func fetchData() {
        nasaProvider.request(.apod(count: 2)) { [weak self] result in
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
                break
            }
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apodModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "\(PicCell.self)", for: indexPath) as? PicCell
        
        let model = apodModels[indexPath.row]
        cell?.configure(model: model)
        
        guard let safeCell = cell else {
            fatalError("Can not deque Cell")
        }
        return safeCell
    }
    
}


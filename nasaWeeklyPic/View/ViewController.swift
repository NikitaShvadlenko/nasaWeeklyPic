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
    
    let cacheProvider = CacheProvider()
    
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    let calendar = Calendar.current
    var requestedNewDataCount = 1
    
    private lazy var currentDateString: String = {return dateFormatter.string(from: calendar.date(byAdding: .day, value: -1, to: Date())!)}()
    
    private lazy var lastWeekDateString: String = {
        return dateFormatter.string(from: calendar.date(byAdding: .weekOfYear, value: -1, to: Date())! )}()

    var fetchingMoreData = false

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
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
        nasaProvider.request(.apod(startDateString: lastWeekDateString, endDateString: currentDateString)) { [weak self] result in
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
    func getNewDates()  {
        requestedNewDataCount += 1
        var lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1, to: Date())!
        let currentDate = lastWeekDate
        lastWeekDate = calendar.date(byAdding: .weekOfYear, value: -1 * requestedNewDataCount, to: Date())!
         currentDateString = (dateFormatter.string(from: currentDate))
         lastWeekDateString = (dateFormatter.string(from: lastWeekDate))
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        apodModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Согласно сообщению, я проверку кэша должен написать вот сюда, но тут нет Data, тут только модель.  Зачем во вью контроллер создавать Кэш провайдер? Можно же просто в сетапе ячейки, но не тут. 
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

//MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        print(offsetY)
        print(contentHeight)
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMoreData {
                fetchMoreData()
            }
        }
        func fetchMoreData() {
            fetchingMoreData = true
            print("Aked for more data")
            getNewDates()
            fetchData()
            fetchingMoreData = false
        }
    }
}

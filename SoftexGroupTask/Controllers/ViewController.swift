//
//  ViewController.swift
//  SoftexGroupTask
//
//  Created by Ivan on 17/05/2019.
//  Copyright © 2019 Ivan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

class ViewController: UIViewController {

    private let tableView = UITableView()
    private let cellIdentifier = "cellIdentifier"
    private let apiClient = APIClient()
    private let bag = DisposeBag()
    private let countries = BehaviorRelay<[Country]>(value: [])
    private lazy var countriesFileURL = cachedFileURL("countries.json")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProperties()
        setupLayout()
        
        let decoder = JSONDecoder()
        if let countriesData = try? Data(contentsOf: countriesFileURL),
            let persistedCountries = try? decoder.decode([Country].self, from:
                countriesData) {
            countries.accept(persistedCountries)
        }
        
        bindings()
        refresh()
    }
    
    private func setupProperties() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        navigationItem.title = "Cities"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        
        self.tableView.refreshControl = UIRefreshControl()
        let refreshControl = self.tableView.refreshControl!
        
        refreshControl.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        refreshControl.tintColor = UIColor.darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }
    
    private func setupLayout() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        tableView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    private func bindings() {
        tableView.rx.itemDeleted
            .subscribe(onNext: { [weak self] item in
                var countries = self?.countries.value
                countries?.remove(at: item.row)
                self?.countries.accept(countries!)
            }).disposed(by: bag)
        
        countries.bind(to: tableView.rx.items(cellIdentifier: "cellIdentifier")) { row, country, cell in
            cell.textLabel?.text = country.name
            cell.detailTextLabel?.text = country.time
            cell.imageView?.kf.setImage(with: URL(string: country.image ?? ""), placeholder: UIImage(named: "blank-avatar"))
            }.disposed(by: bag)
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self else { return }
            self.fetchCountries()
        }
    }
    
    func cachedFileURL(_ fileName: String) -> URL {
        return FileManager.default
            .urls(for: .cachesDirectory, in: .allDomainsMask)
            .first!
            .appendingPathComponent(fileName)
    }
    
    func fetchCountries() {
        Observable.of("")
            .map { _ in CountryRequest() }
            .flatMap { request -> Observable<[Country]> in
                return self.apiClient.send(apiRequest: request)
            }            .filter { objects in
                return !objects.isEmpty
            }
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] newCountries in
                self?.processCountries(newCountries)
            })
            .disposed(by: bag)
    }
    
    func processCountries(_ newCountries: [Country]) {
        let updatedCountries = newCountries + countries.value
        countries.accept(updatedCountries)
        
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        
        let encoder = JSONEncoder()
        if let countriesData = try? encoder.encode(updatedCountries) {
            try? countriesData.write(to: countriesFileURL, options: .atomicWrite)
        }
    }
}


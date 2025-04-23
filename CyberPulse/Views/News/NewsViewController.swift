import UIKit
import Combine

class NewsViewController: UIViewController {
    private var viewModel: NewsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(NewsCell.self, forCellReuseIdentifier: NewsCell.identifier)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.showsVerticalScrollIndicator = false
        
        // Add refresh control
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .systemCyan
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        table.refreshControl = refreshControl
        
        return table
    }()
    
    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchBar.placeholder = "Search cybersecurity news..."
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.tintColor = .systemCyan
        controller.searchBar.searchTextField.textColor = .white
        controller.searchBar.searchTextField.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.3)
        return controller
    }()
    
    private lazy var severityFilterButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"),
                                   style: .plain,
                                   target: self,
                                   action: #selector(showSeverityFilter))
        button.tintColor = .systemCyan
        return button
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .systemCyan
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    init(viewModel: NewsViewModel = NewsViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        viewModel.fetchNews()
    }
    
    private func setupUI() {
        title = "Cybersecurity News"
        view.backgroundColor = .clear
        
        navigationItem.searchController = searchController
        navigationItem.rightBarButtonItem = severityFilterButton
        
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupBindings() {
        viewModel.$newsItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc private func refreshData() {
        viewModel.fetchNews()
    }
    
    @objc private func showSeverityFilter() {
        let alert = UIAlertController(title: "Filter by Severity",
                                    message: nil,
                                    preferredStyle: .actionSheet)
        
        NewsSeverity.allCases.forEach { severity in
            let action = UIAlertAction(title: severity.rawValue.capitalized, style: .default) { [weak self] _ in
                self?.viewModel.filterBySeverity(severity)
            }
            action.setValue(severity.color, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        if let popoverController = alert.popoverPresentationController {
            popoverController.barButtonItem = severityFilterButton
        }
        
        present(alert, animated: true)
    }
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.newsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCell.identifier, for: indexPath) as? NewsCell else {
            return UITableViewCell()
        }
        
        let newsItem = viewModel.newsItems[indexPath.row]
        cell.configure(with: newsItem)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let newsItem = viewModel.newsItems[indexPath.row]
        let detailVC = NewsDetailViewController(newsItem: newsItem)
        navigationController?.pushViewController(detailVC, animated: true)
    }
} 
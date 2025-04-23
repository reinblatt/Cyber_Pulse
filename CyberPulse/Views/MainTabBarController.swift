import UIKit

class MainTabBarController: UITabBarController {
    private let backgroundView = BackgroundImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViewControllers()
        setupAppearance()
    }
    
    private func setupBackground() {
        view.insertSubview(backgroundView, at: 0)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupViewControllers() {
        let newsVC = NewsViewController()
        let podcastsVC = PodcastsViewController()
        let blogsVC = BlogsViewController()
        
        newsVC.tabBarItem = UITabBarItem(title: "News", image: UIImage(systemName: "newspaper"), tag: 0)
        podcastsVC.tabBarItem = UITabBarItem(title: "Podcasts", image: UIImage(systemName: "headphones"), tag: 1)
        blogsVC.tabBarItem = UITabBarItem(title: "Blogs", image: UIImage(systemName: "doc.text"), tag: 2)
        
        let controllers = [newsVC, podcastsVC, blogsVC].map { UINavigationController(rootViewController: $0) }
        controllers.forEach { configureNavigationBar($0) }
        
        viewControllers = controllers
    }
    
    private func setupAppearance() {
        // Configure tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithTransparentBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemCyan]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .systemCyan
        
        tabBar.standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = tabBarAppearance
        }
        
        // Add blur effect
        tabBar.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
    }
    
    private func configureNavigationBar(_ navigationController: UINavigationController) {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithTransparentBackground()
        navigationBarAppearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController.navigationBar.standardAppearance = navigationBarAppearance
        navigationController.navigationBar.compactAppearance = navigationBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        navigationController.navigationBar.tintColor = .systemCyan
        navigationController.navigationBar.prefersLargeTitles = true
    }
} 
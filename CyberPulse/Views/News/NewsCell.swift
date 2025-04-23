import UIKit
import SDWebImage

class NewsCell: UITableViewCell {
    static let identifier = "NewsCell"
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.7)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = 2
        label.textColor = .white
        return label
    }()
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .systemCyan
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .systemGray
        return label
    }()
    
    private let severityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        return view
    }()
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.systemCyan.cgColor
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(blurView)
        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(sourceLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(severityView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            blurView.topAnchor.constraint(equalTo: containerView.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            thumbnailImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            thumbnailImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 80),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 80),
            
            titleLabel.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            sourceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            sourceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            
            dateLabel.leadingAnchor.constraint(equalTo: sourceLabel.trailingAnchor, constant: 8),
            dateLabel.centerYAnchor.constraint(equalTo: sourceLabel.centerYAnchor),
            
            severityView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            severityView.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 8),
            severityView.widthAnchor.constraint(equalToConstant: 8),
            severityView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(with newsItem: NewsItem) {
        titleLabel.text = newsItem.title
        sourceLabel.text = newsItem.source
        dateLabel.text = newsItem.date.formatted(date: .abbreviated, time: .shortened)
        
        if let imageURL = newsItem.imageURL {
            thumbnailImageView.sd_setImage(with: imageURL, placeholderImage: UIImage(systemName: "newspaper"))
        } else {
            thumbnailImageView.image = UIImage(systemName: "newspaper")
            thumbnailImageView.tintColor = .systemCyan
        }
        
        severityView.backgroundColor = newsItem.severity.color
        
        // Add glow effect to severity indicator
        severityView.layer.shadowColor = newsItem.severity.color.cgColor
        severityView.layer.shadowOffset = .zero
        severityView.layer.shadowRadius = 4
        severityView.layer.shadowOpacity = 0.8
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        thumbnailImageView.layer.borderColor = UIColor.systemCyan.cgColor
    }
} 
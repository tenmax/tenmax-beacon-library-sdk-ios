import UIKit

class CongratulationsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let messageLabel = UILabel()
    private let dataLabel = UILabel()
    private let creativeLabel = UILabel()

    private let deeplink: String?
    private let creativeId: Int

    init(deeplink: String? = nil, creativeId: Int = 0) {
        self.deeplink = deeplink
        self.creativeId = creativeId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.deeplink = nil
        self.creativeId = 0
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupNavigationBar()
        setupScrollView()
        setupLabels()
        layoutUI()
    }
    
    private func setupNavigationBar() {
        title = "恭喜你成功串接 TenMax Beacon SDK"

        let customBackButton = CustomBackButton()
        customBackButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)

        let backButtonItem = UIBarButtonItem(customView: customBackButton)
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func setupLabels() {
        messageLabel.text = "當您看到這一頁，代表您已成功串接 TenMax Beacon SDK，實現推動虛實整合廣告體驗的重要一步！"
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageLabel.textColor = .black
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        dataLabel.text = "Data: \(deeplink ?? "N/A")"
        dataLabel.font = UIFont.systemFont(ofSize: 14)
        dataLabel.textColor = .darkGray
        dataLabel.textAlignment = .center
        dataLabel.numberOfLines = 0
        dataLabel.translatesAutoresizingMaskIntoConstraints = false

        creativeLabel.text = "Creative ID: \(creativeId)"
        creativeLabel.font = UIFont.systemFont(ofSize: 14)
        creativeLabel.textColor = .darkGray
        creativeLabel.textAlignment = .center
        creativeLabel.numberOfLines = 0
        creativeLabel.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(messageLabel)
        contentView.addSubview(dataLabel)
        contentView.addSubview(creativeLabel)
    }
    
    private func layoutUI() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            dataLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            dataLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dataLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            creativeLabel.topAnchor.constraint(equalTo: dataLabel.bottomAnchor, constant: 10),
            creativeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            creativeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
        ])
    }
    
    @objc private func backButtonTapped() {
        if let navController = navigationController {
            for viewController in navController.viewControllers {
                if viewController is MainPageViewController {
                    navController.popToViewController(viewController, animated: true)
                    return
                }
            }
        }
        navigationController?.popViewController(animated: true)
    }
}

private class CustomBackButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        if #available(iOS 13.0, *) {
            setImage(UIImage(systemName: "chevron.left"), for: .normal)
        } else {
            setTitle("‹", for: .normal)
            titleLabel?.font = UIFont.systemFont(ofSize: 18)
        }

        tintColor = .white

        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: 44),
            heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -10, dy: -10)
        return expandedBounds.contains(point)
    }
}

import UIKit
import CoreLocation
import UserNotifications
import AppTrackingTransparency
import AdSupport

class MainPageViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileContainerView = UIView()
    private let phoneTextField = UITextField()
    private let emailTextField = UITextField()
    private let submitButton = UIButton(type: .system)

    private let titleLabel1 = UILabel()
    private let contentLabel1 = UITextView()
    private let titleLabel2 = UILabel()
    private let contentLabel2 = UITextView()
    private let titleLabel3 = UILabel()
    private let contentLabel3 = UITextView()

    private let permissionManager = PermissionManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupNavigationBar()
        setupScrollView()
        setupProfileSection()
        setupLabels()
        setupPermissionManager()

        layoutUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        updateNavigationTitle()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        updateNavigationTitle()
        permissionManager.requestAllPermissions()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    private func setupProfileSection() {
        profileContainerView.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        profileContainerView.layer.cornerRadius = 8
        profileContainerView.translatesAutoresizingMaskIntoConstraints = false

        phoneTextField.placeholder = "請輸入手機號碼"
        phoneTextField.borderStyle = .none
        phoneTextField.backgroundColor = .white
        phoneTextField.textColor = .black
        phoneTextField.font = UIFont.systemFont(ofSize: 16)
        phoneTextField.layer.cornerRadius = 8
        phoneTextField.layer.borderWidth = 1
        phoneTextField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        phoneTextField.layer.shadowColor = UIColor.black.cgColor
        phoneTextField.layer.shadowOffset = CGSize(width: 0, height: 1)
        phoneTextField.layer.shadowOpacity = 0.1
        phoneTextField.layer.shadowRadius = 2
        phoneTextField.keyboardType = .phonePad
        phoneTextField.translatesAutoresizingMaskIntoConstraints = false

        phoneTextField.attributedPlaceholder = NSAttributedString(
            string: "請輸入手機號碼",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )

        let phoneLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        phoneTextField.leftView = phoneLeftView
        phoneTextField.leftViewMode = .always

        emailTextField.placeholder = "請輸入 Email"
        emailTextField.borderStyle = .none
        emailTextField.backgroundColor = .white
        emailTextField.textColor = .black
        emailTextField.font = UIFont.systemFont(ofSize: 16)
        emailTextField.layer.cornerRadius = 8
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
        emailTextField.layer.shadowColor = UIColor.black.cgColor
        emailTextField.layer.shadowOffset = CGSize(width: 0, height: 1)
        emailTextField.layer.shadowOpacity = 0.1
        emailTextField.layer.shadowRadius = 2
        emailTextField.keyboardType = .emailAddress
        emailTextField.autocapitalizationType = .none
        emailTextField.translatesAutoresizingMaskIntoConstraints = false

        emailTextField.attributedPlaceholder = NSAttributedString(
            string: "請輸入 Email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray]
        )

        let emailLeftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 44))
        emailTextField.leftView = emailLeftView
        emailTextField.leftViewMode = .always

        submitButton.setTitle("更新資料", for: .normal)
        submitButton.backgroundColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 8
        submitButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        submitButton.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)

        contentView.addSubview(profileContainerView)
        profileContainerView.addSubview(phoneTextField)
        profileContainerView.addSubview(emailTextField)
        profileContainerView.addSubview(submitButton)

        NSLayoutConstraint.activate([
            phoneTextField.topAnchor.constraint(equalTo: profileContainerView.topAnchor, constant: 16),
            phoneTextField.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            phoneTextField.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            phoneTextField.heightAnchor.constraint(equalToConstant: 44),

            emailTextField.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 12),
            emailTextField.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),

            submitButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 16),
            submitButton.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor, constant: 16),
            submitButton.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor, constant: -16),
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            submitButton.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: -16)
        ])
    }

    @objc private func submitButtonTapped() {
        let phoneNumber = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)

        let finalPhoneNumber = phoneNumber?.isEmpty == true ? nil : phoneNumber
        let finalEmail = email?.isEmpty == true ? nil : email

        AppBeaconManager.shared.updateClientInfo(phoneNumber: finalPhoneNumber, email: finalEmail)

        let alert = UIAlertController(title: "更新成功", message: "客戶資料已更新", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)

        view.endEditing(true)
    }

    private func setupLabels() {
        titleLabel1.text = "TenMax Beacon SDK 簡介"
        titleLabel1.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel1.numberOfLines = 0
        titleLabel1.translatesAutoresizingMaskIntoConstraints = false

        titleLabel2.text = "TenMax Beacon SDK 會取得的資料"
        titleLabel2.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel2.numberOfLines = 0
        titleLabel2.translatesAutoresizingMaskIntoConstraints = false

        titleLabel3.text = "TenMax Beacon SDK 具體的行為"
        titleLabel3.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel3.numberOfLines = 0
        titleLabel3.translatesAutoresizingMaskIntoConstraints = false

        setupTextView(contentLabel1, withText: """
TenMax Beacon SDK 為了協助企業主做到虛實整合的效果，讓企業主投遞 Outdoor 戶外廣告時，能與使用者的行動裝置產生即時互動。

整合 TenMax Beacon SDK 至 App 後，當 APP 使用者靠近設有 Outdoor 戶外廣告設備，且廣告播放指定內容時，若使用者的 App 正於背景執行，即可根據 Outdoor 戶外廣告播放的指定廣告素材觸發對應的推播訊息，進一步提升互動機會，打造虛實整合的互動體驗。
""")

        setupTextView(contentLabel2, withText: """
TenMax Beacon SDK 在整合至企業主的 App 後，會依據使用情境與使用者授權，取得以下幾項裝置資訊，以實現虛實整合的推播互動功能：

1. 裝置系統類型（platform）：識別使用者所使用的行動系統為 iOS 或 Android，為必要欄位。
2. App 名稱（appName）：取得目前執行中的應用程式名稱，作為來源識別之用，為必要欄位。
3. 手機型號（deviceMode）：用於了解使用者裝置規格，例如 iPhone 14 Pro、Samsung Galaxy S21 等，為必要欄位。
4. 裝置識別碼（deviceId）：包含 iOS 的 IDFA 或 Android 的 ADID，這是用於廣告識別與追蹤的欄位。此欄位非必填，但若可取得，能協助提升廣告追蹤與投遞精準度。
5. 使用者電話號碼（phoneNumber）：此欄位僅在使用者授權同意的前提下才會被蒐集，非必填。
6. 使用者 Email（email）：此欄位僅在使用者授權同意的前提下才會被蒐集，非必填。

其中 `deviceId`、`phoneNumber` 及 `email` 為選填欄位，可依企業實際需求與隱私政策選擇是否提供。若未提供這些資料，SDK 核心功能仍可正常運作，不會影響推播互動的基本流程。

輸入後可以讓 TenMax 開發者確認可以正確收到 email 、手機號碼
""")

        setupTextView(contentLabel3, withText: """
TenMax Beacon SDK 僅針對 TenMax AD Player 的藍牙訊號進行被動掃描，其監控行為包含以下幾點：

1. 啟用藍牙掃描功能

    當 APP 使用者裝置開啟系統藍牙功能，SDK 將啟動藍牙掃描行為，用於識別指定的藍牙訊號。

2. 接收 TenMax AD Player 的藍牙訊號

    SDK 會被動接收來自 TenMax AD Player 的藍牙訊號，其中包含三組識別資訊：

    -  公司識別碼 ( Company ID )

    - 廣告空間 ( Space ID )

    - 素材 ( Creative ID )

    這些訊息皆為公開廣播內容，並非裝置私有資訊。
""")

        contentView.addSubview(titleLabel1)
        contentView.addSubview(contentLabel1)
        contentView.addSubview(titleLabel2)
        contentView.addSubview(contentLabel2)
        contentView.addSubview(titleLabel3)
        contentView.addSubview(contentLabel3)
    }

    private func setupTextView(_ textView: UITextView, withText text: String) {
        textView.text = text
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.dataDetectorTypes = []
        textView.textAlignment = .left

        // 設定內容壓縮阻力和內容擁抱優先級
        textView.setContentCompressionResistancePriority(.required, for: .vertical)
        textView.setContentHuggingPriority(.required, for: .vertical)
    }

    private func layoutUI() {
        NSLayoutConstraint.activate([
            titleLabel1.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
            titleLabel1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            contentLabel1.topAnchor.constraint(equalTo: titleLabel1.bottomAnchor, constant: 10),
            contentLabel1.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentLabel1.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            titleLabel2.topAnchor.constraint(equalTo: contentLabel1.bottomAnchor, constant: 30),
            titleLabel2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            contentLabel2.topAnchor.constraint(equalTo: titleLabel2.bottomAnchor, constant: 10),
            contentLabel2.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentLabel2.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            profileContainerView.topAnchor.constraint(equalTo: contentLabel2.bottomAnchor, constant: 20),
            profileContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            profileContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            titleLabel3.topAnchor.constraint(equalTo: profileContainerView.bottomAnchor, constant: 30),
            titleLabel3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            contentLabel3.topAnchor.constraint(equalTo: titleLabel3.bottomAnchor, constant: 10),
            contentLabel3.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            contentLabel3.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            contentLabel3.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30)
        ])
    }

    private func setupNavigationBar() {
        title = "TenMax Beacon SDK"

        if let navigationBar = navigationController?.navigationBar {
            navigationBar.prefersLargeTitles = false
            navigationBar.isTranslucent = false
            navigationBar.barTintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
            navigationBar.tintColor = .white
            navigationBar.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor: UIColor.white,
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)
            ]
        }
    }

    private func updateNavigationTitle() {
        if title == nil || title?.isEmpty == true {
            title = "TenMax Beacon SDK"
        }

        navigationController?.navigationBar.setNeedsLayout()
    }

    private func setupPermissionManager() {
        permissionManager.delegate = self
    }



    private func log(_ message: String) {
        print("MainPageViewController: \(message)")
    }
}

// MARK: - PermissionManagerDelegate
extension MainPageViewController: PermissionManagerDelegate {
    func permissionManager(_ manager: PermissionManager, didUpdateAdvertisingId advertisingId: String?) {
        AppBeaconManager.shared.updateAdvertisingId(advertisingId)
    }

    func permissionManager(_ manager: PermissionManager, didCompletePermissionRequests: Void) {
        log("All permission requests completed")
    }

    func permissionManager(_ manager: PermissionManager, didLogMessage message: String) {
        log(message)
    }
}

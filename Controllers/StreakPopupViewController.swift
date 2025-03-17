import UIKit
import FSCalendar

class StreakPopupViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {

    private let popupView = UIView()
    private var calendar: FSCalendar!
    private var previousButton: UIButton!
    private var nextButton: UIButton!
    private var titleLabel: UILabel!
    private var playedDates: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlayedDates()
        setupPopup()
        setupCalendar()
        setupCustomHeader()
    }

    // MARK: - Load Played Dates
    private func loadPlayedDates() {
        playedDates = UserDefaults.standard.stringArray(forKey: "PlayedDates") ?? []
        print("Loaded Played Dates: \(playedDates)")
    }

    // MARK: - Setup Popup UI
    private func setupPopup() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)

        popupView.backgroundColor = .white
        popupView.layer.cornerRadius = 12
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)

        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.black, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        closeButton.addTarget(self, action: #selector(closePopup), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closeButton)

        NSLayoutConstraint.activate([
            popupView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popupView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popupView.widthAnchor.constraint(equalToConstant: 350),
            popupView.heightAnchor.constraint(equalToConstant: 400),

            closeButton.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 10),
            closeButton.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10),
            closeButton.widthAnchor.constraint(equalToConstant: 30),
            closeButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    // MARK: - Setup Calendar
    private func setupCalendar() {
        calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.delegate = self
        calendar.dataSource = self
        calendar.allowsSelection = false
        calendar.appearance.headerTitleColor = .clear

        calendar.appearance.todayColor = .clear
        calendar.appearance.titleTodayColor = .black
        calendar.appearance.selectionColor = .clear
        calendar.appearance.borderRadius = 0.3

        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14)

        calendar.scrollEnabled = false
        calendar.scope = .month
        
        calendar.appearance.imageOffset = CGPoint(x: 0, y: -12)

        calendar.placeholderType = .none

        popupView.addSubview(calendar)

        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 80),
            calendar.leadingAnchor.constraint(equalTo: popupView.leadingAnchor, constant: 10),
            calendar.trailingAnchor.constraint(equalTo: popupView.trailingAnchor, constant: -10),
            calendar.bottomAnchor.constraint(equalTo: popupView.bottomAnchor, constant: -10)
        ])
    }

    // MARK: - Setup Header (Month Navigation)
    private func setupCustomHeader() {
        let headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(headerView)

        previousButton = UIButton(type: .system)
        previousButton.setTitle("◀", for: .normal)
        previousButton.setTitleColor(.blue, for: .normal)
        previousButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        previousButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(previousButton)

        nextButton = UIButton(type: .system)
        nextButton.setTitle("▶", for: .normal)
        nextButton.setTitleColor(.blue, for: .normal)
        nextButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(nextButton)

        titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 50),
            headerView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 30),

            previousButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            previousButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            nextButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            nextButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor)
        ])
        updateHeaderTitle()
    }

    @objc private func previousMonth() {
        if let previousMonth = Calendar.current.date(byAdding: .month, value: -1, to: calendar.currentPage) {
            calendar.setCurrentPage(previousMonth, animated: true)
            updateHeaderTitle()
        }
    }

    @objc private func nextMonth() {
        if let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: calendar.currentPage) {
            calendar.setCurrentPage(nextMonth, animated: true)
            updateHeaderTitle()
        }
    }

    private func updateHeaderTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        titleLabel.text = formatter.string(from: calendar.currentPage)
    }

    // MARK: - Calendar Appearance Customizations
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        let weekday = Calendar.current.component(.weekday, from: date) 
        let components = Calendar.current.dateComponents([.month, .year], from: date)
        let currentMonthComponents = Calendar.current.dateComponents([.month, .year], from: calendar.currentPage)

        if components.month == currentMonthComponents.month && components.year == currentMonthComponents.year {
            if playedDates.contains(dateString) {
                return .clear
            }
            return weekday == 1 ? .red : nil
        }
        return nil
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, weekdayTextColorFor weekday: Int) -> UIColor? {
        return weekday == 1 ? .red : .black
    }

    // MARK: - Show Coin on Played Dates
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)

        if playedDates.contains(dateString) {
            let isStreakAchieved = UserDefaults.standard.bool(forKey: "StreakAchieved_\(dateString)")
            let coinColor = isStreakAchieved ? UIColor.purple : UIColor.green
            return generateCoinImage(coinColor: coinColor)
        }
        return nil
    }

    private func generateCoinImage(coinColor: UIColor) -> UIImage? {
        let coinSize = CGSize(width: 20, height: 20)
        let coinView = CoinView(frame: CGRect(origin: .zero, size: coinSize), coinColor: coinColor)

        UIGraphicsBeginImageContextWithOptions(coinSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        coinView.layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    func refreshCalendar() {
        loadPlayedDates()
        calendar.reloadData()
    }

    @objc private func closePopup() {
        dismiss(animated: true, completion: nil)
    }
}

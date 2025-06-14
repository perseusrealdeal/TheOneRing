//
//  CurrentLocationPanel.swift, CurrentLocationPanel.xib
//  DarkModeDiscovery
//
//  Created by Mikhail A. Zhigulin of Novosibirsk.
//
//  Unlicensed Free Software.
//

import UIKit

import ConsolePerseusLogger
import PerseusDarkMode
import PerseusGeoKit

class CurrentLocationPanel: UIView {

    private let theDarknessTrigger = DarkModeObserver()

    private lazy var locationViewController = { () -> LocationViewController in

        let storyboard =
            UIStoryboard(name: String(describing: LocationViewController.self), bundle: nil)
        let screen = storyboard.instantiateInitialViewController() as? LocationViewController

        // Do default setup; don't set any parameter causing loadView up, breaks unit tests
        return screen ?? LocationViewController()
    }()

    // MARK: - Outlets

    @IBOutlet private weak var contentView: UIView!

    @IBOutlet private weak var buttonOpenMap: UIButton!
    @IBOutlet private weak var buttonRefreshStatus: UIButton!
    @IBOutlet private weak var buttonCurrentLocation: UIButton!

    @IBOutlet private weak var labelGeoStatus: UILabel!
    @IBOutlet private weak var labelCoordinate: UILabel!

    // MARK: - Actions

    @IBAction func actionOpenMap(_ sender: UIButton) {
        guard let vc = self.parentViewController() else { return }
        vc.present(self.locationViewController, animated: true, completion: nil)
    }

    @IBAction func buttonRefreshStatusTapped(_ sender: UIButton) {
        labelGeoStatus.text = "\(GeoAgent.currentStatus)".capitalized
        LocationDealer.requestPermission(self.parentViewController())

        if GeoAgent.currentStatus == .allowed, let vc = self.parentViewController() {
            REDIRECT_ALERT_TITLES.title = REDIRECT_ALERT_TITLES.titleWithStatus
            GeoAgent.showRedirectAlert(vc, REDIRECT_ALERT_TITLES)  // Offer redirect.
        } else {
            LocationDealer.requestPermission(self.parentViewController())
        }
    }

    @IBAction func buttonRefreshCurrentTapped(_ sender: UIButton) {
        LocationDealer.requestCurrent(self.parentViewController())
    }

    // MARK: - Start

    override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        commonInit()
        configure()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)

        addSubview(contentView)

        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(
                equalTo: widthAnchor,
                constant: .zero
            ),
            contentView.heightAnchor.constraint(
                equalTo: heightAnchor,
                constant: .zero
            )
        ])

        // Connect to Geo Coordinator
        GeoCoordinator.register(stakeholder: self, selector: #selector(reload))

        // Connect to Dark Mode explicitly
        theDarknessTrigger.action = { _ in self.makeUp() }
    }

    private func configure() {
        buttonRefreshStatus.layer.cornerRadius = 8
        buttonRefreshStatus.layer.masksToBounds = true
        buttonCurrentLocation.layer.cornerRadius = 8
        buttonCurrentLocation.layer.masksToBounds = true
        buttonOpenMap.layer.cornerRadius = 8
        buttonOpenMap.layer.masksToBounds = true
    }
}

// MARK: - Implementation

extension CurrentLocationPanel {

    @objc private func reload() {
        labelGeoStatus.text = "\(GeoAgent.currentStatus)".capitalized
        labelCoordinate.text = CURRENT_GEO_POINT
    }

    @objc private func makeUp() {
        buttonRefreshStatus.backgroundColor = .customSecondaryBackground
        buttonCurrentLocation.backgroundColor = .customSecondaryBackground
        buttonOpenMap.backgroundColor = .customSecondaryBackground
        labelGeoStatus.textColor = .customGeoLabel
        labelCoordinate.textColor = .customGeoLabel
    }
}

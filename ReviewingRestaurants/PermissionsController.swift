//
//  PermissionsController.swift
//  ReviewingRestaurants
//
//  Created by David Anglin on 9/7/17.
//  Copyright © 2017 David Anglin. All rights reserved.
//


// Location Services
// 1) Significant Changes - low power, only notified when user makes a large location change
// 2) Standard Location Services - highly configurable way to get users location and make changes
// 3) Region Monitoring - updates when user crosses boundaries of geographical region or bluetooth region

// Local Authorization
// 1) WhenInUse - When the app is in the foreground and in use(NSLocationWhenInUseUsageDescription)
// 2) Always - Significant location changes, region monitoring(NSLocationAlwaysUsageDescription)

import UIKit
import OAuth2
import CoreLocation

class PermissionsController: UIViewController, LocationPermissionsDelegate {
    
    let oauth = OAuth2ClientCredentials(settings: [
        "client_id" : "mE2RJWK_87Hb2yy8QnzIRw",
        "client_secret" : "oKd2MpqARD4oXqgZh3VhLWogWXYS9dqN8kKOYClM94EuTEcIQxck7qwdeTBu75r9",
        "authorize_uri" : "https://api.yelp.com/oauth2/token",
        "secret_in_body" : true,
        "keychain" : false
        ])
    
    lazy var locationManager: LocationManager = {
        return LocationManager(delegate: nil, permissionsDelegate: self)
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        return indicator
    }()
    
    var isAuthorizedForLocation: Bool
    var isAuthorizedWithToken: Bool
    
    lazy var locationPermissionButton:  UIButton = {
        let title = self.isAuthorizedForLocation ? "Location Permissions Granted" : "Request Location Permissions"
        let button = UIButton(type: .system)
        let controlState = self.isAuthorizedForLocation ? UIControlState.disabled : UIControlState.normal
        button.isEnabled = !self.isAuthorizedForLocation
        button.setTitle(title, for: controlState)
        button.addTarget(self, action: #selector(PermissionsController.requestLocationPermissions), for: .touchUpInside)
        
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(colorLiteralRed: 62/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1.0)
        button.setTitleColor(UIColor(colorLiteralRed: 178/255.0, green: 187/255.0, blue: 185/255.0, alpha: 1.0), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var oauthTokenButton:  UIButton = {
        let title = self.isAuthorizedWithToken ? "OAuth Token Granted" : "Request OAuth Token"
        let button = UIButton(type: .system)
        let controlState = self.isAuthorizedWithToken ? UIControlState.disabled : UIControlState.normal
        button.isEnabled = !self.isAuthorizedWithToken
        button.setTitle(title, for: controlState)
        button.addTarget(self, action: #selector(PermissionsController.requestOAuthToken), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(colorLiteralRed: 62/255.0, green: 71/255.0, blue: 79/255.0, alpha: 1.0)
        button.setTitleColor(UIColor(colorLiteralRed: 178/255.0, green: 187/255.0, blue: 185/255.0, alpha: 1.0), for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        
        return button
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(PermissionsController.dismissPermissions), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init coder not implemented")
    }
    
    init(isAuthorizedForLocation locationAuthorization: Bool, isAuthorizedWithToken tokenAuthorization: Bool) {
        self.isAuthorizedForLocation = locationAuthorization
        self.isAuthorizedWithToken = tokenAuthorization
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(colorLiteralRed: 95/255.0, green: 207/255.0, blue: 128/255.0, alpha: 1.0)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let stackView = UIStackView(arrangedSubviews: [locationPermissionButton, oauthTokenButton])
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 16.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        view.addSubview(dismissButton)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            locationPermissionButton.heightAnchor.constraint(equalToConstant: 64.0),
            locationPermissionButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            locationPermissionButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            oauthTokenButton.heightAnchor.constraint(equalToConstant: 64.0),
            oauthTokenButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
            oauthTokenButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32.0),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32.0),
            dismissButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            dismissButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            ])
        
    }
    
    func requestLocationPermissions() {
        do {
            try locationManager.requestLocationAuthorization()
            
        } catch LocationError.disallowedByUser {
            // Show alert to users
        } catch let error {
            print("Location Authorization Failed: \(error.localizedDescription)")
        }
    }
    
    func requestOAuthToken() {
        activityIndicator.startAnimating()
        oauth.authorize { authParams, error in
            if let params = authParams {
                guard let token = params["access_token"] as? String, let expiration = params["expires_in"] as? TimeInterval else { return }
                
               let account = YelpAccount(accessToken: token, expiration: expiration, grantDate: Date())
                do {
                    try? account.save()
                    self.oauthTokenButton.setTitle("OAuth Token Granted", for: .disabled)
                    self.oauthTokenButton.isEnabled = false
                    self.activityIndicator.stopAnimating()
                    self.popupAlert(title: "Successful", message: "Authentication Successful", actionTitles: ["Ok"], actions: [{ action in }])
                }
            } else {
                self.activityIndicator.stopAnimating()
                self.popupAlert(title: "Error", message: "Authorization was cancelled or went wrong: \(error!)", actionTitles: ["Ok"], actions: [{ action in } ])
            }
        }
    }
    
    func dismissPermissions() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Location Permissions Delegate -
    func authorizationSucceeded() {
        locationPermissionButton.setTitle("Locations Permissions Granted", for: .disabled)
        locationPermissionButton.isEnabled = false
    }
    
    func authorizationFaliedWithStatus(_ status: CLAuthorizationStatus) {
        //
    }
    
}


//
//  MobSurSurveyViewController.swift
//
//  Created by Lachezar Todorov on 25.11.21.
//  Copyright © 2021 EdenTechLabs, Inc. All rights reserved.
//

import UIKit
import WebKit

class MobSurSurveyViewController: UIViewController, WKNavigationDelegate {
    
    var webView: WKWebView
    
    let survey: MobSurSDK.Survey
    
    let closeButton = UIButton(type: .custom)
    var activityIndicator = UIActivityIndicatorView()
    
    init(survey: MobSurSDK.Survey) {
        self.survey = survey
        
        let webConfiguration = WKWebViewConfiguration()
        self.webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        let closeImage = UIImage(named: "SurveyCloseButton", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        
        closeButton.setImage(closeImage, for: .normal)
        closeButton.addTarget(self, action: #selector(close), for: .touchUpInside)
        closeButton.tintColor = UIColor(red: 0.141, green: 0.659, blue: 0.475, alpha: 1)

        view.addSubview(webView)
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        view.addSubview(activityIndicator)
        
        activityIndicator.color = .darkGray
        activityIndicator.hidesWhenStopped = true
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        }
        activityIndicator.startAnimating()

        let g = view.safeAreaLayoutGuide
        webView.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: g.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: g.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: g.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: g.topAnchor, constant: 15),
            closeButton.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -25),
            
            webView.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 15),
            
            activityIndicator.centerXAnchor.constraint(equalTo: webView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: webView.centerYAnchor)
        ])
        
        webView.navigationDelegate = self
        
        guard let myURL = URL(string: survey.url) else {
            close()
            return
        }
        
        let myRequest = URLRequest(url: myURL)
        webView.load(myRequest)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlString = navigationAction.request.mainDocumentURL?.absoluteString,
           urlString.hasSuffix("#close") {
            self.close(finished: true)
            decisionHandler(.cancel)
            return
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    @objc func close(finished: Bool = false) {
        if finished {
            MobSurSDK.shared.finish(survey: survey)
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

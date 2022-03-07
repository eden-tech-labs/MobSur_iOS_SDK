//
//  MobSurSDK.swift
//
//  Created by Lachezar Todorov on 26.11.21.
//  Copyright © 2021 EdenTechLabs, Inc. All rights reserved.
//

import Foundation
import UIKit

class MobSurSDK {
    static let shared = MobSurSDK()
    
    private var appID: String?
    
    private var launched = false
    
    private var surveys: [MobSurSDK.Survey] {
        get {
            guard let obj = storage.data(forKey: Self.surveyStorageKey),
                let result = try? JSONDecoder().decode(SurveyResponse.self, from: obj) else {
                return []
            }
            
            return result.data
        }
        set {
            let obj = SurveyResponse.init(data: newValue)
            guard let data = try? JSONEncoder().encode(obj) else {
                return
            }
            
            storage.set(data, forKey: Self.surveyStorageKey)
        }
    }
    
    private var eventLog: [SurveyEventLog] {
        get {
            guard let obj = storage.data(forKey: Self.eventLogStorageKey),
                let result = try? JSONDecoder().decode([SurveyEventLog].self, from: obj) else {
                return []
            }
            
            return result
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                return
            }
            
            storage.set(data, forKey: Self.eventLogStorageKey)
        }
    }
    
    private let urlSession = URLSession(configuration: .default)
    
    private static let endpoint = "https://mobsur.appget.link/api/surveys"
    
    private static let prefix = "MobSur_106_"
    private static let surveyStorageKey = "\(prefix)surveys"
    private static let eventLogStorageKey = "\(prefix)eventLog"
    private static let userIDKey = "\(prefix)user_id"
    
    private var storage: UserDefaults { UserDefaults.standard }
    
    private var userID: String? {
        get {
            UserDefaults.standard.string(forKey: Self.userIDKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Self.userIDKey)
            self.fetchData()
        }
    }
    
    private var languages: [String] {
        Locale.preferredLanguages
    }
    
    
    func setup(appID: String, userID: String? = nil) {
        self.appID = appID
        
        if let userID = userID {
            self.userID = userID // Changing the user triggers fetchData
        } else {
            self.fetchData()
        }
    }
    
    func updateUser(id: String) {
        self.userID = id
    }
    
    func event(name eventName: String) {
        print("SurveyEvent: \(eventName)")
        
        surveyLoop: for survey in surveys {
            if survey.validFor(date: Date()) {
                
                // The only supported type right now is counted events
                let rules = survey.rules(for: eventName).filter{ $0.type == .countedEvent }
                
                guard !rules.isEmpty else {
                    continue
                }
                
                let eventItem = logEvent(name: eventName, for: survey)
                var delay = 0
                for rule in rules {
                    if let min = rule.occurred?.min, min > eventItem.count {
                        print("SurveySkip: \(min) > \(eventItem.count)")
                        continue surveyLoop
                    }
                    if let max = rule.occurred?.max, max < eventItem.count {
                        print("SurveySkip: \(max) < \(eventItem.count)")
                        continue surveyLoop
                    }
                    
                    delay = rule.delay ?? 0
                    break
                }
                
                print("SurveyShowing:\(survey.id) for:\(eventName) count:\(eventItem.count)")
                
                let secondsDelay = Double(delay) / 1000
                DispatchQueue.main.asyncAfter(deadline: .now() + secondsDelay) {
                    self.launch(survey: survey)
                }
                
                return
            }
        }
    }
    
    private func logEvent(name: String, for survey: Survey) -> SurveyEventLog.Item {
        if let index = eventLog.firstIndex(where: { $0.surveyID == survey.id }) {
            if let eventIndex = eventLog[index].events.firstIndex(where: { $0.name == name }) {
                eventLog[index].events[eventIndex].count += 1
                return eventLog[index].events[eventIndex]
            } else {
                let item = SurveyEventLog.Item(name: name, count: 1)
                eventLog[index].events.append(item)
                return item
            }
        } else {
            let item = SurveyEventLog.Item(name: name, count: 1)
            eventLog.append(.init(surveyID: survey.id, events: [item]))
            return item
        }
    }
    
    func finish(survey: Survey) {
        surveys.removeAll(where: { $0.id == survey.id })
    }
    
    private func launch(survey: Survey) {
        guard !launched else {
            return
        }
        
        print("Launching: \(survey.url)")
        
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let vc = MobSurSurveyViewController(survey: survey)
            vc.modalPresentationStyle = .pageSheet
            vc.modalTransitionStyle = .coverVertical

            launched = true
            
            topController.present(vc, animated: true, completion: nil)
        }
    }
    
    private func fetchData() {
        guard let appID = appID, var urlComponents = URLComponents(string: Self.endpoint) else {
            return
        }
        
        guard let userID = userID else {
            return
        }
        
        urlComponents.queryItems = [
            .init(name: "app_id", value: appID),
            .init(name: "user_reference_id", value: userID),
            .init(name: "platform", value: UIDevice.current.systemName)
        ]
        
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String? {
            urlComponents.queryItems?.append(.init(name: "app_version", value: version))
        }
        
        guard let url = urlComponents.url else {
            printError(message: "Can't construct url")
            return
        }
        
        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "GET"
        
        let languages = Locale.preferredLanguages.joined(separator: ",")
        request.setValue(languages, forHTTPHeaderField: "Accept-Language")
        
        urlSession.dataTask(with: request) {[weak self] data, response, error in
            if let error = error {
                self?.handleError(error: error)
                return
            }
            
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            
            do {
                let object = try decoder.decode(SurveyResponse.self, from: data)
                self?.update(surveys: object.data)
            } catch {
                self?.handleError(error: error)
                return
            }
        }.resume()
    }
    
    private func update(surveys: [Survey]) {
        
        print("SURVEYS:", surveys)
        
        let newIDs = Set(surveys.map(\.id))
        let oldIDs = Set(self.surveys.map(\.id))
        
        let deleted = oldIDs.subtracting(newIDs)
        eventLog.removeAll(where: { deleted.contains($0.surveyID) })
        
        self.surveys = surveys
    }
    
    private func handleError(error: Error) {
        printError(message: "\(error)")
    }
    
    private func printError(message: String) {
        print("Survey Error: \(message)")
    }
}

extension MobSurSDK {
    struct SurveyResponse: Codable {
        let data: [MobSurSDK.Survey]
    }
    struct Survey: Codable {
        
        struct Rule: Codable {
            
            enum RuleType: String, Codable {
                case countedEvent = "counted_event"
            }
            
            struct Occurrance: Codable {
                let min: Int?
                let max: Int?
            }
            
            let type: RuleType
            let name: String
            let occurred: Occurrance?
            let delay: Int?
        }
        
        let id: Int
        let url: String
        let rules: [Rule]
        let startDate: Date?
        let endDate: Date?
        
        func validFor(date: Date) -> Bool {
            return (startDate == nil || startDate! < date)
                && (endDate == nil || endDate! > date)
        }
        
        func rules(for event: String) -> [Rule] {
            return rules.filter{ $0.name == event }
        }
    }
    
    struct SurveyEventLog: Codable {
        struct Item: Codable {
            let name: String
            var count: Int
        }
        
        let surveyID: Int
        var events = [Item]()
    }
}

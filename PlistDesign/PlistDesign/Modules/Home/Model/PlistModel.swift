//
//  PlistModel.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import Foundation

struct PlistRootModel : Codable {
    var version: Version?
    private enum CodingKeys : String, CodingKey {
      case version = "4.64.0"
    }
}
struct Version : Codable {
    var shared: Shared?
    var support: Support?
    var extensionConfiguration: ExtensionConfiguration?
    private enum CodingKeys : String, CodingKey {
      case shared = "Shared"
      case support = "Support"
      case extensionConfiguration = "ExtensionConfiguration"
    }
}

struct ExtensionConfiguration : Codable {
    var extensionToday: Int?
    private enum CodingKeys : String, CodingKey {
      case extensionToday = "ExtensionTodayViewMinRefreshIntervalSeconds"
    }
}

struct Support : Codable {
    var liveChat: LiveChat?
    private enum CodingKeys : String, CodingKey {
      case liveChat = "LiveChat"
    }
}

struct LiveChat : Codable {
    var welcomeMessage: String?
    private enum CodingKeys : String, CodingKey {
      case welcomeMessage = "WelcomeMessage"
    }
}

struct Shared : Codable {
    var appVersions: [AppVersion]?
    var features: [Feature]?
    private enum CodingKeys : String, CodingKey {
      case appVersions = "ApplicationVersionManagement"
      case features = "Features"
    }
}

struct AppVersion : Codable {
    var latestVersion: String?
    var appstoreURL: String?
    var appstroreUpgradeMessage: LatestAppstoreVersionUpgradeMessage?
    private enum CodingKeys : String, CodingKey {
      case latestVersion = "LatestVersionInAppstore"
      case appstoreURL = "AppstoreURL"
      case appstroreUpgradeMessage = "LatestAppstoreVersionUpgradeMessage"
    }
}

struct LatestAppstoreVersionUpgradeMessage : Codable {
    var title: String?
    var message: String?
    private enum CodingKeys : String, CodingKey {
      case title = "title"
      case message = "message"
    }
}
struct Feature : Codable {
    var name: String?
    var enabled: Bool?
    private enum CodingKeys : String, CodingKey {
      case name = "Name"
      case enabled = "Enabled"
    }
}


class Section {
    var isCollapsible: Bool
    var isOpened: Bool
    var key: String
    var level: Int
    var value: Any
    var sections = [Section]()
    var type: String = ""
    var itemCount: String = ""
    
    init(isCollapsible: Bool, isOpened: Bool, key: String, level: Int, value: Any, sections: [Section] = [Section]()) {
        self.isCollapsible = isCollapsible
        self.isOpened = isOpened
        self.key = key
        self.level = level
        self.value = value
        self.sections = sections
        self.type = getTypeOfValue(val: value)
        self.itemCount = getItemCount(value: value)
    }
    
    func getTypeOfValue(val: Any) -> String {
        switch val {
        case is Bool:
            return "Boolean"
        case is Int:
            return "Int"
        case is String:
            return "String"
        case is [String:Any]:
            return "Dictionary"
        case is [[String:Any]]:
            return "Array"
        default:
            return "Unknown"
        }
    }
    
    func getItemCount(value: Any) -> String {
        var count = ""
        if let val = value as? [String:Any] {
            let item = (val.count > 1) ? "items" : "item"
            count = "(" + "\(val.count)" + " \(item)" + ")"
        }else if let val = value as? [[String:Any]] {
            let item = (val.count > 1) ? "items" : "item"
            count = "(" + "\(val.count)" + " \(item)" + ")"
        }
        return count
    }
}

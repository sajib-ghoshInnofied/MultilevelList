//
//  HomeViewModel.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import Foundation

class HomeViewModel {
    let apiDataManager: HomeAPIDataManagerProtocol
    init(apiDataManager: HomeAPIDataManagerProtocol) {
        self.apiDataManager = apiDataManager
    }

    func fetchPlist() async -> (PlistRootModel?,CustomError?) {
        return await apiDataManager.fetchPlistData()
    }
    
    func convertSectionArrayToDictionary(sections: [Section]) -> NSMutableDictionary {
        let sectionDict = NSMutableDictionary()
        var count = 0
        for section in sections {
            if section.isOpened {
                let childItems = getChildItemsFor(parent: section)
                sectionDict[count] = childItems
            }
            count += 1
        }
        return sectionDict
    }
    
    func getChildItemsFor(parent: Section) -> NSMutableArray {
        let childItems = NSMutableArray()
        if !parent.isOpened {
            return childItems
        }
        for section in parent.sections {
            childItems.add(section)
            if section.isOpened {
                childItems.addObjects(from: getChildItemsFor(parent: section) as! [Any])
            }
        }
        return childItems
    }
    
    func getAllChildItemsFor(parent: Section) -> NSMutableArray {
        let childItems = NSMutableArray()
        //childItems.add(parent)
        //parent.isOpened = true
        for section in parent.sections {
            section.isOpened = true
            childItems.add(section)
            childItems.addObjects(from: getAllChildItemsFor(parent: section) as! [Any])
        }
        return childItems
    }
    
    func getChildItemsForSearch(parent: Section, searchText: String) -> NSMutableArray {
        let childItems = NSMutableArray()
        for section in parent.sections {
            let child = NSMutableArray()
            section.isOpened = true
            child.add(section)
            if section.key.contains(searchText) || section.valueString.contains(searchText) {
                childItems.addObjects(from: child as! [Any])
                return childItems
            }else if !section.isCollapsible {
                print("Go back....\(section.key)")
                child.removeAllObjects()
                childItems.removeAllObjects()
                collapseChild(childItems: childItems as! [Section])
                return childItems
            }else{
                child.addObjects(from: getChildItemsForSearch(parent: section, searchText: searchText) as! [Any])
            }
            childItems.addObjects(from: child as! [Any])
        }
        return childItems
    }
    
    func collapseChild(childItems:[Section]) {
        for childItem in childItems {
            childItem.isOpened = false
        }
    }
    
    func convertPlistToSections(_ plist: PlistRootModel?) -> [Section] {
        var sections = [Section]()
        if let plist = plist {
            if let plistDict = convertPlistToDictionary(plist) {
                //print(plistDict)
                var section: Section!
                for (key,value) in plistDict {
                    section = Section(isCollapsible: true, isOpened: false, key: key, level: 1, value: value)
                    convertDictToSections(value as! [String : Any], parentNode: section, level: 1)
                }
                sections.append(section)
            }
        }
        return sections
    }
    
    func convertDictToSections(_ dict: [String:Any], parentNode: Section?, level: Int) {
        for (key,value) in dict {
            let currentNode = Section(isCollapsible: false, isOpened: false, key: key, level: level + 1, value: value)
            if let dictionary1 = value as? [String:Any] {
                currentNode.isCollapsible = true
                for (key,value) in dictionary1 {
                    let currentNode1 = Section(isCollapsible: false, isOpened: false, key: key, level: level + 2, value: value)
                    if let dictionary2 = value as? [String:Any] {
                        currentNode1.isCollapsible = true
                        for (key,value) in dictionary2 {
                            //Bottom most
                            let currentNode2 = Section(isCollapsible: false, isOpened: false, key: key, level: level + 3, value: value)
                            currentNode1.sections.append(currentNode2)
                        }
                    }else if let arr = value as? [[String:Any]] {
                        currentNode1.isCollapsible = true
                        var count = 0
                        for dict2 in arr {
                            let item = Section(isCollapsible: true, isOpened: false, key: "Item \(count)", level: level + 3, value: dict2)
                            for (key,value) in dict2 {
                                //Bottom most
                                let currentNode3 = Section(isCollapsible: false, isOpened: false, key: key, level: level + 4, value: value)
                                item.sections.append(currentNode3)
                            }
                            currentNode1.sections.append(item)
                            count += 1
                        }
                    }
                    currentNode.sections.append(currentNode1)
                }
            }
            parentNode?.sections.append(currentNode)
        }
    }
    

    func convertPlistToDictionary(_ plist: PlistRootModel) -> [String: Any]? {
        var dict: [String: Any]?
        if let jsonData = try? JSONEncoder().encode(plist){
            let jsonString = String(data: jsonData, encoding: .utf8)!
            if let data = jsonString.data(using: .utf8) {
                let anyResult = try? JSONSerialization.jsonObject(with: data, options: [])
                dict = anyResult as? [String: Any]
            }
        }else{
            fatalError("Could not convert plist to dictionary")
        }
        return dict
    }

}

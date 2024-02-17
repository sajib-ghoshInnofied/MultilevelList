//
//  ViewController.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    private var sections = [Section]()
    private var sectionDictionary = NSMutableDictionary()
    private var plistModel: PlistRootModel?
    private var viewModel: HomeViewModel!
    
    private var isSearching = false
    @IBOutlet weak var searchBar: UISearchBar!
    private var sectionDictionaryForSearch = NSMutableDictionary()
    private var searchText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            activityIndicator.startAnimating()
            await getPlist()
            activityIndicator.stopAnimating()
            reloadData()
        }
        
        searchBar.delegate = self
        
    }
    
    func reloadData() {
        sections = viewModel.convertPlistToSections(plistModel)
        sectionDictionary = viewModel.convertSectionArrayToDictionary(sections: sections)
        tableView.reloadData()
    }
    
    

    func getPlist() async {
        let apiDataManager = HomeAPIDataManager(networkService: NetworkService())
        viewModel = HomeViewModel(apiDataManager: apiDataManager)
        let (plist,error) = await viewModel.fetchPlist()
        plistModel = plist
        if let error = error {
            print(error.description)
        }
    }

}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !isSearching {
            return sections.count
        }else{
            return sections.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if !isSearching {
            let childItems = sectionDictionary[section]
            if let items = childItems as? [Section] {
                return items.count
            }else{
                return 0
            }
        }else{
            let childItems = sectionDictionaryForSearch[section]
            if let items = childItems as? [Section] {
                return items.count
            }else{
                return 0
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlistCell") as? PlistCell
        var childItems: Any?
        if !isSearching {
            childItems = sectionDictionary[indexPath.section]
        }else{
            childItems = sectionDictionaryForSearch[indexPath.section]
        }
        if let items = childItems as? [Section] {
            let item = items[indexPath.row]
            cell?.cellFillWithData(section: item)
        }
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "PlistHeaderCell") as? PlistHeaderCell
        headerView?.delegate = self
        headerView?.location = section
        if !isSearching {
            headerView?.cellFillWithData(section: sections[section])
        }else{
            headerView?.cellFillWithData(section: sections[section])
//            let childItems = sectionDictionaryForSearch[section]
//            if let items = childItems as? [Section] {
//                headerView.cellFillWithData(section: items[section])
//            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let childItems = viewModel.getChildItemsFor(parent: sections[indexPath.section])
        if !isSearching {
            if let items = childItems as? [Section] {
                let item = items[indexPath.row]
                plistItemTapped(item: item, location: indexPath)
            }
        }else{
            if let items = childItems as? [Section] {
                let item = items[indexPath.row]
                plistItemTappedForSearch(item: item, location: indexPath)
                if item.isOpened {
                    executeSearch(searchText: searchText)
                }
            }
        }
        
    }
}

extension HomeVC: PlistHeaderCellProtocol {
    func plistHeaderTappend(location: Int) {
        print(location)
        let item = sections[location]
        if !isSearching {
            plistItemTapped(item: item, location: IndexPath(row: NSNotFound, section: location))
        }else{
            plistItemTappedForSearch(item: item, location: IndexPath(row: NSNotFound, section: location))
            if item.isOpened {
                executeSearch(searchText: searchText)
            }
        }
        
    }
}

extension HomeVC {
    
    func plistItemTapped(item: Section, location: IndexPath) {
        if !item.sections.isEmpty {
            if item.isOpened {
                //Remove child
                item.isOpened = false
                collapseExpandedSections(parent: item)
            }else{
                //Insert will happen in dict
                item.isOpened = true
            }
        }
        sectionDictionary.removeAllObjects()
        for index in 0..<sections.count {
            let parentItem = sections[index]
            let expandedChilds = viewModel.getChildItemsFor(parent: parentItem)
            sectionDictionary[location.section] = expandedChilds
        }
        //self.tableView.reloadData()
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    func plistItemTappedForSearch(item: Section, location: IndexPath) {
        if !item.sections.isEmpty {
            if item.isOpened {
                //Remove child
                item.isOpened = false
                collapseExpandedSections(parent: item)
            }else{
                //Insert will happen in dict
                item.isOpened = true
            }
        }
        sectionDictionaryForSearch.removeAllObjects()
        for index in 0..<sections.count {
            let parentItem = sections[index]
            let expandedChilds = viewModel.getChildItemsFor(parent: parentItem)
            sectionDictionaryForSearch[location.section] = expandedChilds
        }
        //self.tableView.reloadData()
        UIView.transition(with: tableView, duration: 0.2, options: .transitionCrossDissolve, animations: {self.tableView.reloadData()}, completion: nil)
    }
    
    func collapseExpandedSections(parent: Section) {
        if !parent.sections.isEmpty {
            for section in parent.sections {
                if (!section.isOpened) {
                    continue
                }else{
                    section.isOpened = false
                    collapseExpandedSections(parent: section)
                }
            }
        }
    }
}

extension HomeVC: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = true
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(HomeVC.performSearch), object: nil)
            self.perform(#selector(HomeVC.performSearch), with: nil, afterDelay: 0.2)
        print("textDidChange")
    }
    
    @objc func performSearch() {
        guard let searchText = searchBar.text else { return }
        if searchText == "" {
            isSearching = false
            print("performSearch:\(isSearching)")
            sectionDictionaryForSearch.removeAllObjects()
            reloadData()
        }else{
            print("performSearch:\(searchText)")
            self.searchText = searchText
            executeSearch(searchText: searchText)
        }
    }
    
    func executeSearch(searchText:String) {
        sectionDictionaryForSearch.removeAllObjects()
        let childItems = viewModel.getAllChildItemsFor(parent: sections[0])
        if let items = childItems as? [Section] {
            var filterItems = items.filter{$0.key.contains(searchText) || $0.valueString.contains(searchText) || String(describing: $0.value).contains(searchText)}
            //filterItems.insert(sections[0], at: 0)
            //sectionDictionaryForSearch[0] = viewModel.getChildItemsForSearch(parent: sections[0], searchText: searchText)
            sectionDictionaryForSearch[0] = filterItems
            sections[0].isOpened = true
            tableView.reloadData()
        }
    }
}

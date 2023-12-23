//
//  ViewController.swift
//  PlistDesign
//
//  Created by Sajib Ghosh on 21/12/23.
//

import UIKit

class HomeVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var sections = [Section]()
    private var sectionDictionary = NSMutableDictionary()
    private var plistModel: PlistRootModel?
    private var viewModel: HomeViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        Task {
            await getPlist()
            sections = viewModel.convertPlistToSections(plistModel)
            sectionDictionary = viewModel.convertSectionArrayToDictionary(sections: sections)
            tableView.reloadData()
        }
        
    }

    func getPlist() async {
        let apiDataManager = HomeAPIDataManager(networkService: NetworkService())
        viewModel = HomeViewModel(apiDataManager: apiDataManager)
        let (plist,error) = await viewModel!.fetchPlist()
        plistModel = plist
        if let error = error {
            print(error.description)
        }
    }

}

extension HomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let childItems = sectionDictionary[section]
        if let items = childItems as? [Section] {
            return items.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlistCell") as! PlistCell
        let childItems = sectionDictionary[indexPath.section]
        if let items = childItems as? [Section] {
            let item = items[indexPath.row]
            cell.cellFillWithData(section: item)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableCell(withIdentifier: "PlistHeaderCell") as! PlistHeaderCell
        headerView.delegate = self
        headerView.location = section
        headerView.cellFillWithData(section: sections[section])
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        let childItems = viewModel.getChildItemsFor(parent: sections[indexPath.section])
        if let items = childItems as? [Section] {
            let item = items[indexPath.row]
            plistItemTapped(item: item, location: indexPath)
        }
    }
}

extension HomeVC: PlistHeaderCellProtocol {
    func plistHeaderTappend(location: Int) {
        print(location)
        let item = sections[location]
        plistItemTapped(item: item, location: IndexPath(row: NSNotFound, section: location))
    }
}

extension HomeVC {
    
    func plistItemTapped(item: Section, location: IndexPath) {
        if item.sections.count > 0 {
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
    
    func collapseExpandedSections(parent: Section) {
        if parent.sections.count > 0 {
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

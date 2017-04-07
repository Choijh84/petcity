//
//  StoreDetailViewDatasource.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 4..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Custom datasourceType to be able to customise the methods and parameters the different sections and rows handle
protocol StoreSectionDataSourceType : class {
    var numberOfRows: Int { get }
    var dataSource: StoreDetailViewDatasource! { get set }
    var sectionIndex: Int! { get set }
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath)
}

 /// Datasource object that is responsible for handling the datasource for the TableView in StoreDetailViewController

class StoreDetailViewDatasource: NSObject, UITableViewDataSource {
    
    /// array that contains all the sections that the tableview will display 
    var sectionSources: [StoreSectionDataSourceType]
    
    /// the tabieview reference
    weak var tableView: UITableView?
    
    /** 
    Initialize the datasource with array of sections and the tableView
    
     - parameter sectionSources: array of sections
     - parameter tableView: tableView
     - returns: self
    */
    
    required init(sectionSources: [StoreSectionDataSourceType]) {
        self.sectionSources = sectionSources
        super.init()
        
        // Assign the correct sectoin index to each sectionSource objects
        var sectionIndex = 0
        for section in self.sectionSources {
            section.dataSource = self
            section.sectionIndex = sectionIndex
            sectionIndex += 1
        }
    }
    
    /** 
     Removes a section at a given index
     - parameter sectionIndex: index to remove the object at
    */
    func removeSectionAtIndex(_ sectionIndex: Int) {
        sectionSources.remove(at: sectionIndex)
    }
    
    // MARK: tableView methods
    /**
     Configures the cell of the requested section
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath of the cell
     
     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = sectionSources[indexPath.section].tableView(tableView, cellForRowAtIndexPath: indexPath)
        return cell
    }
    
    /**
     How many rows it should display at a section
     
     - parameter tableView: tableView
     - parameter section:   section
     
     - returns: number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionSources[section].numberOfRows
    }
    
    /**
     Number of sections to display
     
     - parameter tableView: tableView
     
     - returns: number of sections
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionSources.count
    }
    
    /**
     Gets the section datasource for the given section and calls the selection block of that
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath that was selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sectionSources[indexPath.section].tableView(tableView, didSelectRowAtIndexPath: indexPath)
    }
}

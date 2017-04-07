//
//  StoreDetailSectionDatasource.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 5..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

// Datasource object to configure a datasource object that displays multiple rows

class StoreDetailSectionDatasource<CellClass: UITableViewCell> : StoreSectionDataSourceType {

    /// Datasource object
    var dataSource: StoreDetailViewDatasource!
    
    /// the section index of the datasource
    var sectionIndex: Int!
    
    /// block to be called when the cell is selected
    let selectionBlock: CellSelectionBlock
    
    /// Identifier of the cell
    let cellIdentifier: String
    /// Block to be called to configure the cell
    let setupBlock: CellSetupBlock
    
    /// Setup block of the cell
    typealias CellSetupBlock = (_ cell: CellClass, _ row: Int) -> ()
    /// Selection block of the cell
    typealias CellSelectionBlock = (_ cell: CellClass, _ row: Int) -> ()
    
    /// The number of rows before making an update (adding, removing)
    fileprivate var oldNumberOfRows = Int()
    
    /// The number of rows the datasource should display, if the amount changes, Reload the tableView
    var numberOfRows: Int = 0 {
        willSet {
            oldNumberOfRows = numberOfRows
        }
        didSet {
            if oldNumberOfRows != numberOfRows {
                dataSource.tableView?.reloadData()
            }
        }
    }
    
    /**
     Sets up the cell datasource with the cell's identifier, the setup and the selection block
     
     - parameter cellIdentifier: identifier of the cell
     - parameter numberOfRows:   number of rows to display
     - parameter setupBlock:     setup block
     - parameter selectionBlock: selection block to be called when the cell is selected
     
     - returns: self
     */
    init(cellIdentifier: String, numberOfRows: Int, setupBlock: @escaping CellSetupBlock, selectionBlock: @escaping CellSelectionBlock) {
        self.cellIdentifier = cellIdentifier
        self.setupBlock = setupBlock
        self.numberOfRows = numberOfRows
        self.selectionBlock = selectionBlock
    }
 
    /**
     Calls to configure the cell with the given identifier at the given indexPath and calls the setup block
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath
     
     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CellClass
        setupBlock(cell, indexPath.row)
        return cell
    }
    
    /**
    Calls the selection block if there is any
    
    - parameter tableView: tableView
    - parameter indexPath: indexPath that was selected
    */
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CellClass
        selectionBlock(cell, indexPath.row)
    }
    
}

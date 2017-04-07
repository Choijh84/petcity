//
//  StoreDetailRowDatasource.swift
//  pet-place
//
//  Created by Owner on 2017. 1. 5..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

/// Datasource object to configure a datasource object that displays a single row
class StoreDetailRowDatasource<CellClass: UITableViewCell>: StoreSectionDataSourceType {

    /// Identifier of the cell
    let cellIdentifier: String
    /// Block that called to configure the cell
    let setupBlock: CellSetupBlock
    /// Block that should be called if the cell is selected, might be nil
    let selectionBlock: (() -> ())?
    
    /// How many rows it has 
    var numberOfRows: Int = 1
    /// parent datasource object
    var dataSource: StoreDetailViewDatasource!
    /// the section index of the datasource
    var sectionIndex: Int!
    
    /// setup block to be called to configure the cell
    typealias CellSetupBlock = (_ cell: CellClass) -> ()
    
    /**
    Sets up the cell datasource with the cell's identifier, the setup and the selection block
     
     - parameter identifier: identifier of the cell
     - parameter setupBlock: setup block
     - parameter selectionBlock: selection block to be called when the cell is selected
     - returns: self
    */
    required init(identifier: String, setupBlock: @escaping CellSetupBlock, selectionBlock:(() -> ())?) {
        cellIdentifier = identifier
        self.setupBlock = setupBlock
        self.selectionBlock = selectionBlock
    }
    
    /**
     Sets up the cell datasource with the**
     Sets up the cell datasource with the cell's identifier and the setupBlock
     
     - parameter identifier: identifier of the cell
     - parameter setupBlock: setup block
     
     - returns: self
     */
    required init(identifier: String, setupBlock: @escaping CellSetupBlock) {
        cellIdentifier = identifier
        self.setupBlock = setupBlock
        selectionBlock = nil
    }
    
    /**
     Calls to configure the cell with the given identifier at the given indexPath and calls the setup block
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath
     
     - returns: cell
     */
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! CellClass
        setupBlock(cell)
        return cell
    }
    
    /**
     Calls the selection block if there is any
     
     - parameter tableView: tableView
     - parameter indexPath: indexPath that was selected
     */
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let selectionBlock = selectionBlock {
            selectionBlock()
            print("This is selection BLOCK: \(indexPath)")
        }
    }
}

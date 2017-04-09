//
//  FilterViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 3. 6..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

struct GlobalVar {
    static var filter1: String?
    static var filter2: String?
}

/// The viewcontroller where the user can filter the store objects
class FilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    /// Save the selected storeCategory 
    var selectedCategory: StoreCategory?
    
    /// All sorting options 
    var sortingOptions1 = [
        SortingOption1(name: "강아지", sortingKey: SortingKey1.dog),
        SortingOption1(name: "고양이", sortingKey: SortingKey1.cat)]
    
    var sortingOptions2 = [
        SortingOption2(name: "소형", sortingKey: SortingKey2.small),
        SortingOption2(name: "중형", sortingKey: SortingKey2.middle),
        SortingOption2(name: "대형", sortingKey: SortingKey2.big)]
    
    /// The selected sorting option
    /// var selectedSortingOption1: SortingOption1?
    
    /// The selected sorting option
    /// var selectedSortingOption2: SortingOption2?
    
    /// Tableview to display our categories
    @IBOutlet weak var tableView: UITableView!
    
    /// The Trash Button 
    @IBOutlet weak var trashButton: UIButton!
    
    /**
    Called when the trash button is clicked, clear all filter options
    */
    @IBAction func trashButtonPressed(_ button: UIButton) {
        selectedCategory = nil
        /// selectedSortingOption1 = nil
        /// selectedSortingOption2 = nil
        GlobalVar.filter1 = nil
        GlobalVar.filter2 = nil
        
        tableView.reloadData()
        button.isEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("This is Global Var: \(String(describing: GlobalVar.filter1)) and \(String(describing: GlobalVar.filter2))")
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        if GlobalVar.filter1 != nil || GlobalVar.filter2 != nil {
            setTrashButtonEmpty(false)
        } else {
            setTrashButtonEmpty(true)
        }
    }
    
    // MARK: Tableview methods
    /**
     Description asks the data source for a cell to insert in a particular location of the table view. Loads the sorting options
     :param: tableView A table-view object requesting the cell.
     :param: indexPath An index path locating a row in tableView.
     
     :returns: An object inheriting from UITableViewCell that the table view can use for the specified row.
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortingOption", for: indexPath)
        
        if indexPath.section == 0 {
            let sortingOption = sortingOptions1[indexPath.row]
            cell.textLabel?.text = sortingOption.name
            print("Global filter1: \(String(describing: GlobalVar.filter1)))")
            if GlobalVar.filter1 == sortingOption.name {
                cell.accessoryType = .checkmark
                } else {
                cell.accessoryType = .none
            }
            
        } else {
            let sortingOption = sortingOptions2[indexPath.row]
            cell.textLabel?.text = sortingOption.name
            print("Global filter2: \(String(describing: GlobalVar.filter2))")
            if GlobalVar.filter2 == sortingOption.name {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        return cell
    }
    
    /**
     Displaying 2 sections, 1 for servicePet, 1 for sizePet
     
     :param: tableView An object representing the table view requesting this information.
     
     :returns: number of sections
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    /**
     The title for each section
     
     :param: tableView The table-view object asking for the title.
     :param: section   An index number identifying a section of tableView .
     
     :returns: A string to use as the title of the section header.
     */
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "원하시는 반려동물 종류를 선택하세요"
        } else {
            return "원하시는 반려동물 크기를 선택하세요"
        }
    }
    
    /**
     Asks the delegate for the height to use for the header of a particular section.
     
     :param: tableView The table-view object requesting this information.
     :param: section   An index number identifying a section of tableView .
     
     :returns: A nonnegative floating-point value that specifies the height (in points) of the header for section.
     */
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    /**
     Asks the delegate for the height to use for a row in a specified location.
     
     :param: tableView The table-view object requesting this information.
     :param: indexPath An index path that locates a row in tableView.
     
     :returns: A nonnegative floating-point value that specifies the height (in points) that row should be.
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50.0
    }
    
    /**
     Tells the data source to return the number of rows in a given section of a table view.
     
     :param: tableView The table-view object requesting this information.
     :param: section   An index number identifying a section in tableView.
     
     
     :returns: The number of rows in section.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return sortingOptions1.count
        } else {
            return sortingOptions2.count
        }
    }
    
    /**
     Tells the delegate that the specified row is now selected. Saves the selection, if the cell was already selected, deselects it.
     
     :param: tableView A table-view object informing the delegate about the new row selection.
     :param: indexPath An index path locating the new selected row in tableView.
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0
        {
            /// let selectedSortingOption1 = sortingOptions1[indexPath.row]
            if GlobalVar.filter1 == sortingOptions1[indexPath.row].name {
                /// self.selectedSortingOption1 = nil
                GlobalVar.filter1 = nil
            } else {
                /// self.selectedSortingOption1 = sortingOptions1[indexPath.row]
                GlobalVar.filter1 = sortingOptions1[indexPath.row].name
            }
            // print("This is GlobalVar.filter1: \(String(describing: GlobalVar.filter1))")
        } else {
            /// let selectedSortingOption2 = sortingOptions2[indexPath.row]
            if GlobalVar.filter2 == sortingOptions2[indexPath.row].name {
                /// self.selectedSortingOption2 = nil
                GlobalVar.filter2 = nil
            } else {
                /// self.selectedSortingOption2 = sortingOptions2[indexPath.row]
                GlobalVar.filter2 = sortingOptions2[indexPath.row].name
            }
            // print("This is GlobalVar.filter2: \(String(describing: GlobalVar.filter2))")
        }
        tableView.reloadData()
        setTrashButtonEmpty(false)
    }

    /**
     Sets the trash button's image to empty or full
     
     - parameter empty: true if the trash should display empty state
     */
    func setTrashButtonEmpty(_ empty: Bool) {
        if empty {
            trashButton.setImage(UIImage(named: "trash icon empty"), for: UIControlState())
            trashButton.isEnabled = false
        } else {
            trashButton.setImage(UIImage(named: "trash icon full"), for: UIControlState())
            trashButton.isEnabled = true
        }
    }
    
    /**
     Returns the preferred statusbar style, this case Light(White)
     
     :returns: the statusbar style (White)
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
}

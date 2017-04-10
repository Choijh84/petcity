//
//  ComposableSearchRow.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 10..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Eureka

open class _ComposableSearchablePushRow<T: Equatable, Cell: CellType> : TableSelectorRow<Cell, ComposableSearchableViewController<T>> where Cell: BaseCell, Cell: TypedCellType, Cell.Value == ComposableSearchableItem<T>, T: SearchableItem, T: CustomStringConvertible {
    
    public required init(tag: String?) {
        super.init(tag: tag)
        onCreateControllerCallback = { [weak self] _ in
            let controller = ComposableSearchableViewController<T>()
            controller.searchPlaceholder = self?.searchPlaceholder
            return controller
        }
    }
    
    var searchPlaceholder: String?
}

/// Selector Controller (used to select one option among a list)
open class ComposableSearchableViewController<T:Equatable> : _ComposableSearchableViewController<T, ListCheckRow<ComposableSearchableItem<T>>, T> where T:SearchableItem, T: CustomStringConvertible  {
}

open class _ComposableSearchableViewController<T: Equatable, Row: SelectableRowType, TOriginal:Equatable> : UITableViewController, UISearchResultsUpdating, TypedRowControllerType where Row: BaseRow, Row: TypedRowType, Row.Cell.Value == ComposableSearchableItem<T>, T: SearchableItem, T: CustomStringConvertible, TOriginal: SearchableItem, TOriginal: CustomStringConvertible  {
    /// A closure to be called when the controller disappears.
    public var onDismissCallback: ((UIViewController) -> ())?
    
    open var row: RowOf<Row.Cell.Value>!
    let searchController = UISearchController(searchResultsController: nil)
    
    required public init() {
        super.init(style: .grouped)
        self.navigationItem.titleView = self.searchController.searchBar
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        self.definesPresentationContext = true
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    var originalOptions = [ComposableSearchableItem<T>]()
    var currentOptions = [ComposableSearchableItem<T>]()
    var searchPlaceholder: String?
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        searchController.searchBar.placeholder = searchPlaceholder
        //tableView!.tableHeaderView = searchController.searchBar
        if let options = row.dataProvider?.arrayData {
            self.originalOptions = options
            self.currentOptions = options
        }
        self.tableView.reloadData()
        if let composableItem = row.value {
            switch composableItem {
            case .composedQuery(let query):
                searchController.searchBar.text = query
            case .existingItem:
                if let index = currentOptions.index(of: composableItem) {
                    let indexPath = IndexPath(index: index)
                    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
                }
            }
        }
    }
    fileprivate func filter(_ query: String) {
        if query == "" {
            currentOptions = self.originalOptions
        } else {
            currentOptions = self.originalOptions.filter{ $0.matchesSearchQuery(query) }
            if currentOptions.isEmpty {
                currentOptions.append(ComposableSearchableItem<T>.composedQuery(query))
            }
        }
        self.tableView.reloadData()
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.row?.title
    }
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentOptions.count
    }
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = self.currentOptions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch(option) {
        case .composedQuery(let query):
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: "Otro: ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: UIFont.labelFontSize)]))
            text.append(NSAttributedString(string: query))
            cell.textLabel?.attributedText = text
        case .existingItem(let item):
            cell.textLabel?.text = item.description
        }
        return cell
    }
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = self.currentOptions[indexPath.row]
        row.value = option
        onDismissCallback?(self)
    }
    open func updateSearchResults(for searchController: UISearchController) {
        filter(searchController.searchBar.text!)
    }
}

public final class ComposableSearchablePushRow<T: Equatable> : _ComposableSearchablePushRow<T, PushSelectorCell<ComposableSearchableItem<T>>>, RowType where T: SearchableItem, T: CustomStringConvertible {
    public required init(tag: String?) {
        super.init(tag: tag)
    }
}

public enum ComposableSearchableItem<T:Equatable> : Equatable, CustomStringConvertible, SearchableItem where T: SearchableItem, T: CustomStringConvertible {
    case existingItem(T)
    case composedQuery(String)
    
    public var description: String {
        switch(self) {
        case .existingItem(let item):
            return item.description
        case .composedQuery(let query):
            return query
        }
    }
    public func matchesSearchQuery(_ query: String) -> Bool {
        switch(self) {
        case .existingItem(let item):
            return item.matchesSearchQuery(query)
        case .composedQuery(let q):
            return q == query
        }
    }
}
public func ==<T>(lhs: ComposableSearchableItem<T>, rhs: ComposableSearchableItem<T>) -> Bool {
    switch (lhs, rhs) {
    case let (.existingItem(l), .existingItem(r)):
        return l == r
    case let(.composedQuery(l), .composedQuery(r)):
        return l == r
    default:
        return false
    }
}


/// Generic row type where a user must select a value among several options.
open class TableSelectorRow<Cell: CellType, VCType: TypedRowControllerType>: OptionsRow<Cell> where Cell: BaseCell, VCType: UITableViewController, VCType.RowValue == Cell.Value {
    
    open var onCreateControllerCallback : ((FormViewController)->(VCType))?
    
    required public init(tag: String?) {
        super.init(tag: tag)
    }
    
    /**
     Extends `didSelect` method
     */
    open override func customDidSelect() {
        super.customDidSelect()
        if isDisabled {
            return
        }
        guard let createController = onCreateControllerCallback else {
            return
        }
        let controller = createController(cell.formViewController()!)
        prepareSelector(controller: controller)
        let formViewController = cell.formViewController()!
        formViewController.show(controller, sender: nil)
    }
    
    /**
     Prepares the pushed row setting its title and completion callback.
     */
    open override func prepare(for segue: UIStoryboardSegue) {
        super.prepare(for: segue)
        guard let controller = segue.destination as? VCType else { return }
        prepareSelector(controller: controller)
    }
    
    fileprivate func prepareSelector(controller: VCType) {
        controller.row = self
        controller.title = selectorTitle ?? controller.title
        controller.onDismissCallback = {vc in
            _ = vc.navigationController?.popViewController(animated: true)
        }
    }
}

public protocol SearchableItem {
    func matchesSearchQuery(_ query: String) -> Bool
}


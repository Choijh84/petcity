//
//  NewsListViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 1. 28..
//  Copyright © 2017년 press.S. All rights reserved.
//

import Foundation
import UIKit

/**
 * A viewcontroller that will display all the news objects
 */

class NewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate {
    
    /// Our List View
    @IBOutlet var tableView: LoadingTableView!
    
    /// Objects that needs to be displayed
    var newsArrayToDisplay: [News] = []
    
    /// The view on top, at the statusbar
    @IBOutlet var headerView: UIView!
    
    /// Refresh control to show the pull to refresh view
    var refreshControl: UIRefreshControl!
    
    /// Lazy getter for the dateFormatter
    lazy var dateFormatter: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()
    
    /** 
        Download the news objects 
     */
    func downloadNews() {
        let downloadNews = NewsDownloader()
        downloadNews.downloadNews { (news, error) in
            DispatchQueue.main.async(execute: { 
                if let newsArray = news {
                    self.newsArrayToDisplay = newsArray
                    self.refreshControl.endRefreshing()
                    self.tableView.hideLoadingIndicator()
                    self.tableView.reloadData()
                } else {
                    self.tableView.hideLoadingIndicator()
                    self.refreshControl.endRefreshing()
                }
            })
        }
    }
    
    /**
     Called after the view has been loaded, customize the view and set up the tableView to allow dynamic cell size
     */
    override func viewDidLoad() {
        headerView.backgroundColor = UIColor.globalTintColor()
        navigationController?.isToolbarHidden = true
        title = "공지사항"
        
        // set up the dynamic cell size
        tableView.estimatedRowHeight = 200.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // set up the refreshControl
        refreshControl = UIRefreshControl(frame: CGRect(x: 0.0, y: 0.0, width: tableView.frame.width, height: 44.0))
        refreshControl.tintColor = UIColor.globalTintColor()
        refreshControl.addTarget(self, action: #selector(NewsListViewController.loadContent), for: .valueChanged)
        refreshControl.attributedTitle = NSAttributedString(string: "Loading news")
        tableView.addSubview(refreshControl)
        
        loadContent()
        super.viewDidLoad()
    }
    
    /**
     Set the navigation controller's delegate to this controller and deselect a cell, if there is one selected
     
     :param: animated YES if to animate it
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.delegate = self
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }
    
    /**
     Set the navigation controller's delegate to nil when the view is about to disappear
     
     :param: animated YES if to animate it
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.delegate = nil
    }
    
    /**
        Download data and show the refresh control
     */
    
    func loadContent() {
        refreshControl.beginRefreshing()
        tableView.showLoadingIndicator()
        downloadNews()
    }
    
    /**
     Called when the user scrolls the view, and updates the cells to get the parallax effect
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleCells: [NewsTableViewCell] = tableView.visibleCells as! [NewsTableViewCell]
        for newsTableViewCell in visibleCells
        {
            let heightOfImageView: CGFloat = newsTableViewCell.thumbnailView.frame.height
            let yOffset: CGFloat = ((tableView.contentOffset.y - newsTableViewCell.frame.origin.y) / heightOfImageView) * 20.0
            newsTableViewCell.offsetImageView(CGPoint(x: 0.0, y: yOffset))
        }
    }
    
    // MARK: tableView methods
    /**
         Get the newsObject for the given indexPath and set the labels with the values
         
         :param: tableView the tableView
         :param: indexPath the indexPath
         
         :returns: the cell
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell") as! NewsTableViewCell
        
        let newsObject = newsArrayToDisplay[indexPath.row]
        cell.titleLabel.text = newsObject.title
        cell.descriptionTextLabel.text = newsObject.descriptionText
        cell.dateLabel.text = "Posted on: \(dateFormatter.string(from: newsObject.created! as Date))"
        
        if let imageURL = newsObject.imageURL() {
            cell.thumbnailView.hnk_setImage(from: imageURL)
        }
        
        return cell
    }
    
    /**
         Return how many rows the tableView should have
         
         :param: tableView the tableView
         :param: section   which section needs to work with
         
         :returns: how many rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArrayToDisplay.count
    }
    
    /**
     Called when a segue is about to be executed. Get the object for the given indexPath and pass it on to the detailView
     
     :param: segue  segue that has been called
     :param: sender which object triggered the segue
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newsDetailViewController = segue.destination as! NewsListDetailViewController
        
        let selectedCell = sender as! NewsTableViewCell
        let indexPath = tableView.indexPath(for: selectedCell)
        if let selectedIndexPath = indexPath
        {
            let selectedNewsObject = newsArrayToDisplay[selectedIndexPath.row]
            newsDetailViewController.newsObjectToDisplay = selectedNewsObject
        }
    }
    
    /**
     Return the tableViewCell for the passed in newsObject
     
     :param: newsObject the object which index is needed
     
     :returns: the cell
     */
    func tableViewCellForNewsObject(_ newsObject: News) -> NewsTableViewCell? {
        let newsObjectIndex = newsArrayToDisplay.index(of: newsObject)
        if newsObjectIndex == NSNotFound {
            return nil
        } else {
            return tableView.cellForRow(at: IndexPath(row: newsObjectIndex!, section: 0)) as? NewsTableViewCell
        }
    }
    
    /**
     Called to allow the delegate to return a noninteractive animator object for use during view controller transitions.
     
     :param: navigationController The navigation controller whose navigation stack is changing
     :param: operation            The type of transition operation that is occurring.
     :param: fromVC               The currently visible view controller.
     :param: toVC                 The view controller that should be visible at the end of the transition.
     
     :returns: The animator object responsible for managing the transition animations, or nil if you want to use the standard navigation controller transitions.
     */
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if fromVC == self && toVC.isKind(of: NewsListDetailViewController.self) {
            return NewsTransitionPresentAnimator()
        } else {
            return nil
        }
    }
    
    /**
     The preferred status bar style for the view controller.
     
     :returns: A UIStatusBarStyle key indicating your preferred status bar style for the view controller.
     */
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

}

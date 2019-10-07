//
//  ContentTableViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 02/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import Foundation

class ContentTableViewController: IBABaseUIViewController {
    
    var downloadedContent: [Content]!
    var currentContent: [Content]!
    var tableViewContent: [Content]!
    var refreshControl: UIRefreshControl!
    //var contentImageLocation = "https://ibamembersapp.ibanet.org/images/contentlibrary/"
    var contentImageLocation = Environment().baseURL + "images/contentlibrary/"
    
    @IBOutlet var contentTableView: UITableView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        //getContentForView()
        tableViewContent = []
        getContentForView()
        addPullToRefresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if segmentedControl.selectedSegmentIndex == 1 {
            downloadedContent = DataProvider.getDownloadedContent()
            tableViewContent = downloadedContent
            contentTableView.reloadData()
        }
        //showConfBubbleView()
    }
    
    func reloadDownloadedContent() {
        downloadedContent = DataProvider.getDownloadedContent()
        if segmentedControl.selectedSegmentIndex == 1 {
            tableViewContent = downloadedContent
        }
    }
    @IBAction func segmentedControlChange(_ sender: AnyObject) {
        downloadedContent = DataProvider.getDownloadedContent()

        switch segmentedControl.selectedSegmentIndex {
        case 0:
            tableViewContent = currentContent
            break
        case 1:
            tableViewContent = downloadedContent
            break
        default: break
        }
        contentTableView.reloadData()
    }
    
    @objc func getContentForView() {
        currentContent = []
        downloadedContent = []
        
        Networking.getContent("", success: { (results) in
            self.currentContent = Content.createContentFromContentLibraryResponseModel(results)
            if self.segmentedControl.selectedSegmentIndex == 0 {
                self.tableViewContent = self.currentContent
                self.contentTableView.reloadData()
                self.selectFirstCellIfDetailViewShowing()
                self.refreshControl.endRefreshing()
            }
        }) { (error) in
            print("Failed to get content")
            self.refreshControl.endRefreshing()
            
        }
        downloadedContent = DataProvider.getDownloadedContent()
        if segmentedControl.selectedSegmentIndex == 1 {
            tableViewContent = downloadedContent
            self.refreshControl.endRefreshing()
        } else {
            tableViewContent = currentContent
        }
    }
}

extension ContentTableViewController {
    //MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showContentDetailSegue"
        {
            
            //the destinationViewController is a UINavigationController for iOS 8 and is the ProfileViewController for iOS7 - so check class before using to prevent crash.
            let destinationViewController: UIViewController = segue.destination
            var contentDetailViewController : ContentDetailViewController!
            
            if destinationViewController.isKind(of: UINavigationController.self)
            {
                let navController = destinationViewController as! ContentNavController
                let contentStoryboard = UIStoryboard(name: "ContentMessagesStoryboard", bundle: nil)
                contentDetailViewController = contentStoryboard.instantiateViewController(withIdentifier: "ContentMessgesStoryboard") as! ContentDetailViewController
                navController.setViewControllers([contentDetailViewController], animated: false)
            }
            else if destinationViewController.isKind(of: ContentDetailViewController.self)
            {
                contentDetailViewController = destinationViewController as! ContentDetailViewController
            }
            
            if contentDetailViewController != nil
            {
                let cell : UITableViewCell = (sender as? UITableViewCell)!
                let indexPath = contentTableView.indexPath(for: cell)
                let content : Content = tableViewContent![indexPath!.row] as Content
                contentDetailViewController.content = content
                contentDetailViewController.detailDelegate = self
                
                //pass the master view button for when we segue to new detail view in portrait iPad
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    let navigationController = splitViewController!.viewControllers[1] as! UINavigationController
                    let previousViewController = navigationController.viewControllers[0] as? UIViewController
                    contentDetailViewController.navigationItem.leftBarButtonItem = previousViewController!.navigationItem.leftBarButtonItem
                }
            }
        }
    }
    
    func selectFirstCellIfDetailViewShowing()
    {
        //only perform segue if both views on screen
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            return
        }
        if tableViewContent != nil && tableViewContent!.count > 0
        {
            let firstIndexPath = IndexPath(row: 0, section: 0)
            contentTableView.selectRow(at: firstIndexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            if let cell = contentTableView.cellForRow(at: firstIndexPath) {
                performSegue(withIdentifier: "showContentDetailSegue", sender: cell)
            }
        }
        else
        {
            //performSegue(withIdentifier: "showNoMembersView", sender: self)
        }
    }
    
}

extension ContentTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableViewContent.count > 0 {
        let content = tableViewContent[indexPath.row]
        if content.featured == 1 {
            let featuredContentCell : FeaturedContentCell = tableView.dequeueReusableCell(withIdentifier: "FeaturedContentCell") as! FeaturedContentCell
            
            featuredContentCell.featuredTitle.text = content.title as String
            featuredContentCell.featuredType.text = content.contentType.toString()
            featuredContentCell.createdTimeAgo.text = content.dateCreated.toTimeString("dd/MM/yyyy")
            if content.thumbnailData != nil {
                featuredContentCell.featuredImage.image = UIImage(data: content.thumbnailData as Data)
            } else {
                if content.thumbnailURL != nil  {
                
                featuredContentCell.featuredImage.image = UIImage(named: "image_placeholder")
                featuredContentCell.featuredImage.contentMode = .scaleAspectFill
                featuredContentCell.featuredImage.downloadImageFrom(link: "\(contentImageLocation)\(content.thumbnailURL!)", contentMode: .scaleAspectFill, completion: { (imageData) in
                    content.thumbnailData = imageData
                })
                } else {
                    featuredContentCell.featuredImage.image = UIImage(named: "image_placeholder")
                }
            }
            if Date().daysFrom(content.dateCreated) > 0 {
                featuredContentCell.createdTimeAgo.text = content.dateCreated.toTimeString("dd/MM/yyyy")
            } else {
                featuredContentCell.createdTimeAgo.text = Date().offsetFrom(content.dateCreated)
            }
            featuredContentCell.featuredTypeImage.image = UIImage(named: content.contentType.getImageSrc())
            return featuredContentCell
        } else {
            let contentCell: ContentViewCell = tableView.dequeueReusableCell(withIdentifier: "ContentViewCell") as! ContentViewCell
                contentCell.contentTitle.text = content.title as String
                contentCell.contentType.text = content.contentType.toString()
            if content.thumbnailData != nil {
                contentCell.contentImage.image = UIImage(data: content.thumbnailData as Data)
                contentCell.contentImage.contentMode = .scaleAspectFill
            } else {
                if content.thumbnailURL != nil  {

                contentCell.contentImage.image = UIImage(named: "image_placeholder")
                contentCell.contentImage.contentMode = .scaleAspectFill
                contentCell.contentImage.downloadImageFrom(link: "\(contentImageLocation)\(content.thumbnailURL!)", contentMode: .scaleAspectFill, completion: { (imageData) in
                    content.thumbnailData = imageData
                })
                } else {
                    contentCell.contentImage.image = UIImage(named: "image_placeholder")
                }
            }
            
            if Date().daysFrom(content.dateCreated) > 0 {
                contentCell.contentUpdatedTimeAgo.text = content.dateCreated.toTimeString("dd/MM/yyyy")
            } else {
                contentCell.contentUpdatedTimeAgo.text = Date().offsetFrom(content.dateCreated)
            }
            contentCell.contentTypeImage.image = UIImage(named: content.contentType.getImageSrc())
            return contentCell
        }
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewContent.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row > tableViewContent.count - 1 {
            return 0
        }
        let content = tableViewContent[indexPath.row]
        if content.featured == 1 {
            return 280
        } else
        {
            return 120
        }
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = contentTableView.cellForRow(at: indexPath) {
            performSegue(withIdentifier: "showContentDetailSegue", sender: cell)
        }
    }
    
    func addPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refreshControl.addTarget(self, action: #selector(getContentForView), for: .valueChanged)
        contentTableView.addSubview(refreshControl)
    }

}

extension ContentTableViewController: ContentDetailDelegate {
    func didDeleteItem(_ id: Int,content: Content) {
        var index = 0
        for var item in currentContent {
            
            if item.contentId == id as NSNumber{
                break
            }
            index += 1
        }
        
        currentContent.remove(at: index)
        currentContent.insert(content, at: index)
        reloadDownloadedContent()
        contentTableView.reloadData()
    }
    
    func didDownloadItem() {
        reloadDownloadedContent()
        contentTableView.reloadData()
    }
}



//
//  ContentDetailViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 03/08/2016.
//  Copyright © 2016 Compsoft plc. All rights reserved.
//

import UIKit
import AVFoundation

protocol ContentDetailDelegate {
    func didDeleteItem(_ id: Int,content: Content)
    func didDownloadItem()
}

class ContentDetailViewController: UIViewController {
    //var contentImageLocation = "https://ibamembersapp.ibanet.org/images/contentlibrary/"
    
    var content: Content!
    var lastOffsetValue = CGFloat(0)
    var revealImageHeight = CGFloat(66)
    var scrollToHeight = CGFloat(66)
    var parentNav: UINavigationController!
    var originalBarTintColour: UIColor!
    var contentIsPlaying:Bool = false
    var playButtonIsDocked: Bool = false
    var minPlayButtonOffset = CGFloat(5)
    var minMediaPlayerOffset = CGFloat(0)
    var startPlaybackOffset = CGFloat(100)
    var avPlayer: AVAudioPlayer!
    var greyedBackgroundOffset = CGFloat(50)
    var tableDiffIfNotBigEnough: CGFloat! = CGFloat(0)
    var detailDelegate: ContentDetailDelegate!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var contentImageView: UIImageView!
    @IBOutlet var featuredContentTableView: UITableView!
    @IBOutlet var overlayView: UIView!
    @IBOutlet var playbackButtonConstraint: NSLayoutConstraint!
    @IBOutlet var playbackButton: UIButton!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageContainingViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var imageContainingViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var featuredTableViewConstraint: NSLayoutConstraint!
    @IBOutlet var mediaControlsConstraint: NSLayoutConstraint!
    @IBOutlet var playbackBar: UISlider!
    @IBOutlet var startTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var mediaContainingView: UIView!
    @IBOutlet var saveContentLocallyButton: UIBarButtonItem!
    @IBOutlet weak var greyedBackgroundConstraint: NSLayoutConstraint!
    
    var contentIsDownloadingDeleting: Bool! = false
    
    var mediaControlsLimit = CGFloat(90)
    
    @IBOutlet var playbackBarConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()
    }
    
    @IBAction func viewArticle(_ sender: AnyObject) {
        print("View Article")
        self.performSegue(withIdentifier: "showContentWebView", sender: self)
    }
    
    @IBAction func saveContentLocally(_ sender: AnyObject) {
        if !contentIsDownloadingDeleting {
            if sender.tag! == 0 {
                if content.additionalData == nil {
                    contentIsDownloadingDeleting = true
                    checkForWifiAndDownloadData(true)
                } else {
                    if content.commit() {
                    contentIsDownloadingDeleting = false
                    saveContentLocallyButton.tag = 1
                    saveContentLocallyButton.image = UIImage(named: "delete")
                    detailDelegate.didDownloadItem()
                    }
                }
            } else {
                if content.id != NSNull() {
                    contentIsDownloadingDeleting = true
                  
                    if content.remove() {
                        let newContent = content.copyItemToNewContent()
                        detailDelegate.didDeleteItem(newContent.contentId as! Int, content:newContent)
                        content = newContent
                        contentIsDownloadingDeleting = false
                        saveContentLocallyButton.tag = 0
                        saveContentLocallyButton.image = UIImage(named: "download_content")
                    } else {
                        contentIsDownloadingDeleting = false
                        print("Failed to delete")
                    }
                }
            }
        }
    }
    
    @IBAction func sliderChanged(_ sender: AnyObject) {
        if let player = avPlayer {
            player.currentTime = TimeInterval(playbackBar.value)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showContentWebView" {
            let destination = segue.destination as! UINavigationController
            if let vc = destination.childViewControllers[0] as? ContentDetailWebViewController {
                vc.content = self.content
            }
        }
    }
    
    @objc func updateTime (_ timer: Timer) {
        playbackBar.value = Float(avPlayer.currentTime)
        startTime.text = avPlayer.currentTime.toString()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let player = avPlayer {
            player.stop()
        }
    }
    
    func setupAVPlayer(_ data: Data) -> Bool {
        do {
            self.avPlayer = try AVAudioPlayer(data: data)
            self.avPlayer.delegate = self
            self.avPlayer.prepareToPlay()
            self.endTime.text = self.avPlayer.duration.toString()
            self.playbackBar.isContinuous = true
            self.playbackBar.maximumValue = Float(self.avPlayer.duration)
            self.playbackButton.alpha = 1.0
            return true
        } catch _ as NSError {
            print("Audio failed")
            return false
        }
    }
    
    func downloadNeededData(_ shouldCommitOnDownload: Bool = false, playOnCompletion: Bool = false) {
        
        loadingIndicator.startAnimating()
        playbackButton.alpha = 0.0
        loadingIndicator.alpha = 1.0
        if let url = URL(string: content.url as String) {
            URLSession.shared.dataTask(with: url, completionHandler:  {(data, response, error) -> Void in
                DispatchQueue.main.async(execute: {
                    print("Finished Downloading")
                    self.loadingIndicator.stopAnimating()
                    if self.content.contentType == ContentType.film || self.content.contentType == ContentType.podcast {
                        self.playbackButton.alpha = 1.0
                    }
                    
                    if let data = data {
                        self.content.additionalData = data
                        self.content.mimeType = response?.mimeType as NSString!
                        if shouldCommitOnDownload {
                            self.content.commit()
                            self.saveContentLocallyButton.tag = 1
                            self.saveContentLocallyButton.image = UIImage(named: "delete")
                        }
                        self.contentIsDownloadingDeleting = false
                        if self.content.contentType == .podcast {
                            if self.setupAVPlayer(data) && playOnCompletion {
                                self.playPauseAudio()
                            }
                        }
                    }
                })
            }).resume()
        }
    }
    
    func checkForWifiAndDownloadData(_ shouldCommitOnDownload: Bool = false) {
        if !checkForWifi() {
            let alert = UIAlertController(title: DATA_WARNING_TITLE, message: DATA_WARNING_TEXT, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Got It!", style: .default, handler: { (action) in
                self.downloadNeededData(shouldCommitOnDownload)
            }))
            alert.addAction(UIAlertAction(title: "Don't Download!", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            
        } else {
            downloadNeededData(shouldCommitOnDownload)
        }
    }
    
    func setupView() {
        switch content.contentType! {
        case .article:
            featuredTableViewConstraint.constant = 0
            revealImageHeight = CGFloat(0)
            playbackButton.alpha = 0
            mediaContainingView.alpha = 0
            break
        case .film:
            mediaContainingView.alpha = 0
            saveContentLocallyButton.tintColor = UIColor.clear
            saveContentLocallyButton.isEnabled = false
            break
        case .podcast:
            mediaContainingView.alpha = 1
            playbackButton.alpha = 1
            if content.additionalData != nil {
                setupAVPlayer(content.additionalData as Data)
            }
            break
        }
        
        if let id = content.id {
            if id != NSNull() {
                saveContentLocallyButton.image = UIImage(named: "delete")
                saveContentLocallyButton.tag = 1
            }
        }
        
        if UIDevice.current.userInterfaceIdiom != .pad
        {
            if let parentVC = self.parent {
                if let parentNav = parentVC.navigationController {
//                    originalBarTintColour = parentNav.navigationBar.barTintColor
//                    parentNav.navigationBar.setBackgroundImage(UIImage(), for: .default)
//                    parentNav.navigationBar.shadowImage = UIImage()
//                    parentNav.navigationBar.isTranslucent = true
//                    parentNav.navigationBar.backItem?.title = "IBA Digital Content"
                    self.parentNav = parentNav
                }
            }
            scrollToHeight = 66
            mediaControlsLimit = CGFloat()
            imageContainingViewTopConstraint.constant = -66
            if content.contentType != .article {
                featuredTableViewConstraint.constant = -40
            }
            
            revealImageHeight = CGFloat(0)
            mediaControlsLimit = CGFloat(40)
            
            
        } else {
            //playbackButtonConstraint.constant += playbackButton.frame.height / 2
            //startPlaybackOffset = playbackButtonConstraint.constant
            minPlayButtonOffset = 66
            minMediaPlayerOffset = 50
            playbackBarConstraint.constant = 0
        }
        if content.thumbnailData != nil {
            contentImageView.image = UIImage(data: content.thumbnailData as Data)
        } else {
            if content.thumbnailURL != nil  {
                contentImageView.downloadImageFrom(link: "\(CONTENT_IMAGE_LOCATION)\(content.thumbnailURL!)", contentMode: .scaleToFill) { (imageData) in
                    self.content.thumbnailData = imageData
                }
            }
            
        }
        
        
        loadingIndicator.alpha = 0
        loadingIndicator.hidesWhenStopped = true
    }
    
    func checkForWifi() -> Bool{
        let reachability = Reachability.forInternetConnection()
        let networkStatus = reachability?.currentReachabilityStatus().rawValue
        if networkStatus != ReachableViaWiFi.rawValue
        {
            return false
        } else {
            return true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupView()
        featuredContentTableView.reloadData()
        
    }
    
    @IBAction func navbarPlayButtonHit(_ sender: AnyObject) {
        if playButtonIsDocked {
            playButtonHit(sender)
        }
    }
    
    @IBAction func playButtonHit(_ sender: AnyObject) {
        switch content.contentType! {
        case .film:
            self.performSegue(withIdentifier: "showContentWebView", sender: self)
            break
        case .podcast:
            if content.additionalData != nil {
                playPauseAudio()
            } else {
                downloadNeededData(false, playOnCompletion: true)
            }
            break
        default:
            break
        }
    }
    
    func playPauseAudio() {
        contentIsPlaying = !contentIsPlaying
        if contentIsPlaying {
            playbackButton.setImage(UIImage(named: "pause_content_icon"), for: UIControlState())
            avPlayer.play()
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime(_:)), userInfo: nil, repeats: true)
        } else {
            playbackButton.setImage(UIImage(named: "play_content_icon"), for: UIControlState())
            avPlayer.pause()
        }
    }
}

extension ContentDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func setupTableView() {
        featuredContentTableView.rowHeight = UITableViewAutomaticDimension
        featuredContentTableView.estimatedRowHeight = 150
        featuredContentTableView.contentInset.top = imageContainingViewHeightConstraint.constant - revealImageHeight
        mediaControlsConstraint.constant = imageContainingViewHeightConstraint.constant - (revealImageHeight - minMediaPlayerOffset)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentDetailHeaderViewCell") as! ContentDetailHeaderViewCell
            cell.contentDetailTitle.text = content.title as String
            cell.contentDetailTypeImage.image = UIImage(named: content.contentType.getImageSrc())
            cell.contentDetailType.text = content.contentType.toString()
            if Date().daysFrom(content.dateCreated) > 0 {
                cell.contentDetailTimeCreated.text = content.dateCreated.toTimeString("dd/MM/yyyy")
            } else {
                cell.contentDetailTimeCreated.text = Date().offsetFrom(content.dateCreated)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContentDetailViewCell") as! ContentDetailViewCell
            cell.contentDetailBody.text = (content.precis as String)
            if content.contentType != .article {
                cell.viewArticleButton.alpha = 0
            }
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
          
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

extension ContentDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offset = scrollView.contentOffset.y
        print(lastOffsetValue - offset)
        
        var imageViewTansform = CATransform3DIdentity
        
        if lastOffsetValue != 0  {
            if lastOffsetValue < offset {

            } else {
                if offset < scrollToHeight - 166 {
                    playButtonIsDocked = false
                }
            }
        }
        if offset <= -200 + revealImageHeight {
            //Pulling down
            
            let headerScaleFactor:CGFloat = -(offset) / contentImageView.bounds.height / 1.8
            let headerSizevariation = ((contentImageView.bounds.height * (1.0 + headerScaleFactor)) - contentImageView.bounds.height)/2.0
            imageViewTansform = CATransform3DTranslate(imageViewTansform, 0, headerSizevariation, 0)
            imageViewTansform = CATransform3DScale(imageViewTansform, 1.0 + headerScaleFactor, 1.0 + headerScaleFactor, 0)
            contentImageView.layer.transform = imageViewTansform
            
            
        } else {
            if offset < scrollToHeight {
                let current = contentImageView.layer.transform
                imageViewTansform = CATransform3DTranslate(current, 0, (lastOffsetValue - offset)/4, 0)
                contentImageView.layer.transform = imageViewTansform
                
            }
        }
        if lastOffsetValue < offset {
            
            if mediaControlsConstraint.constant + lastOffsetValue - offset > minMediaPlayerOffset {
                mediaControlsConstraint.constant = -offset + minMediaPlayerOffset
                greyedBackgroundConstraint.constant =  -offset + minMediaPlayerOffset + greyedBackgroundOffset
            } else {
                mediaControlsConstraint.constant =  minMediaPlayerOffset
                greyedBackgroundConstraint.constant = minMediaPlayerOffset + greyedBackgroundOffset
            }

            if mediaControlsConstraint.constant < mediaControlsLimit {
                if -offset >= -5 {
                    playbackButtonConstraint.constant =  -offset //+ minMediaPlayerOffset
                } else {
                    playbackButtonConstraint.constant = -5
                    playButtonIsDocked = true
                }
            }
        }
        else {
            if offset < scrollToHeight - 60{
                
                mediaControlsConstraint.constant  = -offset + minMediaPlayerOffset
                 greyedBackgroundConstraint.constant =  -offset + minMediaPlayerOffset + greyedBackgroundOffset
            }

            if mediaControlsConstraint.constant > minMediaPlayerOffset {
                if -offset < 70  {
                    self.playbackButtonConstraint.constant =  -offset //+ self.minMediaPlayerOffset
                } else {
                    self.playbackButtonConstraint.constant = 70
                }
            }
        }
       
        lastOffsetValue = offset
    }
}

extension ContentDetailViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.prepareToPlay()
        playbackButton.setImage(UIImage(named: "play_content_icon"), for: UIControlState())
        contentIsPlaying = false
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?){
        
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        
    }
}

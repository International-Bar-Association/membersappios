//
//  TestViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 28/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

class TestViewController: UIViewController {
    
    @IBOutlet weak var collectionView: CCMessagesCollectionView!
    var senderDisplayName: String?
    var senderId: String?
    var messageThread: P2PMessageThread!
    var messages: [P2PMessage]!
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.messageDataSource = self
        collectionView.delegate = self
        collectionView.ccDelegate = self
        messageThread = P2PMessageThread.query().fetch()[0] as! P2PMessageThread
        messages = messageThread.getMessages()
        collectionView.reloadData()
    }
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor(red:0.11, green:0.17, blue:0.47, alpha:1.00))
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor(red:0.94, green:0.94, blue:0.94, alpha:1.00))
    }
    
}

extension TestViewController: CCMessagesCollectionViewDataSource {
    func collectionView(collectionView: CCMessagesCollectionView, messageDataForItemAtIndexPath indexPath: IndexPath) -> CCMessageData? {
        
        return messages[indexPath.row]
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource? {
        let message = messages[indexPath.item] // 1
        if message.senderId() == senderId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let ccCollectionView = collectionView as? CCMessagesCollectionView else {
            fatalError()
        }
        
        let message = messages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CCMessagesIncomingCollectionViewCell.cellReuseIdentifier(), for: indexPath) as! CCMessagesIncomingCollectionViewCell
        
        let imageData = ccCollectionView.messageDataSource?.collectionView!(collectionView: ccCollectionView, messageBubbleImageDataForItemAt: indexPath)
        if message.senderId() == self.senderId {
            cell.textView!.textColor = UIColor.white
        }
        else {
            cell.textView!.textColor = UIColor(red:0.12, green:0.18, blue:0.48, alpha:1.00)
        }
        cell.textView?.text = message.text()
        cell.messageBubbleImageView?.image = imageData?.messageBubbleImage()
        return cell
        
    }
    
    

}

extension TestViewController: CCMessagesCollectionViewDelegateFlowLayout,UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let ccFlow = collectionViewLayout as? CCMessageCollectionViewFlowLayout else {
            return CGSize(width: 0, height: 0)
        }
        return ccFlow.sizeForItem(at: indexPath)
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, layout collectionViewLayout: CCMessageCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, layout collectionViewLayout: CCMessageCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat {
        return 0.0
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) {
        
    }
    
    func collectionView(collectionView: CCMessagesCollectionView, didTapMessageBubbleAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("nope")
    }
}

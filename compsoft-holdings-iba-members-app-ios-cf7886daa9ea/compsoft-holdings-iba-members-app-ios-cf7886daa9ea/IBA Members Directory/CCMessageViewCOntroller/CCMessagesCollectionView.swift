//
//  CCMessagesCollectionView.swift
//  IBA Members Directory
//
//  Created by George Smith on 25/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class CCMessagesCollectionView: UICollectionView {
    
    public var messageDataSource: CCMessagesCollectionViewDataSource?
    public var ccDelegate: CCMessagesCollectionViewDelegateFlowLayout?
 
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupView()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private func setupView() {
        
        self.backgroundColor = UIColor.white
        self.keyboardDismissMode = .none
        self.alwaysBounceVertical = true
        self.bounces = true
        
//        self.register(CCMessagesIncomingCollectionViewCell.self, forCellWithReuseIdentifier: CCMessagesIncomingCollectionViewCell.cellReuseIdentifier())
//        self.register(CCMessagesOutgoingCollectionViewCell.self, forCellWithReuseIdentifier: CCMessagesOutgoingCollectionViewCell.cellReuseIdentifier())
        
        self.register(UINib(nibName: "CCMessagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CCMessagesIncomingCollectionViewCell.cellReuseIdentifier())
    }
}

extension CCMessagesCollectionView: CCMessagesCollectionViewCellDelegate {
    func messagesCollectionViewCell(_ cell: CCMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: Any) {
        guard self.indexPath(for: cell) != nil else {
            return
        }
        if self.delegate as? CCMessagesCollectionViewDelegateFlowLayout != nil {
            print("NOT IMPLEMENTED")
        }
    }
    
    func messagesCollectionViewCellDidTap(_ cell: CCMessagesCollectionViewCell, atPosition position: CGPoint) {
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }
        if let delegate = self.delegate as? CCMessagesCollectionViewDelegateFlowLayout {
            delegate.collectionView!(collectionView: self, didTapCellAt: indexPath, touchLocation: position)
        }
    }
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: CCMessagesCollectionViewCell) {
        guard let indexPath = self.indexPath(for: cell) else {
            return
        }
        if let delegate = self.delegate as? CCMessagesCollectionViewDelegateFlowLayout {
            delegate.collectionView!(collectionView: self, didTapMessageBubbleAt: indexPath)
        }
    }
    
    func messagesCollectionViewCellDidTapAvatar(_ cell: CCMessagesCollectionViewCell) {
        guard self.indexPath(for: cell) != nil else {
            return
        }
        if self.delegate as? CCMessagesCollectionViewDelegateFlowLayout != nil {
            print("NOT IMPLEMENTED")
        }
    }
}



/// An object that adopts the CCMessagesCollectionViewDataSource protocol provides the data and the views required by a CCMessagesCollectionView. The object represents your apps messaging data model and supplys information to the collection view as needed.
@objc protocol CCMessagesCollectionViewDataSource: UICollectionViewDataSource {
    
    var senderDisplayName: String? {get set}
    var senderId: String? {get set}
    
    
    /// Notifies the datasource for the message data that corresponds to item at indexPath in collectionView.
    ///
    /// - Parameters:
    ///   - collectionView: CCMessageCollectionView requesting the information
    ///   - messageDataForItemAtIndexPath: The messagedata for the item at the specific index path
    /// - Returns: Returns the message data for that item.
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, messageDataForItemAtIndexPath indexPath: IndexPath) -> CCMessageData?
    
    /// Asks the data source to display in the cellTopLabel for the specified message data at indexPath.
    ///
    /// - Parameters:
    ///   - collectionView: CCMessageCollectionView requesting the information
    ///   - attributedTextForCellTopLabelAtIndexPath: The index path that specifies the loacation of the item
    /// - Returns: An attributed string or nil if you do not want text displayed for the item at indexPath
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, attributedTextForCellTopLabelAt indexPath: IndexPath) -> NSAttributedString?
    
    /// Asks the data source to display in the cellBottomLabel for the specified message data at indexPath.
    ///
    /// - Parameters:
    ///   - collectionView: CCMessageCollectionView requesting the information
    ///   - attributedTextForCellBottomLabelAtIndexPath: The index path that specifies the loacation of the item
    /// - Returns: An attributed string or nil if you do not want text displayed for the item at indexPath
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, attributedTextForCellBottomLabelAt indexPath: IndexPath) -> NSAttributedString?
    
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, messageBubbleImageDataForItemAt indexPath: IndexPath) -> JSQMessageBubbleImageDataSource?
}


@objc protocol CCMessageData: NSObjectProtocol {

    @objc optional func senderId() -> String!

    @objc optional func senderDisplayName() -> String!

    @objc optional func date() -> Date!
    
    @objc optional func messageHash() -> UInt

    @objc optional func text() -> String!
    

}

@objc protocol CCMessagesCollectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout {
    
    
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, layout collectionViewLayout: CCMessageCollectionViewFlowLayout, heightForCellAt indexPath: IndexPath) -> CGFloat
    
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, layout collectionViewLayout: CCMessageCollectionViewFlowLayout, heightForMessageBubbleTopLabelAt indexPath:IndexPath) -> CGFloat
    
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, layout collectionViewLayout: CCMessageCollectionViewFlowLayout, heightForCellBottomLabelAt indexPath: IndexPath) -> CGFloat
    
    @objc optional func collectionView(collectionView: CCMessagesCollectionView,  didTapMessageBubbleAt indexPath: IndexPath) -> Void
    
    @objc optional func collectionView(collectionView: CCMessagesCollectionView, didTapCellAt indexPath: IndexPath, touchLocation: CGPoint) -> Void
    
}

protocol CCMessagesCollectionViewCellDelegate: NSObjectProtocol {
    func messagesCollectionViewCellDidTapAvatar(_ cell: CCMessagesCollectionViewCell)
    
    func messagesCollectionViewCellDidTapMessageBubble(_ cell: CCMessagesCollectionViewCell)
    
    func messagesCollectionViewCellDidTap(_ cell: CCMessagesCollectionViewCell, atPosition position: CGPoint)
    
    func messagesCollectionViewCell(_ cell: CCMessagesCollectionViewCell, didPerformAction action: Selector, withSender sender: Any)
}


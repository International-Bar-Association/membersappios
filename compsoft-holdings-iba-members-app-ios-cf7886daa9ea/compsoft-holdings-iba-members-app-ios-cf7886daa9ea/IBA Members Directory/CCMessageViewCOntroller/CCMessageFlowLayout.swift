//
//  CCMessageFlowLayout.swift
//  IBA Members Directory
//
//  Created by George Smith on 27/07/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import Foundation
import UIKit

open class CCMessageCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: - Properties
    
    open var messageFont: UIFont
    
    open var messageContainerInsets: UIEdgeInsets
    
    fileprivate var itemWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        return collectionView.frame.width - sectionInset.left - sectionInset.right
    }
    
    override open class var layoutAttributesClass: AnyClass {
        return CCMessageCollectionViewLayoutAttributes.self
    }
    
    // MARK: - Initializers
    
    override public init() {
        messageFont = UIFont.preferredFont(forTextStyle: .body)
        messageContainerInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        super.init()
        sectionInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    }
    
    required public init?(coder aDecoder: NSCoder) {
       
        messageFont = UIFont.preferredFont(forTextStyle: .body)
        messageContainerInsets = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        super.init(coder: aDecoder)
        sectionInset = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
        
    }
    
    // MARK: - Methods
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        guard let attributesArray = super.layoutAttributesForElements(in: rect) as? [CCMessageCollectionViewLayoutAttributes] else { return nil }
        
        attributesArray.forEach { attributes in
            if attributes.representedElementCategory == UICollectionElementCategory.cell {
                configure(attributes: attributes)
            }
        }
        
        return attributesArray
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        guard let attributes = super.layoutAttributesForItem(at: indexPath) as? CCMessageCollectionViewLayoutAttributes else { return nil }
        
        if attributes.representedElementCategory == UICollectionElementCategory.cell {
            configure(attributes: attributes)
        }
        
        return attributes
        
    }
    
    private func configure(attributes: CCMessageCollectionViewLayoutAttributes) {
        
        guard let collectionView = collectionView as? CCMessagesCollectionView, let dataSource = collectionView.dataSource as? CCMessagesCollectionViewDataSource else { return }
        
        let indexPath = attributes.indexPath
        let message = dataSource.collectionView!(collectionView: collectionView, messageDataForItemAtIndexPath: indexPath)
        
        let direction: MessageDirection = dataSource.senderId == message?.senderId!() ? .outgoing : .incoming
        let messageContainerSize = containerSizeFor(message: message!)
        
        attributes.direction = direction
        attributes.messageFont = messageFont
        attributes.messageContainerSize = messageContainerSize
        attributes.messageContainerInsets = messageContainerInsets
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        
        return collectionView?.bounds.width != newBounds.width
        
    }
    
}

extension CCMessageCollectionViewFlowLayout {

    func minimumCellHeightFor(message: CCMessageData) -> CGFloat {
        
        guard let collectionView = collectionView as? CCMessagesCollectionView , let dataSource = collectionView.dataSource as? CCMessagesCollectionViewDataSource else { return 0 }
        
        let messageDirection: MessageDirection = dataSource.senderId == message.senderId!() ? .outgoing : .incoming
        
        return 0
    }
    
    func containerHeightForMessage(message: CCMessageData) -> CGFloat {
        
        let avatarSize = 0
        var insets = messageContainerInsets.left + messageContainerInsets.right
        let availableWidth = itemWidth - insets
    
        let text = message.text!()!
        let estimatedHeight = text.height(considering: availableWidth, and: messageFont)
        insets = messageContainerInsets.top + messageContainerInsets.bottom
        return estimatedHeight.rounded(.up) + insets //+ 1
    }
    
    func containerWidthForMessage(message: CCMessageData) -> CGFloat {
        
        let containerHeight = containerHeightForMessage(message: message)
        
        let avatarSize = 0
        var insets = messageContainerInsets.left + messageContainerInsets.right
        let availableWidth = itemWidth - insets

        let text = message.text!()!
        let estimatedWidth = text.width(considering: containerHeight, and: messageFont).rounded(.up)
        insets = messageContainerInsets.left + messageContainerInsets.right
        let finalWidth = estimatedWidth > availableWidth ? availableWidth : estimatedWidth
        return finalWidth + insets
        
        
    }
    
    func estimatedCellHeightForMessage(message: CCMessageData) -> CGFloat {
        
        let messageContainerHeight = containerHeightForMessage(message: message)
        return messageContainerHeight
        
    }
    
    func containerSizeFor(message: CCMessageData) -> CGSize {
        
        let containerHeight = containerHeightForMessage(message: message)
        let containerWidth = containerWidthForMessage(message: message)
        
        return CGSize(width: containerWidth, height: containerHeight)
        
    }
    

    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        
        guard let collectionView = collectionView as? CCMessagesCollectionView, let dataSource = collectionView.dataSource as? CCMessagesCollectionViewDataSource else { return .zero }
        
       let message = dataSource.collectionView!(collectionView: collectionView, messageDataForItemAtIndexPath: indexPath)
        
        let minHeight = minimumCellHeightFor(message: message!)
        let estimatedHeight = estimatedCellHeightForMessage(message: message!)
        let actualHeight = estimatedHeight < minHeight ? minHeight : estimatedHeight
        
        return CGSize(width: itemWidth, height: actualHeight)
        
    }
}



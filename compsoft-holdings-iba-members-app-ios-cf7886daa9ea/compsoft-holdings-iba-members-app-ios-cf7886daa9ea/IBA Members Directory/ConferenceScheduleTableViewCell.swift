//
//  ConferenceScheduleTableViewCell.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit

protocol EventActionDelegate {
    func didTapGetDirections()
    func didTapAddToCalender(event: Event)
}

class ConferenceScheduleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var floorLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var addToCalenderButton: UIButton!
    
    var event: Event!
    var delegate: EventActionDelegate!
    
    func createItem(event: Event) {
        self.roundedBackgroundView.backgroundColor = event.status.backgroundColourForState()
        self.timeLabel.textColor = event.status.headerTextColourForState()
        self.floorLabel.textColor = event.status.bodyTextColourForState()
        self.detailLabel.textColor = event.status.bodyTextColourForState()
        
        self.timeLabel.text = event.prettyEventTimeString as String
        self.floorLabel.text = "\(event.roomName!)"
        self.detailLabel.text = event.title as String
        self.event = event
        
    }
    
    override func awakeFromNib() {
        self.roundedBackgroundView.clipsToBounds = true
        self.roundedBackgroundView.layer.cornerRadius = self.frame.height / 15
        self.roundedBackgroundView.layer.borderColor = UIColor.clear.cgColor
        self.roundedBackgroundView.layer.borderWidth = CGFloat(1)
        self.backgroundColor = UIColor.clear
        
        self.contentView.backgroundColor = UIColor.clear
    }
    
    override func prepareForReuse() {
        self.roundedBackgroundView.backgroundColor = UIColor.white
        self.addToCalenderButton.tintColor = UIColor.init(hex: "222222")
    }
    
    func selectItem() {
        event.status = .selected
        self.roundedBackgroundView.backgroundColor = event.status.backgroundColourForState()
        self.timeLabel.textColor = event.status.headerTextColourForState()
        self.floorLabel.textColor = event.status.bodyTextColourForState()
        self.detailLabel.textColor = event.status.bodyTextColourForState()
        self.addToCalenderButton.tintColor = UIColor.white

    }
    
    func unselectItem() {
        event.status = .scheduled
        self.roundedBackgroundView.backgroundColor = event.status.backgroundColourForState()
        self.timeLabel.textColor = event.status.headerTextColourForState()
        self.floorLabel.textColor = event.status.bodyTextColourForState()
        self.detailLabel.textColor = event.status.bodyTextColourForState()
        self.addToCalenderButton.tintColor = UIColor.init(hex: "222222")
    }
    
    @IBAction func addToCalenderHit(_ sender: Any) {
        delegate?.didTapAddToCalender(event: self.event)
    }
}

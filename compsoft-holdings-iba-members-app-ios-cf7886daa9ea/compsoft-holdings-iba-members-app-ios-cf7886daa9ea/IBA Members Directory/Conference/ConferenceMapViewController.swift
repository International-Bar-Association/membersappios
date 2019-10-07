//
//  ConferenceMapViewController.swift
//  IBA Members Directory
//
//  Created by George Smith on 15/03/2017.
//  Copyright © 2017 Compsoft plc. All rights reserved.
//

import UIKit
import MapKit
import ARSLineProgress

class ConferenceMapViewController: UIViewController {
    
    @IBOutlet weak var levelTableView: UITableView!
    @IBOutlet weak var scheduleContainerTop: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var mapScrollView: UIScrollView!
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var buildingDropdown: DropdownButton!
    @IBOutlet weak var realMapView: MKMapView!
    @IBOutlet weak var closeButton: UIBarButtonItem!
    
    var currentEventAnnotation: MKPointAnnotation!
    var selectedEventAnnotation: MKPointAnnotation!
    
    let bubblePresentAnimationController = BubblePresentAnimationController()
    var topConstraint: HeaderTopConstraint!
    var scheduleTable: ConferenceScheduleTableViewController!
    
    var nextEventTime: Timer?
    var currentAttendingEvent: Event?
    var currentSelectedEvent: Event?
    
    var showContainerView:Bool = false
    var collapseToView: UIView!
    var imageIndexLoaded = -1
    
    var currentConference: Conference!
    var currentBuilding: Building! {
        didSet {
            guard buildingDropdown != nil, currentBuilding != nil else {
                return
            }
            buildingDropdown.setTitle(currentBuilding.buildingName as String?, for: .normal)
        }
    }

    var floorplan:[UIImage]? {
        get {
            return currentBuilding != nil ? currentBuilding?.floors : []
        }
    }
    
    var floorNames: [String] {
        get {
            return currentBuilding != nil ? currentBuilding!.getFloorNames() : []
        }
    }
    
    var buildings: [Building]!
    
    var currentPinImageView = UIImageView(image: #imageLiteral(resourceName: "icon_map_pin_now"))
    var nextPinImageView = UIImageView(image: #imageLiteral(resourceName: "icon_map_pin_next"))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildings = []
        let member = MemberProfile.getMyProfile()!
        
        currentConference = Conference.query().where(withFormat: "conferenceId = %@", withParameters: [member.currentConference ?? 0]).fetch()[0] as? Conference
        buildings = currentConference.buildings()
        currentBuilding = buildings.first(where: { (building) -> Bool in
            return !building.isOffsite
        })
        

        if currentBuilding != nil {
            if currentBuilding.isOffsite {
            
                loadRealMap()
            } else {
                if let topFloor = currentBuilding.floorCount as? Int, topFloor - 1 > 0 {
                    loadMapImage(building: currentBuilding, imageNo: topFloor - 1, goingUp: false)
                } else {
                    loadMapImage(building: currentBuilding, imageNo: 0, goingUp: false)
                }
                
            }
        }
        
        mapScrollView.delegate = self
        
        levelTableView.tableFooterView = UIView()
        levelTableView.separatorStyle = .none
        
        levelTableView.clipsToBounds = false
        levelTableView.layer.masksToBounds = false
        levelTableView.layer.shadowColor = UIColor.black.cgColor
        levelTableView.layer.shadowOffset = CGSize(width: 0, height: 2)
        levelTableView.layer.shadowRadius = 5.0
        levelTableView.layer.shadowOpacity = 0.3
        currentLocationButton.alpha = 0.0
        
        if !showContainerView {
            containerView.removeFromSuperview()
            closeButton.tintColor = UIColor.clear
            closeButton.isEnabled = false
        } else {
            containerView.layer.shadowColor = UIColor.black.cgColor
            containerView.layer.shadowOffset = CGSize.zero
            containerView.layer.shadowOpacity = 0.7
            containerView.layer.shadowRadius = 5
        }
        
        currentLocationButton.isEnabled = false
        buildingDropdown.delegate = self
        buildingDropdown.datasource = self
        buildingDropdown.shouldDismissAfterSelection = true
        buildingDropdown.reloadData()
        realMapView.delegate = self
        setupProgress()
    }
    
    func setupProgress() {

        ARSLineProgressConfiguration.backgroundViewColor = UIColor(red:0.31, green:0.19, blue:0.35, alpha:1.0).cgColor
        
        ARSLineProgressConfiguration.circleColorInner =  Settings.getSelectedEventColour().cgColor
        ARSLineProgressConfiguration.circleColorMiddle = Settings.getConferencePrimaryColour().cgColor
        ARSLineProgressConfiguration.circleColorOuter = Settings.getConferencePrimaryColour().cgColor
        ARSLineProgressConfiguration.successCircleColor = Settings.getConferencePrimaryColour().cgColor
        ARSLineProgressConfiguration.checkmarkColor = Settings.getConferencePrimaryColour().cgColor
        ARSLineProgressConfiguration.failCircleColor = UIColor(red:0.82, green:0.65, blue:0.15, alpha:1.0).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = Settings.getConferencePrimaryColour()
        topConstraint = HeaderTopConstraint(constraintToAnimate: scheduleContainerTop, closedValue: 44, peakValue: 144, openValue: self.view.frame.height)
        topConstraint.onPeak = {
            if self.currentLocationButton.alpha == 0.0 {
                self.currentLocationButton.alpha = 0.0
                self.currentLocationButton.bounceIn()
            }
            
            
        }
        topConstraint.onClosing = {
            self.currentLocationButton.alpha = 0.0
        }
        topConstraint.onOpening = {
            self.currentLocationButton.alpha = 0.0
        }
        
        topConstraint.didTapHeader(view: self.view)
        mapScrollView.contentSize = CGSize(width: mapImage.frame.width, height: mapImage.frame.height)
       
        if buildings.count == 0 {
            ARSLineProgress.showBlocking(view: self.view, completionBlock: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "EmbedScheduleSegue":
                let vc = segue.destination as! ConferenceScheduleTableViewController
                vc.delegate = self
                scheduleTable = vc
                scheduleTable.topConstraint = self.topConstraint
                scheduleTable.isEmbedded = true
            break
        default:
            break
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(mapScrollView.frame)
        self.mapScrollView.minimumZoomScale = self.view.frame.width / 2048
        mapScrollView.zoomScale = self.view.frame.width / 2048

        realMapView.setCenter(CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964), animated: false)
    }
    
    @IBAction func showCurrentEvent(_ sender: Any) {
            //NOTE: Need to change image
        guard let event = currentAttendingEvent else {
            return
        }
        currentBuilding = event.building
        if event.building.isOffsite {
            loadRealMap()
        } else {
            let floor = event.floor as! Int
            if Int(floor) != imageIndexLoaded - 1 {
                loadMapImage(building: event.building, imageNo: self.floorplan!.count - (floor + 1),goingUp: floor < imageIndexLoaded)
            }
            scrollToPin(x: currentAttendingEvent?.roomCentreX as! CGFloat, y: currentAttendingEvent?.roomCentreY as! CGFloat)
        }
    }
    
    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func loadRealMap() {
        //Need to make sure the building drop down is correct
        
        mapScrollView.alpha = 0.0
        realMapView.alpha = 1.0
        levelTableView.alpha = 0.0
        
        if currentAttendingEvent != nil {
            self.addCurrentPinIfNeeded()
        }
        
        if currentSelectedEvent != nil {
            self.addSelectedPinIfNeeded()
        }
    }
    
    func loadMapImage(building: Building,imageNo: Int,goingUp: Bool) {
        guard currentBuilding != nil else {
            return
        }
        var buildingChanged =  building.buildingId != currentBuilding.buildingId
        currentBuilding = building
        
        guard let fp = self.floorplan, imageNo < fp.count else {
            if currentBuilding.isOffsite {
                loadRealMap()
            }
            return
        }
        
        guard !currentBuilding.isOffsite else {
            loadRealMap()
            return
        }
        
        mapScrollView.alpha = 1.0
        realMapView.alpha = 0.0
        levelTableView.alpha = 1.0
        
        if currentAttendingEvent != nil {
            
            if self.floorplan!.count - (imageNo + 1) != currentAttendingEvent?.floor as! Int {
                self.clearCurrentPin()
            } else {
                self.addCurrentPinIfNeeded()
            }
        }
        
        if currentSelectedEvent != nil {
            if self.floorplan!.count - (imageNo + 1) != currentSelectedEvent?.floor as! Int {
                self.clearEventPin()
            } else {
                self.addSelectedPinIfNeeded()
            }
        }
        
        if(self.imageIndexLoaded != imageNo || buildingChanged) {
        let current = self.mapImage.transform
        if goingUp {
            self.mapImage.transform = CGAffineTransform.identity.scaledBy(x: 0.0, y: 0.0)
        } else {
            self.mapImage.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
        }
        
       UIView.transition(with: mapImage, duration: 0.3, options: .transitionCrossDissolve, animations: { 
        self.mapImage.image = self.floorplan!.reversed()[imageNo]
        UIView.animate(withDuration: 0.2) {
            //self.mapImage.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.mapImage.transform = current
        }
       }) { (fin) in
        self.imageIndexLoaded = imageNo
        self.levelTableView.reloadData()
        }
        }
    }
    
    func addPinToRealMap(lat: CGFloat, long: CGFloat,current: Bool, shouldScrollTo: Bool = true) {
        if current {
            if currentEventAnnotation != nil {
                self.realMapView.removeAnnotation(currentEventAnnotation)
            }
            currentEventAnnotation = MKPointAnnotation()
            currentEventAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
            self.realMapView.addAnnotation(currentEventAnnotation)
            let region = MKCoordinateRegionMake(currentEventAnnotation.coordinate, MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))
            //self.realMapView.setCenter(currentEventAnnotation.coordinate, animated: true)
            self.realMapView.setRegion(region, animated: true)
        } else {
            if selectedEventAnnotation != nil {
                self.realMapView.removeAnnotation(selectedEventAnnotation)
            }
            selectedEventAnnotation = MKPointAnnotation()
            selectedEventAnnotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(long))
            self.realMapView.addAnnotation(selectedEventAnnotation)
            let region = MKCoordinateRegionMake(selectedEventAnnotation.coordinate, MKCoordinateSpan(latitudeDelta: 0.006, longitudeDelta: 0.006))
            //self.realMapView.setCenter(currentEventAnnotation.coordinate, animated: true)
            self.realMapView.setRegion(region, animated: true)
        }
    }
    
    func addPinToMap(x:CGFloat,y:CGFloat,current: Bool, shouldScrollTo: Bool = true) {
            self.mapScrollView.layoutIfNeeded()
            self.mapScrollView.setZoomScale(1, animated: false)
            let currentZoom = CGFloat(1)
            var neededImageView: UIImageView!
            if current {
                neededImageView = self.currentPinImageView
            } else {
                neededImageView = self.nextPinImageView
            }
            
            let pinWidth = CGFloat(50)
            let pinHeight = CGFloat(50)
            neededImageView.frame = CGRect(x: (x - (pinWidth / 2)), y: (y - (pinHeight)), width: pinWidth, height: pinHeight )
            neededImageView.transform = CGAffineTransform(scaleX: currentZoom, y: currentZoom)
            self.mapImage.addSubview(neededImageView)
            if shouldScrollTo {
                self.scrollToPin(x: x, y: y)
        }
    }
    
    func scrollToPin(x: CGFloat, y: CGFloat) {
        let scrollX =  x - (self.mapScrollView.frame.width / 2)
        let scrollY = y - (self.mapScrollView.frame.height / 2)
        let pinImageWidthHalved = self.nextPinImageView.frame.width / 2
        let pinImageHeightHalved = self.nextPinImageView.frame.height / 2
        let scrollToPoint = CGPoint(x:scrollX + pinImageWidthHalved, y:scrollY + pinImageHeightHalved)
        UIView.animate(withDuration: 1.5) {
            self.mapScrollView.contentOffset = scrollToPoint
        }
    }
    
    func checkUserForCurrentEvent() {
        guard scheduleTable != nil else {
            return
        }

        if scheduleTable.userHasOnGoingEvent() {
            showCurrentEventButton()
            currentAttendingEvent = scheduleTable.getCurrentOngoingEvent(forUser: true)
            if currentAttendingEvent!.building != nil, currentAttendingEvent!.building.isOffsite {
                
                addPinToRealMap(lat: currentAttendingEvent?.lat as! CGFloat, long: currentAttendingEvent?.long as! CGFloat, current: true)
                if realMapView.alpha == 0.0 {
                    showCurrentEventButton()
                }
            } else {
                if Int(currentAttendingEvent!.floor) == imageIndexLoaded - 1 {
                    addPinToMap(x: currentAttendingEvent?.roomCentreX as! CGFloat, y: currentAttendingEvent?.roomCentreY as! CGFloat, current: true)
                }
            }

            
        } else {
            guard let nextEventDate = scheduleTable.getUserNextEventDateTime() else {
                return
            }
            nextEventTime = Timer(fireAt: nextEventDate as Date, interval: 0, target: self, selector: #selector(showCurrentEvent(_:)), userInfo: nil, repeats: false)
            
        }
    }
    
    func showCurrentEventButton() {
        print("Show button baby")
        currentLocationButton.isEnabled = true
    }
}

extension ConferenceMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
        } else {
            annotationView?.annotation = annotation
        }
        if let point = annotation as? MKPointAnnotation, point == currentEventAnnotation, let event = currentAttendingEvent {
            annotationView?.image = #imageLiteral(resourceName: "icon_map_pin_now-1")
            point.title = event.title as String?
        } else if let point = annotation as? MKPointAnnotation, point == selectedEventAnnotation, let event = currentSelectedEvent {
            
            annotationView?.image = #imageLiteral(resourceName: "icon_map_pin_next-1")
            point.title = event.title as String?
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
     
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let getDirections = UIAlertAction(title: "Get Directions", style: .default, handler:{ (alert) in
            self.openMapForPlace(event: view.annotation as! MKPointAnnotation)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            optionMenu.dismiss(animated: true, completion: nil)
        }
        optionMenu.addAction(getDirections)
        optionMenu.addAction(cancel)
        
        self.present(optionMenu,animated: true)
    }
    
    func openMapForPlace(event: MKPointAnnotation?) {
        guard event != nil else {
            return
        }
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(event!.coordinate.latitude, event!.coordinate.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = event?.title
        mapItem.openInMaps(launchOptions: options)
    }
}


extension ConferenceMapViewController: ConferenceScheduleDelegate {
    
    func selectEventFromCalender(event: Event) {
        scheduleTable.selectEvent(event: event)
        didSelectScheduleItem(event: event, current: false)
        
    }
    
    func didSelectScheduleItem(event: Event,current: Bool) {
        
        guard event != currentSelectedEvent else {
            currentSelectedEvent = nil
            clearEventPin()
            return
        }
        
        currentSelectedEvent = event
        
        if topConstraint.constraint.constant == topConstraint.open {
            topConstraint.didTapHeader(view: self.view)
            updateScheduleTable()
        }
        if event.building.isOffsite {
            currentBuilding = event.building
            loadRealMap()
            addPinToRealMap(lat: event.lat as! CGFloat, long: event.long as! CGFloat, current: false)
        } else {
            let floor = event.floor as! Int
            if floor != imageIndexLoaded || currentBuilding != event.building {
                var newFloorPlan = event.building.getFloorPlans()
                loadMapImage(building: event.building, imageNo: (newFloorPlan.count - 1) - floor ,goingUp: floor < imageIndexLoaded)
            }
            addPinToMap(x: CGFloat(event.roomCentreX), y: CGFloat(event.roomCentreY),current: current)
        }

        
        if topConstraint.constraint.constant == topConstraint.open {
            topConstraint.didTapHeader(view: self.view)
            updateScheduleTable()
        }
    }
    
    func didDeselectScheduleItem(event: Event) {
        clearEventPin()
    }
    
    func didTapScheduleHeader() {
        topConstraint.didTapHeader(view: self.view)
        if UIDevice.current.userInterfaceIdiom != .pad {
            updateScheduleTable()
        }
        
        
    }
    
    func didSwipeHeader(wasSwipedUp: Bool) {
        topConstraint.didSwipeHeader(view: self.view, directionUp: wasSwipedUp)
        updateScheduleTable()
    }
    
    func topCellDidChange(cellHeight: CGFloat) {
        topConstraint.adjustPeakHeight(height: cellHeight, view: self.view)
        updateScheduleTable()
    }
    
    func updateScheduleTable() {
        if let table = scheduleTable {
            table.updateView(constraint: topConstraint)
        }
    }
    
    func clearPinsFromMap() {
        clearCurrentPin()
        clearEventPin()
    }
    
    func clearEventPin() {
        self.nextPinImageView.removeFromSuperview()
        self.currentSelectedEvent = nil
        guard selectedEventAnnotation != nil else {
            return
        }
        self.realMapView.removeAnnotation(selectedEventAnnotation)
       
    }
    
    func clearCurrentPin() {
        self.currentPinImageView.removeFromSuperview()
    }
    
    func addCurrentPinIfNeeded() {
        
        guard currentAttendingEvent != nil else {
            return
        }
        
        if currentAttendingEvent?.building == nil || currentAttendingEvent!.building!.isOffsite {
            addPinToRealMap(lat: currentAttendingEvent?.lat as! CGFloat, long: currentAttendingEvent?.long as! CGFloat, current: true)
        } else {
            if currentPinImageView.superview == nil {
                addPinToMap(x: currentAttendingEvent?.roomCentreX as! CGFloat, y: currentAttendingEvent?.roomCentreY as! CGFloat, current: true)
            }
        }
    }
    
    func addSelectedPinIfNeeded() {
        if currentBuilding.isOffsite {
            
        } else {
            if nextPinImageView.superview == nil && currentSelectedEvent != nil && currentSelectedEvent!.building.buildingId == currentBuilding.buildingId {
                addPinToMap(x: currentSelectedEvent?.roomCentreX as! CGFloat, y: currentSelectedEvent?.roomCentreY as! CGFloat, current: false)
            }
        }
    }
    
    func eventsListDidUpdate() {
        self.checkUserForCurrentEvent()
        guard currentConference != nil else {
            return
        }
        if buildings.count == 0 {
            ARSLineProgress.hideBlocking(view: self.view, completionBlock: nil)
            buildings = currentConference.buildings()
            guard buildings.count > 0 else {
                return
            }
            currentBuilding = buildings.first(where: { (building) -> Bool in
                return !building.isOffsite
            })
            if currentBuilding.isOffsite {
                loadRealMap()
            } else {
                loadMapImage(building: currentBuilding, imageNo: 0, goingUp: false)
            }
        }
         buildings = currentConference.buildings()
         buildingDropdown.reloadData()
    }
}

extension ConferenceMapViewController: DropdownButtonDelegate,DropdownButtonDatasource {
    func titleForRow(in dropdownButton: DropdownButton, for indexPath: IndexPath) -> String {
        guard buildings.count > 0 else {
            return ""
        }
        return buildings![indexPath.row].buildingName as! String
    }
    
    func didSelectRow(in dropdownButton: DropdownButton, at indexPath: IndexPath) {
        reloadMapAndFloorViews(selectedBuilding: buildings[indexPath.row])
    }
    
    func numberOfRows(in dropdownButton: DropdownButton, for dropdown: DropdownButton) -> Int {
        return buildings.count
    }
    
    func reloadMapAndFloorViews(selectedBuilding: Building) {
        loadMapImage(building: selectedBuilding, imageNo: 0, goingUp: false)
        self.levelTableView.reloadData()
    }
}

extension ConferenceMapViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConferenceLevelTableViewCell", for: indexPath) as! ConferenceLevelTableViewCell
        var floorName = floorNames.reversed()[indexPath.row]
        debugPrint(floorName)
        cell.levelNumber.setTitle(floorName, for: .normal)
//        if indexPath.row == floorplan!.count - 1 {
//            cell.levelNumber.setTitle("G", for: .normal)
//        } else {
//            cell.levelNumber.setTitle("\((floorplan!.count - indexPath.row)-1)", for: .normal)
//        }
        

        if imageIndexLoaded == indexPath.row {
            cell.isSelected = true
            cell.levelNumber.titleLabel?.textColor = UIColor(red:0.28, green:0.53, blue:0.96, alpha:1.00)
            cell.backgroundColor = UIColor(red:0.96, green:0.96, blue:0.96, alpha:1.00)
        } else {
            cell.isSelected = false
            cell.levelNumber.titleLabel?.textColor = UIColor.darkText
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return floorplan!.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loadMapImage(building: currentBuilding, imageNo: indexPath.row,goingUp: indexPath.row < imageIndexLoaded)
        
    }
}

extension ConferenceMapViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        bubblePresentAnimationController.originalFrame = appDel.bubbleContainerView.frame
        if let vc = presenting as? ConferenceMenuViewController {
            bubblePresentAnimationController.viewTransforming = vc.scheduleButton
            collapseToView = vc.scheduleButton
        } else {
            bubblePresentAnimationController.viewTransforming = self.view
        }
        
        return bubblePresentAnimationController
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        bubblePresentAnimationController.dismissing = true
        bubblePresentAnimationController.viewTransforming = collapseToView
        return bubblePresentAnimationController
    }
}

extension ConferenceMapViewController: UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        nextPinImageView.transform = CGAffineTransform(scaleX: 1/scrollView.zoomScale, y: 1/scrollView.zoomScale)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mapImage
    }
}

class ConferenceLevelTableViewCell: UITableViewCell {
    @IBOutlet weak var levelNumber: UIButton!
    
}


//
//  StoreNaverMapTableViewCell.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 4. 7..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit

class StoreNaverMapTableViewCell: UITableViewCell, NMapViewDelegate, NMapPOIdataOverlayDelegate {

    var mapView: NMapView?
    
    // 그냥 콘텐츠뷰에 추가하면 테이블뷰 높이를 알 수 없기 때문에 subUiView를 하나 넣어주고 그 높이를 160으로 세팅하고 들어감
    @IBOutlet weak var subMapView: UIView!
    
    @IBOutlet weak var levelStepper: UIStepper!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        
        
        mapView = NMapView(frame: self.contentView.frame)
        if let mapView = mapView {
            mapView.delegate = self
            
            // set the application api key for Open MapViewer Library
            mapView.setClientId("IabRr36v8g8q7r5dY4Q5")
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.subMapView.addSubview(mapView)
            
            // Zoom 용 UIStepper 셋팅.
            // 스텝퍼를 넣어줘야 함
            initLevelStepper(mapView.minZoomLevel(), maxValue:mapView.maxZoomLevel(), initialValue:11)
            subMapView.bringSubview(toFront: levelStepper)
            
            // 네이버 지도앱 실행 - 지속적으로 설치 여부 물어봄
            // mapView.setBuiltInAppControl(true)
            // mapView.executeNaverMap()
        }
    }

    /**
     Prepares for reusing the cell, removing all annotations
     */
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    /**
     Set the separator to be full width as frame changes
     */
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorInset = UIEdgeInsets.zero
    }
    
    // MARK: - Level Stepper
    
    func initLevelStepper(_ minValue: Int32, maxValue: Int32, initialValue: Int32) {
        levelStepper.minimumValue = Double(minValue)
        levelStepper.maximumValue = Double(maxValue)
        levelStepper.stepValue = 1
        levelStepper.value = Double(initialValue)
    }
    
    @IBAction func levelStepperValeChanged(_ sender: UIStepper) {
        mapView?.setZoomLevel(Int32(sender.value))
    }

    
    func onMapView(_ mapView: NMapView!, initHandler error: NMapError!) {
        if error == nil {
            mapView.reload()
            print("Mapview reloaded")
        } else {
            print("onMapView:initHandler: \(error.description)")
        }
    }

    func zoomMapToStoreLocation(_ store: Store) {
        let lat = store.location?.latitude as! Double
        let long = store.location?.longitude as! Double
        let title = store.name!
        
        let point = NGeoPoint(longitude: long, latitude: lat)
        
        // 지도 센터 잡기, 줌 레벨
        mapView?.setMapCenter(point, atLevel: 11)
        // 마커 보이기
        showMarkers(point, name: title)
        
    }
    
    func showMarkers(_ point: NGeoPoint, name: String) {
        if let mapOverlayManager = mapView?.mapOverlayManager {
            if let poiDataOverlay = mapOverlayManager.newPOIdataOverlay() {
                
                poiDataOverlay.initPOIdata(1)
                
                poiDataOverlay.addPOIitem(atLocation: point, title: name, type: UserPOIflagTypeDefault, with: nil)
                
                poiDataOverlay.endPOIdata()
                
                // show all POI
                poiDataOverlay.showAllPOIdata()
                
                poiDataOverlay.selectPOIitem(at: 1)
            }
        }
    }
    
    // MARK: - NMapPOIdataOverlayDelegate
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForOverlayItem poiItem: NMapPOIitem!, selected: Bool) -> UIImage! {
        return NMapViewResources.imageWithType(poiItem.poiFlagType, selected: selected)
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, anchorPointWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return NMapViewResources.anchorPoint(withType: poiFlagType)
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, calloutOffsetWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForCalloutOverlayItem poiItem: NMapPOIitem!, constraintSize: CGSize, selected: Bool, imageForCalloutRightAccessory: UIImage!, calloutPosition: UnsafeMutablePointer<CGPoint>!, calloutHit calloutHitRect: UnsafeMutablePointer<CGRect>!) -> UIImage! {
        return nil
    }
}

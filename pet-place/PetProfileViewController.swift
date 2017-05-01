//
//  PetProfileViewController.swift
//  pet-place
//
//  Created by Ken Choi on 2017. 2. 5..
//  Copyright © 2017년 press.S. All rights reserved.
//

import UIKit
import Eureka
import SCLAlertView
import Kingfisher

/// A viewcontroller that displays the pet profile information

class PetProfileViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var addView: UIView!
    
    var petArray = [PetProfile]()
    
    /// Lazy getter for the dateformatter that formats the date property of each pet profile to the desired format
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 당신의 펫 프로필을 추가하시겠습니까?
        self.addView.isHidden = true
        self.addView.layer.cornerRadius = 7.5
        
        self.navigationController?.title = "펫 프로필"
        setupPetArray { (success) in
            if success {
                if self.petArray.count != 0 {
                    self.addView.isHidden = true
                } else {
                    self.addView.isHidden = false
                }
            } else {
                self.addView.isHidden = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        collectionView.reloadData()
    }
    
    // 반려동물 배열 준비하기
    func setupPetArray(completionHandler: @escaping (_ success: Bool) -> ()) {
        let user = Backendless.sharedInstance().userService.currentUser
        // 배열 초기화
        petArray.removeAll()
        
        // 유저에서 펫프로필 가져오기
        let objectID = user?.objectId
        let userStore = Backendless.sharedInstance().persistenceService.of(BackendlessUser.ofClass())
        userStore?.findID(objectID, response: { (response) in
            let petUser = response as! BackendlessUser
            let petProfiles = petUser.getProperty("petProfiles") as! [PetProfile]
            dump(petProfiles)
            
            let myGroup = DispatchGroup()
            
            // objectId로 세부사항 불러오기
            for petProfile in petProfiles {
                myGroup.enter()
                let objectId = petProfile.objectId
                
                let dataStore = Backendless.sharedInstance().persistenceService.of(PetProfile.ofClass())
                
                dataStore?.findID(objectId, response: { (response) in
                    if let response = response as? PetProfile {
                        self.petArray.append(response)
                    }
                    myGroup.leave()
                }, error: { (Fault) in
                    print("There is error to retrieve Pet Profiles: \(String(describing: Fault?.description))")
                })
            }
            myGroup.notify(queue: DispatchQueue.main, execute: {
                // 정렬
                self.petArray = self.petArray.sorted { (left, right) -> Bool in
                    return left.created > right.created
                }
                print("This is number of petArray: \(self.petArray.count)")
                completionHandler(true)
                self.collectionView.reloadData()
            })
        }, error: { (Fault) in
            print("There is error to retrieve user: \(String(describing: Fault?.description))")
        })
        
    }
    
    // 예방접종 이력 뷰 이동
    func showVac(sender: MyButton) {
        performSegue(withIdentifier: "ShowVaccination", sender: sender)
        
    }
    
    // 병력 이력 뷰 이동
    func showHistory(sender: MyButton) {
        performSegue(withIdentifier: "ShowSickHistory", sender: sender)

    }
    
    // 프로필 편집 뷰 이동
    func editPetProfile(sender: MyButton) {
        performSegue(withIdentifier: "PetProfileEdit", sender: sender)
    }
    
    // 프로필 삭제 물어보고
    func deletePetProfile(sender: MyButton) {
        let profile = petArray[sender.row!]
        let user = Backendless.sharedInstance().userService.currentUser
        
        // close 버튼 숨기기
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        let alertView = SCLAlertView(appearance: appearance)
        
        if user != nil {
            alertView.addButton("Yes", action: { 
                var petProfiles = user?.getProperty("petProfiles") as! [PetProfile]
                if let index = petProfiles.index(of: profile) {
                    petProfiles.remove(at: index)
                }
                user?.setProperty("petProfiles", object: petProfiles)
                Backendless.sharedInstance().userService.update(user, response: { (user) in
                    SCLAlertView().showSuccess("삭제되었습니다", subTitle: "OK")
                    _ = self.navigationController?.popViewController(animated: true)
                }, error: { (Fault) in
                    print("Server reported an error on deleting pet profile: \(String(describing: Fault?.description))")
                })
            })
            alertView.addButton("No", action: { 
                print("User says no")
                SCLAlertView().showInfo("취소", subTitle: "저장이 취소되었습니다")
            })
            
            alertView.showInfo("펫 프로필 삭제", subTitle: "삭제하시겠습니까?")
            
        } else {
            print("There is no user u can save")
        }
    }
    
    /**
     Called when the segue is about to be performed. Get the current PetProfile object that is connected with the cell, and assign it to the destination viewController.
     
     :param: segue  The segue object containing information about the view controllers involved in the segue.
     :param: sender The object that initiated the segue.
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PetProfileEdit" {
            let destinationVC = segue.destination as! PetProfileEditViewController
            destinationVC.selectedPetProfile = petArray[(sender as! MyButton).row!]
        } else if segue.identifier == "ShowVaccination" {
            let destinationVC = segue.destination as! PetProfilePopUpViewController
            if let vaccination = petArray[(sender as! MyButton).row!].vaccination {
                destinationVC.selectedVaccine = vaccination
            } else {
                destinationVC.selectedVaccine = "입력해주세요"
            }
        } else if segue.identifier == "ShowSickHistory" {
            let destinationVC = segue.destination as! PetProfilePopUpViewController
            if let sickHistory = petArray[(sender as! MyButton).row!].sickHistory {
                destinationVC.selectedSickHistory = sickHistory
            } else {
                destinationVC.selectedSickHistory = "입력해주세요"
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return petArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PetProfileCell", for: indexPath) as! PetProfileCollectionViewCell
        
        /// 백신 기록 보여주기/숨기기
        cell.vaccinationShowHideButton.addTarget(self, action: #selector(PetProfileViewController.showVac), for: .touchUpInside)
        /// 기타 병력 기록 보여주기/숨기기
        cell.historyShowHideButton.addTarget(self, action: #selector(PetProfileViewController.showHistory), for: .touchUpInside)
        /// 편집 버튼
        cell.editButton.addTarget(self, action: #selector(PetProfileViewController.editPetProfile(sender:)), for: .touchUpInside)
        /// 편집 버튼에 row 저장
        cell.editButton.row = indexPath.row
        /// 삭제 버튼
        cell.deleteButton.addTarget(self, action: #selector(PetProfileViewController.deletePetProfile(sender:)), for: .touchUpInside)
        /// 삭제 버튼에 row 저장
        cell.deleteButton.row = indexPath.row
        
        cell.petProfileImageView.layer.cornerRadius = cell.petProfileImageView.layer.frame.width/2
        
        /// petArray의 petProfile에서 사진이 있는 경우
        cell.petProfileImageView.image = #imageLiteral(resourceName: "imageplaceholder")
        print("This is pet profile url: \(String(describing: petArray[indexPath.row].imagePic))")
        if !(petArray[indexPath.row].imagePic?.isEmpty)! {
            let url = URL(string: petArray[indexPath.row].imagePic!)
            DispatchQueue.main.async(execute: {
                cell.petProfileImageView.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "imageLoadingHolder"), options: [.transition(.fade(0.2))], progressBlock: nil, completionHandler: nil)
            })
        } else {
            cell.petProfileImageView.image = #imageLiteral(resourceName: "imageplaceholder")
        }
        
        cell.nameLabel.text = petArray[indexPath.row].name
        cell.breedLabel.text = petArray[indexPath.row].breed
        cell.genderLabel.text = petArray[indexPath.row].gender
        cell.speciesLabel.text = petArray[indexPath.row].species
        
        cell.birthdayLabel.text = dateFormatter.string(from: petArray[indexPath.row].birthday as Date)

        cell.registrationLabel.text = petArray[indexPath.row].registration
        
        if petArray[indexPath.row].neutralized == true {
            cell.neutralizedLabel.text = NSLocalizedString("Neutralized", comment: "")
        } else if petArray[indexPath.row].neutralized == false {
            cell.neutralizedLabel.text = NSLocalizedString("No Neutralized", comment: "")
        } else {
            cell.neutralizedLabel.text = "정보 없음"
        }
        
        // 버튼에 어떤 펫 프로필인지 저장
        cell.vaccinationShowHideButton.row = indexPath.row
        cell.historyShowHideButton.row = indexPath.row
        
        // 숨기기
        cell.vaccinationLabel.isHidden = true
        cell.historyLabel.isHidden = true
        
        // 텍스트 저장해서 보이기 - 필요 없어짐
        /**
        if let vaccination = petArray[indexPath.row].vaccination {
            cell.vaccinationLabel.text = vaccination
        } else {
            cell.vaccinationLabel.text = "EMPTY"
        }
        
        if let sickHistory = petArray[indexPath.row].sickHistory {
            cell.historyLabel.text = sickHistory
        } else {
            cell.historyLabel.text = "EMPTY"
        }
        */
        
        cell.pageControl.numberOfPages = petArray.count
        cell.pageControl.currentPage = indexPath.row
        
        // 스택뷰에서 숨겼다가 보이기
        /**
        if isVaccinationShow == false {
            cell.vaccinationStackView.isHidden = true
            cell.vaccinationShowHideButton.setTitle("Show", for: .normal)
        } else {
            cell.vaccinationShowHideButton.setTitle("Hide", for: .normal)
            UIView.animate(withDuration: 0.3, animations: {
                cell.vaccinationStackView.isHidden = false
            })
        }
        
        if isHistoryShow == false {
            cell.historyStackView.isHidden = true
            cell.historyShowHideButton.setTitle("Show", for: .normal)
        } else {
            cell.historyShowHideButton.setTitle("Hide", for: .normal)
            UIView.animate(withDuration: 0.3, animations: {
                cell.historyStackView.isHidden = false
            })
        }
        */
        
        cell.updateConstraintsIfNeeded()
        cell.layoutIfNeeded()
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        let width = UIScreen.main.bounds.size.width
//        let height = self.view.bounds.size.height-self.topLayoutGuide.length-self.bottomLayoutGuide.length
        
        let width = collectionView.layer.frame.width
        let height = collectionView.layer.frame.height
        
        return CGSize(width: width, height: height)
    }
    
}

class MyButton: UIButton {
    var row: Int?
}


